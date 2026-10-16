import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart' show Color;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../presentation/initial_setup/onboarding/onboarding_concern.dart';
import '../insights/offline_translations.dart';

// Local "come back" touches, with no server and no analytics: every time the
// app becomes active the two pending touches are cancelled and re-planned
// from *now* — 3 days and 10 days ahead. If the person returns sooner they
// are simply pushed forward again; if not, they fire on their own. After the
// 10-day touch nothing more is scheduled until the next visit, so a lapsed
// user gets at most two quiet messages and then silence.
//
// Wording is deliberately factual and pressure-free (no "you are losing
// progress", no counters). Never prompts for permission — it only uses the
// permission the person already granted.
class ReengagementScheduler {
  // Cached by NextStepCard when it resolves the person's matched topic, so
  // the notification can name a real unfinished topic without any network
  // call at schedule time.
  static const topicTitlePrefsKey = 'reengage_topic_title_v1';
  static const _lastActiveKey = 'last_active_at_v1';
  static const _plannedAtKey = 'reengage_planned_at_v1';

  static final int _id3d = 'reengage_3d'.hashCode & 0x7FFFFFFF;
  static final int _id10d = 'reengage_10d'.hashCode & 0x7FFFFFFF;

  static Future<void> onAppActive() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastActiveKey, DateTime.now().toIso8601String());

      // The home screen is shown many times a day — re-planning (which
      // parses the translations file) only needs to happen every few hours.
      final plannedAt = DateTime.tryParse(prefs.getString(_plannedAtKey) ?? '');
      if (plannedAt != null &&
          DateTime.now().difference(plannedAt) < const Duration(hours: 6)) {
        return;
      }

      await AwesomeNotifications().cancel(_id3d);
      await AwesomeNotifications().cancel(_id10d);
      if (!await AwesomeNotifications().isNotificationAllowed()) return;
      // Someone with daily reminders on already hears from the app every day
      // (they keep firing while the app is closed) — a "come back" push on
      // top would just be noise. These touches exist only for people who
      // have no regular reminders at all.
      final dailyReminders = prefs.getStringList('reminderTimeInStr') ?? const <String>[];
      if (dailyReminders.isNotEmpty) return;

      final t = await OfflineTranslations.load();
      final topic = prefs.getString(topicTitlePrefsKey);
      final body3d = (topic != null && topic.trim().isNotEmpty)
          ? OfflineTranslations.tr(t, 'onb_reengage_3d_topic', {'topic': topic})
          : OfflineTranslations.tr(t, 'onb_reengage_3d_generic');
      final body10d = OfflineTranslations.tr(t, 'onb_reengage_10d');

      // The onboarding's own day-2 follow-up already covers a brand-new
      // person's first days — skip the 3-day touch then, so nobody gets two
      // messages within a day of each other (max one touch per week).
      final started = await OnboardingPrefs.startedAt();
      final inOnboardingWindow =
          started != null && DateTime.now().difference(started) < const Duration(days: 4);
      if (!inOnboardingWindow) await _schedule(_id3d, days: 3, body: body3d);
      await _schedule(_id10d, days: 10, body: body10d);
      await prefs.setString(_plannedAtKey, DateTime.now().toIso8601String());
    } catch (_) {
      // Best effort — never let this disturb the app.
    }
  }

  static Future<void> _schedule(int id, {required int days, required String body}) async {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day, 11, 0).add(Duration(days: days));
    await AwesomeNotifications().createNotification(
      schedule: NotificationCalendar(
        year: target.year,
        month: target.month,
        day: target.day,
        hour: target.hour,
        minute: target.minute,
        repeats: false,
        allowWhileIdle: true,
      ),
      content: NotificationContent(
        id: id,
        channelKey: 'scheduled',
        title: 'RIVA PSY',
        body: body,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        color: const Color(0xFF2A5C55),
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }
}
