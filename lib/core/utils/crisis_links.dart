import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/custom_message_box.dart';

// Same pattern as subscriptionUrlForLocale: the site has one localized
// helplines page per language (ru at the root, no /ru). The numbers live
// only on the site, so they never go stale in two places.
String crisisUrlForLocale(BuildContext context) {
  switch (context.locale.languageCode) {
    case 'en':
      return 'https://rivapsy.com/en/crisis';
    case 'es':
      return 'https://rivapsy.com/es/crisis';
    default:
      return 'https://rivapsy.com/crisis';
  }
}

// Opens the helplines page in the browser. If that isn't possible (no
// internet / no browser) the person must not be left with a silent failure
// at a bad moment — show the universal emergency number instead.
Future<void> openHelplines(BuildContext context) async {
  var opened = false;
  try {
    opened = await launchUrl(Uri.parse(crisisUrlForLocale(context)),
        mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!opened && context.mounted) {
    showDialog(
      context: context,
      builder: (_) => CustomMessageBox(
        title: 'helpline_title'.tr(),
        content: 'helpline_open_failed'.tr(),
        height: 230,
      ),
    );
  }
}
