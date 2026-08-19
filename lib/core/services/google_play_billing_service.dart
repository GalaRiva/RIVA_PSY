import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../models/tariff_model.dart';
import '../user_data/user.dart';

/// Google Play Billing purchase flow for the Orion subscription — the
/// Android-native replacement for the Stripe external-payment-link buttons
/// (see go_to_new_tariff_widget.dart, k13_screen.dart), needed because
/// registering Stripe as an "alternative payment system" in Play Console
/// requires the developer account to be a registered company, which this
/// account currently isn't.
///
/// Product IDs must be created in Play Console -> Monetize -> Products ->
/// Subscriptions with these exact strings, priced to match the existing
/// Stripe plans (5.90€/month, 69€/year) — the code only ever references
/// them by ID, the actual price/currency/locale text is entirely
/// Play Console's own responsibility to display correctly per-country.
class GooglePlayBillingService {
  static const String monthlyProductId = 'riva_psy_orion_monthly';
  static const String yearlyProductId = 'riva_psy_orion_yearly';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Call once, early (e.g. app start) — starts listening for purchase
  /// updates so a purchase that completes after the app was backgrounded
  /// (payment sheet, bank confirmation) is still picked up and verified.
  static void startListening() {
    if (_subscription != null) return;
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (error) => print('[BILLING] purchase stream error: $error'),
    );
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Throws on any failure (Billing unavailable, product not found in Play
  /// Console, purchase sheet dismissed) — callers show that as a message,
  /// same as the existing Stripe buttons' launchUrl failures.
  static Future<void> buy(String productId) async {
    if (!Platform.isAndroid) {
      throw Exception('Google Play Billing доступен только на Android.');
    }
    final available = await _iap.isAvailable();
    if (!available) {
      throw Exception('Google Play Billing недоступен на этом устройстве.');
    }
    final response = await _iap.queryProductDetails({productId});
    if (response.notFoundIDs.isNotEmpty || response.productDetails.isEmpty) {
      throw Exception(
          'Товар "$productId" не найден в Play Console — проверьте, что подписка создана и опубликована.');
    }
    final purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
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
          print('[BILLING] purchase error: ${purchase.error}');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _verifyOnServer(purchase);
          break;
        case PurchaseStatus.canceled:
          break;
      }
      // Must be called for every terminal purchase (purchased/error/
      // canceled) or Play Billing keeps redelivering it as unfinished on
      // every app start — completing it here regardless of whether server
      // verification succeeded, since retrying verification separately
      // (e.g. next launch, via restorePurchases()) doesn't require the
      // purchase to still be "pending" from Play's point of view.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Mirrors functions/index.js's stripeWebhook: server is the only thing
  /// that ever writes tariff/tariff_is_end to Firestore. The client never
  /// trusts its own read of the purchase as proof of entitlement — a
  /// purchase token can be forged/replayed, only Google's own Android
  /// Publisher API (queried server-side in verifyAndroidPurchase) is
  /// authoritative.
  static Future<void> _verifyOnServer(PurchaseDetails purchase) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('verifyAndroidPurchase');
      final result = await callable.call<Map<String, dynamic>>({
        'purchaseToken': purchase.verificationData.serverVerificationData,
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
      // Server-side verification failing here (network, function error)
      // doesn't lose the purchase — Google still has it recorded, and
      // completePurchase() below still runs regardless, so the user isn't
      // stuck. Worth a retry path (e.g. restorePurchases() on next app
      // start) rather than silently dropping it long-term, but out of
      // scope for this first pass.
      print('[BILLING] server verification failed: $e');
    }
  }
}
