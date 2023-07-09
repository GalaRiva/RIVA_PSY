/*

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/services/notifications/notification_service.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';

import '../../../routes/app_routes.dart';
import '../workmanager/workmanager_model.dart';

class AwesomeNotificationService extends NotificationService {
  @override
  Future showNotification(WorkManagerModel workManagerModel) async {
    AwesomeNotifications().initialize(
        '@mipmap/ic_launcher',
        [            // notification icon
          NotificationChannel(
            channelGroupKey: 'group_key',
            channelKey: 'channel_key',
            channelName: 'Rigel PSY',
            channelDescription: 'Notification channel for Rigel PSY',
            channelShowBadge: true,
            importance: NotificationImportance.High,
            enableVibration: true,
          ),

        ]
    );

    AwesomeNotifications().createNotification(
        content: NotificationContent( //simgple notification
          id: 1,
          channelKey: 'channel_key', //set configuration wuth key "basic"
          title: 'Rigel PSY',
          body: workManagerModel.pillName != '' ? 'Приём' : 'Как проходит день? Запиши, чтобы запомнить. Мы напоминаем для точной диагностики Вашего состояния',
          payload: {"name":"Rigel PSY",
                  "pill": workManagerModel.pillName ?? '',
                  "time": '${workManagerModel.hour}:${workManagerModel.minute.timeFormatted()}'
          },
          autoDismissible: false,
        ),

        actionButtons: workManagerModel.pillName != '' ? [
          NotificationActionButton(
            key: "open",
            label: "Открыть",
          ),
        ] : null


    );


  }

  void notificationActionStream (BuildContext context) {

  }


}*/
