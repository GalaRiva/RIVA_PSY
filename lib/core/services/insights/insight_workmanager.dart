import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';

import '../../db/hive_db.dart';
import '../workmanager/workmanager_service.dart';
import 'gratitude_nudge_store.dart';
import 'insight_engine.dart';
import 'insight_notifier.dart';
import 'offline_translations.dart';

const String nightlyInsightTaskName = 'nightlyInsightAnalysis';
const String gratitudeNudgeTaskName = 'spontaneousGratitudeNudge';

/// Runs in a separate background isolate spawned by the native WorkManager
/// plugin (not a plain `compute()` isolate) — that isolate does get a real
/// Flutter engine with plugin support, so Hive/rootBundle/notifications work
/// here the same as in the foreground, they just need their own init calls
/// since none of `main()`'s setup ran in this isolate.
///
/// Workmanager only supports one callback dispatcher for the whole app, so
/// both periodic jobs are routed through this single entry point by task
/// name rather than each having their own.
@pragma('vm:entry-point')
void insightCallbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      if (task == nightlyInsightTaskName) {
        await _runNightlyInsightAnalysis();
      } else if (task == gratitudeNudgeTaskName) {
        await _runGratitudeNudge();
      }
    } catch (_) {
      // Best-effort background job — a failure here must not crash the
      // native WorkManager execution, just skip this run.
    }
    return true;
  });
}

/// Brand teal — set as both the channel's default accent and each
/// notification's own `color` so the small-icon badge in the shade renders
/// on-brand instead of the OS default (plain black/gray circle).
const Color _brandNotificationColor = Color(0xFF2A5C55);

Future<void> _runNightlyInsightAnalysis() async {
  await HiveDB.initDB();
  await AwesomeNotifications().initialize('resource://drawable/ic_stat_notify', [
    NotificationChannel(
      channelGroupKey: 'reminders',
      channelKey: 'scheduled',
      channelName: 'RIVA PSY',
      channelDescription: 'Notification channel for RIVA PSY',
      channelShowBadge: true,
      importance: NotificationImportance.High,
      enableVibration: true,
      defaultColor: _brandNotificationColor,
    ),
  ], channelGroups: [
    NotificationChannelGroup(
      channelGroupKey: 'reminders',
      channelGroupName: 'Напоминания',
    ),
  ]);
  final batch = await InsightEngine().run();
  await InsightNotifier.notify(batch);
  // Refreshes the pill reminder schedule so the next occurrence can pick
  // up a fresh 'regularity' nudge (see
  // AwesomeNotificationService._regularityNudgeText) instead of always
  // waiting for the next foreground app-open/pill-save to do it.
  await WorkManagerService().initService();
}

/// Fires one random text from the `gratitude_nudge_template_1..30` pool as a
/// standalone local notification — a lightweight prompt to notice something
/// good right now, independent of any diary/pill data.
Future<void> _runGratitudeNudge() async {
  await AwesomeNotifications().initialize('resource://drawable/ic_stat_notify', [
    NotificationChannel(
      channelGroupKey: 'reminders',
      channelKey: 'gratitude',
      channelName: 'RIVA PSY',
      channelDescription: 'Notification channel for RIVA PSY',
      channelShowBadge: true,
      importance: NotificationImportance.High,
      enableVibration: true,
      defaultColor: _brandNotificationColor,
    ),
  ], channelGroups: [
    NotificationChannelGroup(
      channelGroupKey: 'reminders',
      channelGroupName: 'Напоминания',
    ),
  ]);
  final translations = await OfflineTranslations.load();
  final pick = Random().nextInt(30) + 1;
  final body = OfflineTranslations.toSentenceLines(
      OfflineTranslations.tr(translations, 'gratitude_nudge_template_$pick'));
  await GratitudeNudgeStore.save(body);
  final id = ('gratitude_${DateTime.now().toIso8601String()}').hashCode & 0x7FFFFFFF;
  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: 'gratitude',
      title: 'RIVA PSY',
      body: body,
      wakeUpScreen: true,
      category: NotificationCategory.Reminder,
      color: _brandNotificationColor,
      notificationLayout: NotificationLayout.BigText,
    ),
  );
}

/// Registers the nightly analysis job (Android only for now — iOS background
/// task timing isn't controllable the same way and isn't wired up yet).
/// `frequency: 24h` + `requiresCharging: true` means Android will run this
/// roughly once a day, but only whenever the charging constraint happens to
/// be satisfied within that window — this is a best-effort schedule, not a
/// guaranteed exact clock time (an Android WorkManager platform constraint,
/// not a bug in this code).
Future<void> registerNightlyInsightTask() async {
  final workmanager = Workmanager();
  await workmanager.initialize(insightCallbackDispatcher, isInDebugMode: false);
  await workmanager.registerPeriodicTask(
    'nightlyInsightAnalysisTask',
    nightlyInsightTaskName,
    frequency: const Duration(hours: 24),
    initialDelay: _delayUntilNext(2, 30),
    constraints: Constraints(networkType: NetworkType.not_required, requiresCharging: true),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

/// Registers the spontaneous-gratitude nudge job (Android only, same
/// reasoning as the nightly job). Roughly every 2 days, no charging
/// constraint since these are meant to land during normal daytime use, not
/// overnight. `registerNightlyInsightTask` must run first in `main.dart` so
/// `Workmanager().initialize(...)` has already been called with the shared
/// dispatcher above.
Future<void> registerGratitudeNudgeTask() async {
  await Workmanager().registerPeriodicTask(
    'spontaneousGratitudeNudgeTask',
    gratitudeNudgeTaskName,
    frequency: const Duration(hours: 48),
    initialDelay: Duration(hours: 6 + Random().nextInt(36)),
    constraints: Constraints(networkType: NetworkType.not_required),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );
}

/// Manual trigger for the exact same nightly-analysis code path, for
/// on-device testing from Settings — real WorkManager runs can be delayed
/// hours by Android (Doze, the `requiresCharging` constraint, OEM battery
/// management) so waiting for one isn't a practical way to verify this works.
Future<void> runNightlyInsightAnalysisNow() => _runNightlyInsightAnalysis();

/// Manual trigger for the exact same gratitude-nudge code path, same
/// reasoning as [runNightlyInsightAnalysisNow].
Future<void> runGratitudeNudgeNow() => _runGratitudeNudge();

Duration _delayUntilNext(int hour, int minute) {
  final now = DateTime.now();
  var target = DateTime(now.year, now.month, now.day, hour, minute);
  if (!now.isBefore(target)) target = target.add(const Duration(days: 1));
  return target.difference(now);
}
