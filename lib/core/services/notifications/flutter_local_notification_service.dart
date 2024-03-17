import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:listenmebaby71_s_application17/core/services/notifications/notification_service.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/models/pill_model.dart';

import '../workmanager/workmanager_model.dart';

class FlutterLocalNotificationService extends NotificationService{

  void showFlutterNotificationFromFirebase(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    FlutterLocalNotificationsPlugin flip =  FlutterLocalNotificationsPlugin();
    bool? can = true;
    can = Platform.isAndroid ? await flip
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission() : await flip
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (!(can ?? true)) return;
    var android =  const AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS =  const DarwinInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings =  InitializationSettings(android: android,iOS: IOS);
    flip.initialize(settings,);
    if (notification != null && !kIsWeb) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1',
       'notification',
        channelDescription: 'Rigel PSY notification',
        playSound: true,
        importance: Importance.max,
        priority: Priority.high,

      );
      var iOSPlatformChannelSpecifics = DarwinNotificationDetails(
          sound: null,
          presentSound: true,
          presentAlert: true
      );
      var platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: iOSPlatformChannelSpecifics
      );

      flip.show(
          0,
          notification.title,
          notification.body,
          platformChannelSpecifics,
          payload: jsonEncode(message.data)
      );
    }
  }

  @override
  Future showNotification(WorkManagerModel workManagerModel, Duration dur) async{
    FlutterLocalNotificationsPlugin flip = new FlutterLocalNotificationsPlugin();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var IOS = new DarwinInitializationSettings();

    // initialise settings for both Android and iOS device.
    var settings = new InitializationSettings(android: android,iOS: IOS);
    flip.initialize(settings);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id',
        'your channel name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high
    );
    var iOSPlatformChannelSpecifics = DarwinNotificationDetails();




    // initialise channel platform for both Android and iOS device.
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics
    );

    await flip.show(0, 'Rigel Psy',
      workManagerModel.pillName != '' ? 'Приём' : 'Как проходит день? Запиши, чтобы запомнить. Мы напоминаем для точной диагностики Вашего состояния',
      platformChannelSpecifics, payload: 'Default_Sound',
    );
  }

  @override
  void navigator(BuildContext context, Function otherNavigationFunc) {
    // TODO: implement notificationActionStream
  }


}