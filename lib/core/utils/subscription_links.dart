import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

// Site has separate localized pages, not one URL for everyone — ru is
// served at the root, not /ru. Shared by every in-app entry point that
// used to open the in-app YooKassa purchase flow (now retired — billing
// lives on the website via Stripe).
String subscriptionUrlForLocale(BuildContext context) {
  switch (context.locale.languageCode) {
    case 'en':
      return 'https://rivapsy.com/en';
    case 'es':
      return 'https://rivapsy.com/es';
    default:
      return 'https://rivapsy.com/';
  }
}

// Live Stripe Payment Links (functions/README.md documents the deploy/
// webhook side) — one product, two recurring prices. Regenerated whenever
// the product/price is recreated in Stripe, e.g. moving test -> live.
const String monthlyPaymentLinkUrl = 'https://buy.stripe.com/8x214n4TP6FnevzaV79k400';
const String yearlyPaymentLinkUrl = 'https://buy.stripe.com/7sY4gz3PL7Jr1IN9R39k401';

// prefilled_email both pre-fills and locks the email field on Stripe's
// checkout page, so the buyer can't accidentally type a different address
// than the one their Users doc is keyed on — that's what lets
// functions/index.js's findUserDocs() match the payment automatically
// instead of it landing in UnmatchedStripePayments. Works the same
// regardless of whether the account was created via email/password,
// Google, or Apple, since findUserDocs() already tries all three doc-id
// shapes for whatever real email address is passed here.
String paymentLinkUrlForEmail(String baseUrl, String? email) {
  if (email == null || email.isEmpty) return baseUrl;
  return '$baseUrl?prefilled_email=${Uri.encodeComponent(email)}';
}
