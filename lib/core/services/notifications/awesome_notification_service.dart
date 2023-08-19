import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/services/notifications/notification_service.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';

import '../../../presentation/charts/concrete_pill/concrete_pill_screen.dart';
import '../../../routes/app_routes.dart';
import '../workmanager/workmanager_model.dart';
import 'notification_controller.dart';

class AwesomeNotificationService extends NotificationService {
  @override
  Future showNotification(WorkManagerModel workManagerModel, Duration dur,) async {
    final _channelKey =
        workManagerModel.pillName != '' ? 'open' : 'channel_key';

    final Map<String, String>? _payload = {
      "name": "Rigel PSY",
      "pill": workManagerModel.pillName ?? '',
      "time":
          '${workManagerModel.hour}:${workManagerModel.minute.timeFormatted()}'
    };
    final now = DateTime.now();
    int length = now.difference(workManagerModel.end).inDays;
    if(now.isAfter(workManagerModel.end)) length = 0;
    for(int i = 0; i < length; i++) {
      final date = DateTime(now.year, now.month, now.day + i, now.hour, now.minute, now.second).add(dur);
      await AwesomeNotifications().createNotification(
          schedule: NotificationCalendar.fromDate(
              date: date, repeats: true, allowWhileIdle: true),
          content: NotificationContent(
            //simgple notification
            id: 1,
            channelKey: _channelKey,
            //set configuration wuth key "basic"
            title: 'Rigel PSY',
            body: workManagerModel.pillName != ''
                ? 'Приём'
                : 'Как проходит день? Запиши, чтобы запомнить. Мы напоминаем для точной диагностики Вашего состояния',
            payload: _payload,
          ),
          actionButtons: workManagerModel.pillName != ''
              ? [
            NotificationActionButton(
              key: "open",
              label: "Открыть 💊",
            ),
          ]
              : null);
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
    final _channelKey =
    workManagerModel.pillName != '' ? 'open' : 'channel_key';

    await AwesomeNotifications().initialize('resource://drawable/ic_launcher', [
      // notification icon
      NotificationChannel(
        channelKey: _channelKey,
        channelName: 'Rigel PSY',
        channelDescription: 'Notification channel for Rigel PSY',
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
