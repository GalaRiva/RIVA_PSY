import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

/// Flexible (non-blocking) Play Store update check: the user keeps using
/// the app while the new version downloads in the background, then gets
/// a prompt to restart and apply it. Deliberately never surfaces an error
/// to the user — checkForUpdate() throws on anything that isn't a real
/// Play Store install (sideloaded test APKs, no Play Services, no network),
/// which is expected and not a bug to report.
class InAppUpdateService {
  static bool _checkedThisSession = false;

  static Future<void> checkAndPromptUpdate(BuildContext context) async {
    if (_checkedThisSession || !Platform.isAndroid) return;
    _checkedThisSession = true;

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability != UpdateAvailability.updateAvailable ||
          !info.flexibleUpdateAllowed) {
        return;
      }

      await InAppUpdate.startFlexibleUpdate();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(days: 1),
          content: Text('update_available'.tr()),
          action: SnackBarAction(
            label: 'update_restart'.tr(),
            onPressed: () => InAppUpdate.completeFlexibleUpdate(),
          ),
        ),
      );
    } catch (_) {
      // No Play Store install source, no update, offline, etc. — silently
      // skip, this check is opportunistic and never critical to app function.
    }
  }
}
