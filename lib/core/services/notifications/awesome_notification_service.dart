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
import '../workmanager/workmanager_model.dart';
import 'notification_controller.dart';

class AwesomeNotificationService extends NotificationService {
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
    final now = DateTime.now();
    int length = now.difference(workManagerModel.end).inDays.abs();
    if(now.isAfter(workManagerModel.end)) length = 0;
    for(int i = 0; i < length; i++) {
      final date = DateTime.now().add(workManagerModel.duration).add(Duration(days: i, ));
      if(true) {
        final create = await AwesomeNotifications().createNotification(
            schedule: NotificationCalendar(
                month: date.month,
                day: date.day,
                hour: date.hour,
                minute: date.minute,
                repeats: true,
              allowWhileIdle: true
            ),
            content: NotificationContent(
              //simple notification
              id: Random().nextInt(100),
              channelKey: _channelKey,
              //set configuration wuth key "basic"
              title: 'RIVA PSY',
              body: workManagerModel.pillName != ''
                  ? 'Приём'
                  : 'Как проходит день? Запиши, чтобы запомнить. Мы напоминаем для точной диагностики Вашего состояния',
              payload: _payload,
              wakeUpScreen: true,
              category: NotificationCategory.Reminder
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

    await AwesomeNotifications().initialize('resource://drawable/ic_launcher', [
      // notification icon
      NotificationChannel(
        channelGroupKey: 'reminders',
        channelKey: _channelKey,
        channelName: 'RIVA PSY',
        channelDescription: 'Notification channel for RIVA PSY',
        channelShowBadge: true,
        importance: NotificationImportance.High,
        enableVibration: true,
      ),
    ]);
  }

  Future canselAllSchedules () async {
    await AwesomeNotifications().cancelAllSchedules();
  }
}
