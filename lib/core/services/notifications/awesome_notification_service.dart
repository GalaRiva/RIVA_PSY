import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:googleapis/gkebackup/v1.dart';
import 'package:riva_psy/core/services/notifications/notification_service.dart';
import 'package:riva_psy/core/utils/date_extension.dart';

import '../../../presentation/charts/concrete_pill/concrete_pill_screen.dart';
import '../../../routes/app_routes.dart';
import '../insights/insights_repo.dart';
import '../insights/offline_translations.dart';
import '../workmanager/workmanager_model.dart';
import 'notification_controller.dart';

class AwesomeNotificationService extends NotificationService {
  // If a 'regularity' insight fired for this pill in the last 2 days, the
  // next reminder's body is drawn from a 3-way pool: the standard "Time to
  // take X" text, or one of 2 encouraging nudges (category 8 from the
  // insight template library) — so the nudge shows up sometimes, not every
  // time. Only the very next occurrence gets this — the rest of the course
  // keeps the standard text, since we can't know future insight state when
  // pre-scheduling many days at once. Uses OfflineTranslations rather than
  // easy_localization's `.tr()` because this also runs from the nightly
  // workmanager background isolate (see insight_workmanager.dart), which
  // never builds the EasyLocalization widget tree `.tr()` depends on.
  Future<String?> _regularityNudgeText(String pillName) async {
    if (pillName.isEmpty) return null;
    final insights = await InsightsRepo().getAll();
    final recent = insights.where((i) =>
        i.category == 'regularity' &&
        i.namedArgs['pill'] == pillName &&
        DateTime.now().difference(i.generatedAt).inDays <= 2);
    if (recent.isEmpty) return null;
    final pick = Random().nextInt(3); // 0 = keep the standard reminder text
    if (pick == 0) return null;
    final translations = await OfflineTranslations.load();
    return OfflineTranslations.tr(translations, 'insight_action_prompt_template_$pick', {
      'pill': pillName,
      'days': recent.first.namedArgs['days'] ?? '',
    });
  }

  @override
  Future showNotification(WorkManagerModel workManagerModel, Duration dur,) async {
    final _channelKey =
        workManagerModel.pillName.isNotEmpty ? 'open' : 'scheduled';

    final Map<String, String>? _payload = {
      "name": "RIVA PSY",
      "pill": workManagerModel.pillName ?? '',
      "time":
          '${workManagerModel.hour}:${workManagerModel.minute.timeFormatted()}'
    };
    final nudgeText = await _regularityNudgeText(workManagerModel.pillName);
    final now = DateTime.now();
    int length = now.difference(workManagerModel.end).inDays.abs();
    if(now.isAfter(workManagerModel.end)) length = 0;
    for(int i = 0; i < length; i++) {
      final date = DateTime.now().add(workManagerModel.duration).add(Duration(days: i, ));
      if(true) {
        // Random().nextInt(100) gave every notification an id in 0-99.
        // A single course of reminders schedules one notification per day
        // for the whole pill course (the for-loop above) — with 100
        // possible ids and typically dozens of notifications created in
        // one burst here, id collisions were common, and awesome_notifications
        // treats a repeat id as "replace the existing schedule with this
        // one" — so later days in the loop were silently overwriting
        // earlier ones, dropping reminders with no error anywhere.
        // Deterministic hash of what actually identifies this slot (pill +
        // exact date + time) instead — stable, and only collides if the
        // same reminder is scheduled twice, which is the desired behavior.
        final id = (workManagerModel.pillName + date.toIso8601String() + _channelKey).hashCode & 0x7FFFFFFF;
        final create = await AwesomeNotifications().createNotification(
            schedule: NotificationCalendar(
                month: date.month,
                day: date.day,
                hour: date.hour,
                minute: date.minute,
                // Was `repeats: true` on a schedule that already pins a
                // specific calendar day — the outer loop above creates one
                // of these per day of the course, so "repeats" here doesn't
                // mean "daily", it means "re-arm on this exact month+day
                // next year" once fired. Each entry is already meant to
                // fire exactly once; repeats was never doing what it looked
                // like it did.
                repeats: false,
              allowWhileIdle: true
            ),
            content: NotificationContent(
              //simple notification
              id: id,
              channelKey: _channelKey,
              //set configuration wuth key "basic"
              title: 'RIVA PSY',
              // Was just 'Приём' with no pill name — every log entry showed
              // the same generic title/body no matter which medication the
              // reminder was actually for.
              body: OfflineTranslations.toSentenceLines(workManagerModel.pillName != ''
                  ? (i == 0 && nudgeText != null
                      ? nudgeText
                      : 'Пора принять: ${workManagerModel.pillName}')
                  : 'Как проходит день? Запиши, чтобы запомнить. Мы напоминаем для точной диагностики Вашего состояния'),
              payload: _payload,
              wakeUpScreen: true,
              category: NotificationCategory.Reminder,
              color: const Color(0xFF2A5C55),
              notificationLayout: NotificationLayout.BigText,
            ),
            actionButtons: workManagerModel.pillName != ''
                ? [
                    NotificationActionButton(
                      key: "open",
                      label: "Открыть 💊",
                    ),
                  ]
                : null);
        debugPrint(create ? ' create ' : 'not create');

      }
    }
  }

  Future navigator(BuildContext context, Function otherNavigationsFunc) async {
    ReceivedAction? receivedAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
    if (receivedAction != null) if (receivedAction!.channelKey == 'open') {
      Navigator.pushNamed(context, AppRoutes.concrete_pill);
      print('OPEN');
    } else
      otherNavigationsFunc();
  }

  void setListeners() {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
  }
  Future init (WorkManagerModel workManagerModel) async {
    final _channelKey = workManagerModel.pillName.isNotEmpty ? 'open' :
    'scheduled';

    await AwesomeNotifications().initialize('resource://drawable/ic_stat_notify', [
      // notification icon
      NotificationChannel(
        channelGroupKey: 'reminders',
        channelKey: _channelKey,
        channelName: 'RIVA PSY',
        channelDescription: 'Notification channel for RIVA PSY',
        channelShowBadge: true,
        importance: NotificationImportance.High,
        enableVibration: true,
        defaultColor: const Color(0xFF2A5C55),
      ),
    ], channelGroups: [
      // The channel above references channelGroupKey 'reminders', but no
      // NotificationChannelGroup with that key was ever registered — the
      // channelGroups param here was simply never passed.
      NotificationChannelGroup(
        channelGroupKey: 'reminders',
        channelGroupName: 'Напоминания',
      ),
    ]);
  }

  Future canselAllSchedules () async {
    await AwesomeNotifications().cancelAllSchedules();
  }

  /// Schedules a one-off local notification for the next 09:00 — used to
  /// tell the user about insights the nightly analysis found while the app
  /// was closed. Reuses the 'scheduled' channel already registered by the
  /// regular reminder flow instead of adding a new channel.
  Future scheduleInsightNotification({required String title, required String body}) async {
    final now = DateTime.now();
    var target = DateTime(now.year, now.month, now.day, 9, 0);
    if (!now.isBefore(target)) target = target.add(const Duration(days: 1));
    final id = ('insight_batch_${target.toIso8601String()}').hashCode & 0x7FFFFFFF;
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
        title: title,
        body: body,
        wakeUpScreen: true,
        category: NotificationCategory.Reminder,
        color: const Color(0xFF2A5C55),
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }
}
