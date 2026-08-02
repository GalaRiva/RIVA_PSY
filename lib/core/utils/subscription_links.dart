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
