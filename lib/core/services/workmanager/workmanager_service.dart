import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riva_psy/core/services/notifications/flutter_local_notification_service.dart';
import 'package:riva_psy/core/services/notifications/notification_service.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/presentation/settings/settings_pills/repository.dart';
import 'package:workmanager/workmanager.dart';

import '../notifications/awesome_notification_service.dart';
import 'workmanager_model.dart';

const _kLastScheduleFingerprintKey = 'notification_schedule_fingerprint';
const _kLastScheduleDateKey = 'notification_schedule_date';

class WorkManagerService {
 final workmanager = Workmanager();
  Future initService() async {
    /*  workmanager.initialize(callbackDispatcher,
        isInDebugMode: true
    );
    // Periodic task registration
    await workmanager.cancelAll();*/
    try {
      final AwesomeNotificationService notificationService = AwesomeNotificationService();
      List<Map<String, dynamic>> _time = [];
      _time += await _getReminders();
      _time += await _getRemindersAboutPills();

      // The cancel-everything-then-recreate-everything below is real work —
      // for each reminder it's up to `maxScheduleDays` (60) individual
      // native createNotification() calls, so a handful of pills/reminders
      // means hundreds of platform-channel round-trips. This ran
      // unconditionally on every app launch even when nothing about the
      // reminders had changed since the last one, which is most opens in a
      // day. A same-day fingerprint match means the exact same set of
      // reminder times (and, via _getRemindersAboutPills' item.actual()
      // filter, the same set of currently-active pill courses) would just
      // get cancelled and recreated identically — skip that, but still
      // force a real rebuild at least once per calendar day so the rolling
      // `maxScheduleDays`-day window keeps getting topped up as old
      // (already-fired) days fall off the near end.
      final prefs = SharedPrefs.sharedPreferences;
      // 'end' is a DateTime — general reminders recompute it fresh as
      // `now + 30 days` on every call (see _getReminders below), so its
      // full toString() (microsecond precision) would never match between
      // two launches even on the same day. Truncating to just the date
      // keeps the fingerprint stable within a day while still changing
      // when a pill's real end date, or the day itself, changes.
      final fingerprint = _time
          .map((e) => '${e['hour']}:${e['minute']}:${e['pillName'] ?? ''}:${(e['end'] as DateTime).toIso8601String().substring(0, 10)}')
          .toList()
        ..sort();
      final fingerprintStr = fingerprint.join('|');
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      if (prefs.getString(_kLastScheduleFingerprintKey) == fingerprintStr &&
          prefs.getString(_kLastScheduleDateKey) == todayStr) {
        return;
      }

      // This was fire-and-forget (no await) while the rest of the function
      // went on to schedule fresh notifications right after. Since
      // cancelAllSchedules() is itself an async platform-channel call, its
      // completion could land *after* the new schedules were created below
      // — wiping out the very reminders this call had just set up, with no
      // error anywhere since both the schedule and the cancel technically
      // "succeeded". This runs on every save (add/edit pill, edit
      // reminders, app start), so it could silently erase reminders on
      // essentially every relevant user action. Permission being granted
      // (POST_NOTIFICATIONS) doesn't help here — the app is cancelling its
      // own notifications after creating them, not being blocked by the OS.
      await notificationService.canselAllSchedules();

      final _now = DateTime.now();
      for (int i = 0; i < _time.length; i++) {
        final workmanagerModel = WorkManagerModel.fromJson(_time[i]);
        final date = DateTime(
            _now.year, _now.month, _now.day, workmanagerModel.hour,
            workmanagerModel.minute);
        print(workmanagerModel.hour.toString() + ' ' +
            workmanagerModel.minute.toString());
        final dur = _getTimeRemaining(date);
        workmanagerModel.duration = dur;
        print('dur $dur');
        // Channels are registered once at app startup now (see
        // AwesomeNotificationService.initializeOnce(), called from
        // main.dart) — no per-call initialize() needed here anymore.
        try {
          await notificationService.showNotification(workmanagerModel, dur);
        } catch (e) {
          print('[NOTIF-DIAG] showNotification failed for "${workmanagerModel.pillName}" at ${workmanagerModel.hour}:${workmanagerModel.minute}: $e');
        }
        /*await workmanager.registerPeriodicTask(
          i.toString(),
          "simplePeriodicTask $i",
          frequency: Duration(hours: 24),
          initialDelay: dur,
        inputData: workmanagerModel.toJson()
      );*/
      }
      await prefs.setString(_kLastScheduleFingerprintKey, fingerprintStr);
      await prefs.setString(_kLastScheduleDateKey, todayStr);
    } catch (e) {
      print('[NOTIF-DIAG] initService aborted: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _getReminders () async {
    final list = await CurrentUser.repo.getReminderTimeInStr();
    List<Map<String, dynamic>> time = list.map((e) => {
      'hour': int.parse(e[0]+e[1]),
      'minute': int.parse(e[3]+e[4]),
      'end': DateTime.now().add(Duration(days: 30))
    }).toList();
    return time;
  }

  Future<List<Map<String, dynamic>>> _getRemindersAboutPills () async {
    final list = await PillsRepo().getEvent();
    List<Map<String, dynamic>> time = [];
    for (final item in list) {
      if(item.actual()) {

        time += item.hoursOfTakingPills
            .map((e) => {
                  'hour': int.parse(e[0] + e[1]),
                  'minute': int.parse(e[3] + e[4]),
                  'pillName': item.name,
                  'end': item.endDate
                })
            .toList();
      }
    }
    return time;
  }
}

Duration _getTimeRemaining(DateTime targetDateTime) {
  DateTime now = DateTime.now();
  if (now.isAfter(targetDateTime)) {
    final newDate = DateTime(targetDateTime.year, targetDateTime.month, targetDateTime.day + 1, targetDateTime.hour, targetDateTime.minute);
    return newDate.difference(now);
  }
  return targetDateTime.difference(now);
}