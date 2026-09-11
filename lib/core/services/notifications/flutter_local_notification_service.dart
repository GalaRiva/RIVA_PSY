import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FlutterLocalNotificationService {
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
        channelDescription: 'RIVA PSY notification',
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
}
