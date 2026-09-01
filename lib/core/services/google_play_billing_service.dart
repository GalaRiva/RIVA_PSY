import 'dart:async';
import 'dart:io' show Platform;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

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

  // Must match the Offer ID created in Play Console -> Monetize ->
  // Subscriptions -> [plan] -> Offers, eligibility set to
  // "developer-determined" — Play Console doesn't filter who sees it, the
  // app decides by only passing useWelcomeOffer: true when quiz_completed_at
  // (see quiz paywall) says this user is still within the welcome window.
  static const String welcomeOfferId = 'welcome70';

  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  /// Call once, early (e.g. app start) — starts listening for purchase
  /// updates so a purchase that completes after the app was backgrounded
  /// (payment sheet, bank confirmation) is still picked up and verified.
  static void startListening() {
    // Guard added alongside AppleBillingService.startListening() being
    // wired in next to this same call (k20_screen.dart) — without it, both
    // services would subscribe to the same shared
    // InAppPurchase.purchaseStream on every platform, so a single purchase
    // would get handed to both services' _onPurchaseUpdate, each calling
    // the wrong store's verification Cloud Function for it.
    if (!Platform.isAndroid) return;
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

  /// Read-only price lookup for display (e.g. the quiz paywall showing the
  /// regular price before a purchase is attempted) — doesn't buy anything.
  ///
  /// A subscription with offers returns one ProductDetails per base-plan/
  /// offer combination (see buy()'s doc comment) — `.first` isn't reliably
  /// the plain base-plan price, it can just as easily be a discounted offer
  /// variant. This explicitly picks the entry with no offer id attached.
  static Future<ProductDetails?> queryProduct(String productId) async {
    if (!Platform.isAndroid) return null;
    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return null;
    for (final details in response.productDetails) {
      if (details is GooglePlayProductDetails) {
        final index = details.subscriptionIndex;
        final offers = details.productDetails.subscriptionOfferDetails;
        if (index != null && offers != null && offers[index].offerId == null) {
          return details;
        }
      }
    }
    return response.productDetails.first;
  }

  /// Throws on any failure (Billing unavailable, product not found in Play
  /// Console, purchase sheet dismissed) — callers show that as a message,
  /// same as the existing Stripe buttons' launchUrl failures.
  ///
  /// [useWelcomeOffer]: on Android, querying one product ID for a
  /// subscription returns one ProductDetails per base-plan/offer
  /// combination (see GooglePlayProductDetails.fromProductDetails) — when
  /// true, this looks for the entry whose offer id is [welcomeOfferId] and
  /// buys with its offerToken instead of the plain base-plan price. Falls
  /// back to the regular price if that offer isn't found (e.g. not created
  /// in Play Console yet).
  static Future<void> buy(String productId, {bool useWelcomeOffer = false}) async {
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

    ProductDetails selected = response.productDetails.first;
    String? offerToken;
    if (useWelcomeOffer) {
      for (final details in response.productDetails) {
        if (details is GooglePlayProductDetails) {
          final index = details.subscriptionIndex;
          final offers = details.productDetails.subscriptionOfferDetails;
          if (index != null && offers != null && offers[index].offerId == welcomeOfferId) {
            selected = details;
            offerToken = details.offerToken;
            break;
          }
        }
      }
    }

    final purchaseParam = offerToken != null
        ? GooglePlayPurchaseParam(productDetails: selected, offerToken: offerToken)
        : PurchaseParam(productDetails: selected);
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
