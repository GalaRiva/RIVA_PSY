import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../main.dart';
import '../models/tariff_model.dart';
import '../user_data/user.dart';

// Both purchase-outcome branches below used to only print() — a purchase
// that arrives via the stream (as opposed to buy()'s own synchronous
// failures, which _onBuy's try/catch already surfaces) could fail
// server-side verification or come back as PurchaseStatus.error with
// nothing visible to the user at all: tapping "Subscribe" would just
// appear to do nothing. Surfaces both cases as a SnackBar on whatever
// screen is currently on top, via the app's root navigator — this class
// has no BuildContext of its own (it's a static service, not a widget).
void _showBillingSnackBar(String message) {
  final context = MyApp.navigatorKey.currentContext;
  if (context == null) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

// FirebaseException.toString() appends '\n\n$stackTrace' whenever a stack
// trace is attached (see firebase_core_platform_interface's own source) —
// interpolating the caught error directly ('$e') was dumping that whole
// trace into the user-facing SnackBar text along with the real message.
// Pull just the clean "[code] message" part for anything that carries one.
String _billingErrorText(Object e) {
  if (e is FirebaseException) return '[${e.plugin}/${e.code}] ${e.message}';
  return e.toString();
}

/// App Store (StoreKit) purchase flow for the Orion subscription — the
/// iOS-native replacement for the Stripe external-payment-link buttons
/// (see go_to_new_tariff_widget.dart, k13_screen.dart,
/// recomendation_buy_tariff_screen.dart, paywall_screen.dart), mirroring
/// GooglePlayBillingService's shape so the four call sites can branch on
/// platform without otherwise caring which store they're talking to.
///
/// Product IDs must be created in App Store Connect -> Monetization ->
/// Subscriptions with these exact strings, priced to match the existing
/// Stripe/Play plans (5.90€/month, 69€/year) — the code only ever
/// references them by ID, price/currency/locale text is App Store
/// Connect's own responsibility to display correctly per-country.
///
/// [useWelcomeOffer] on GooglePlayBillingService has no equivalent here yet
/// — StoreKit promotional offers require a server-signed JWT generated
/// per purchase attempt (via an App Store Connect API key), which isn't
/// wired up. buy() accepts the parameter for call-site symmetry but always
/// purchases at the regular price; revisit once the welcome-offer flow is
/// actually needed on iOS.
class AppleBillingService {
  static const String monthlyProductId = 'riva_psy_orion_monthly';
  static const String yearlyProductId = 'riva_psy_orion_yearly';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  // StoreKit re-delivers stale/expired transactions (e.g. an old Sandbox
  // subscription that can't be cancelled) through purchaseStream on every
  // app start. Those must not pop an error SnackBar on whatever screen the
  // user happens to be on — errors are only shown for a purchase/restore the
  // user actually started a moment ago.
  static DateTime? _userActionUntil;
  static bool get _userInitiated =>
      _userActionUntil != null && DateTime.now().isBefore(_userActionUntil!);
  static void _markUserAction() =>
      _userActionUntil = DateTime.now().add(const Duration(minutes: 10));

  /// Call once, early (e.g. app start) — starts listening for purchase
  /// updates so a purchase that completes after the app was backgrounded
  /// (payment sheet, Face ID confirmation) is still picked up and verified.
  static void startListening() {
    // Both this and GooglePlayBillingService.startListening() are called
    // unconditionally from k20_screen.dart (simplest call site, and
    // idempotent either way) — without this guard they'd both subscribe to
    // the same shared InAppPurchase.purchaseStream on every platform, so a
    // single purchase would get handed to both services' _onPurchaseUpdate,
    // each calling the wrong store's verification Cloud Function for it.
    if (!Platform.isIOS) return;
    if (_subscription != null) return;
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) => print('[BILLING-iOS] purchase stream error: $error'),
    );
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Required by App Store Review Guideline 3.1.1 for any restorable IAP —
  /// re-delivers the user's past transactions through the same
  /// purchaseStream startListening() already subscribes to, each arriving
  /// with PurchaseStatus.restored, which _onPurchaseUpdate already routes
  /// through the exact same _verifyOnServer() path as a fresh purchase. No
  /// separate handling needed here — this just asks StoreKit to replay
  /// what the user already owns.
  ///
  /// Throws on failure (e.g. StoreKit unavailable) — callers show that as a
  /// message. A "nothing to restore" case is not an error: it simply
  /// results in no purchases arriving on the stream.
  static Future<void> restorePurchases() async {
    if (!Platform.isIOS) {
      throw Exception('Восстановление покупок доступно только на iOS.');
    }
    _markUserAction();
    await _iap.restorePurchases();
  }

  /// Read-only price lookup for display — doesn't buy anything.
  static Future<ProductDetails?> queryProduct(String productId) async {
    if (!Platform.isIOS) return null;
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return null;
    return response.productDetails.first;
  }

  /// Throws on any failure (StoreKit unavailable, product not found in App
  /// Store Connect, purchase sheet dismissed) — callers show that as a
  /// message, same as the existing Stripe buttons' launchUrl failures.
  static Future<void> buy(String productId, {bool useWelcomeOffer = false}) async {
    if (!Platform.isIOS) {
      throw Exception('Покупки через App Store доступны только на iOS.');
    }
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('App Store покупки недоступны на этом устройстве.');
    }
    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      throw Exception(
          'Товар "$productId" не найден в App Store Connect — проверьте, что подписка создана и опубликована.');
    }

    final selected = response.productDetails.first;
    final purchaseParam = PurchaseParam(productDetails: selected);
    _markUserAction();
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    // Result arrives asynchronously via purchaseStream -> _onPurchaseUpdate,
    // not as a return value from buyNonConsumable() itself.
  }

  static Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.error:
          print('[BILLING-iOS] purchase error: ${purchase.error}');
          if (_userInitiated) {
            _showBillingSnackBar(
                'purchase_verification_failed'.tr(namedArgs: {'error': '${purchase.error}'}));
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyOnServer(purchase);
          break;
        case PurchaseStatus.canceled:
          break;
      }
      // Must be called for every terminal purchase (purchased/error/
      // canceled) or StoreKit keeps redelivering it as unfinished on every
      // app start — completing it here regardless of whether server
      // verification succeeded, same reasoning as the Android side.
      // Wrapped in try/catch — this wasn't awaited-but-unguarded before,
      // so a failure here (observed: a stale/expired transaction stuck in
      // StoreKit's queue kept getting redelivered on every buy() attempt)
      // would throw past this whole loop uncaught, skipping completion
      // for every other purchase still left in `purchases` and leaving no
      // record of why finishing it never actually happened.
      if (purchase.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(purchase);
        } catch (e) {
          print('[BILLING-iOS] completePurchase failed for ${purchase.productID}: $e');
        }
      }
    }
  }

  /// Mirrors GooglePlayBillingService._verifyOnServer: server is the only
  /// thing that ever writes tariff/tariff_is_end to Firestore. The client
  /// never trusts its own read of the purchase as proof of entitlement —
  /// only Apple's own App Store Server API (queried server-side in
  /// verifyApplePurchase) is authoritative.
  static Future<void> _verifyOnServer(PurchaseDetails purchase) async {
    try {
      final callable = FirebaseFunctions.instance.httpsCallable('verifyApplePurchase');
      final result = await callable.call<Map<String, dynamic>>({
        // in_app_purchase_storekit defaults to StoreKit 2 (_useStoreKit2 =
        // true in that package), so this is the transaction's signed JWS
        // representation, not a legacy base64 App Store receipt — confirmed
        // 2026-09-14 after the legacy verifyReceipt-based Cloud Function
        // consistently rejected it as malformed (status 21002) on every
        // purchase attempt. The Cloud Function verifies it the same way
        // appleServerNotifications verifies Apple's own webhook payloads
        // (SignedDataVerifier from @apple/app-store-server-library), not
        // against the old verifyReceipt endpoint.
        'receiptData': purchase.verificationData.serverVerificationData,
        'productId': purchase.productID,
      });
      final tariffIsEnd = result.data['tariffIsEnd'] as String?;
      if (tariffIsEnd != null) {
        await CurrentUser.repo.setLocalUserData(
          currentTariff: TariffModel(
            name: 'Орион',
            nameInEn: 'Orion',
            nameInEs: 'Orion',
            endDate: DateTime.parse(tariffIsEnd),
            description: '',
            cost: 0,
            advantages: const [],
          ),
        );
      }
    } catch (e) {
      // Server-side verification failing here (network, function error, or
      // — during local StoreKit Testing — the function not deployed yet at
      // all) doesn't lose the purchase; Apple still has it recorded on the
      // device. Worth a retry path (e.g. restorePurchases() on next app
      // start) rather than silently dropping it long-term, but out of
      // scope for this first pass.
      print('[BILLING-iOS] server verification failed: $e');
      if (_userInitiated) {
        _showBillingSnackBar('purchase_verification_failed'.tr(namedArgs: {'error': _billingErrorText(e)}));
      }
    }
  }
}
