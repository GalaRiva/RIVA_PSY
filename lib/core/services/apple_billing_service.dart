import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/tariff_model.dart';
import '../user_data/user.dart';

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
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
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
        // in_app_purchase_storekit populates this with the base64-encoded
        // App Store receipt (legacy verifyReceipt format), not a StoreKit 2
        // JWS — the Cloud Function verifies against Apple's verifyReceipt
        // endpoint accordingly.
        'receiptData': purchase.verificationData.serverVerificationData,
        'productId': purchase.productID,
      });
      final tariffIsEnd = result.data['tariffIsEnd'] as String?;
      if (tariffIsEnd != null) {
        await CurrentUser.repo.setLocalUserData(
          currentTariff: TariffModel(
            name: 'Орион',
            nameInEn: 'Oreon',
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
    }
  }
}
