import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../../presentation/settings/help_now_screen/help_now_screen.dart';

// One-time heads-up, shown the first time the person starts any exercise
// (first audio track or first guided-journal topic): practices can bring up
// strong feelings, they can stop any time, and the details live in
// Settings -> "Мне сейчас тяжело". Never shown again. Onboarding marks it as
// shown itself (it has its own inline line) so the first practice isn't
// interrupted by a dialog.
class ExerciseNotice {
  static const _key = 'exercise_notice_shown_v1';
  static bool _showing = false;

  static Future<void> markShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> maybeShow() async {
    if (_showing) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getBool(_key) ?? false) return;
      final context = MyApp.navigatorKey.currentContext;
      if (context == null) return;
      _showing = true;
      await prefs.setBool(_key, true);
      final label = 'helpline_settings'.tr();
      final more = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Text('helpnow_notice_text'.tr(namedArgs: {'label': label})),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('helpnow_notice_more'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('helpnow_notice_ok'.tr()),
            ),
          ],
        ),
      );
      if (more == true) {
        MyApp.navigatorKey.currentState
            ?.push(MaterialPageRoute(builder: (_) => const HelpNowScreen()));
      }
    } catch (_) {
      // Never let a notice break playback or the journal.
    } finally {
      _showing = false;
    }
  }
}
