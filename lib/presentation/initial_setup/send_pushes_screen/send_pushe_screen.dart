import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/initial_setup/pill_reminders/pill_reminders_screen.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_message_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notifications/flutter_local_notification_service.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../../widgets/custom_button.dart';

class SendPushesScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.darkBg,
      body: Container(
        decoration: AppDecoration.txt,
        child: Center(
          child: CustomMessageBox(
            canPop: false,
            title: 'Уведомления', content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: getHorizontalSize(305),
              child: Text('Разрешить приложению Rigel Psy  отправлять push-уведомления', style: AppStyle.txtSFProDisplayLight16,),)

              ,Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    height: getVerticalSize(
                      32,
                    ),
                    width: getHorizontalSize(
                      137,
                    ),
                    onTap: () async {

                      Navigator.pop(context);
                      if(SharedPrefs.sharedPreferences.getBool('pill_reminders') == null) {
                        showDialog(
                            context: context,
                            builder: (_) => PillRemindersScreen());
                      }
                    },
                    text: "нет".toUpperCase(),
                  ),
                  SizedBox(
                    width: getVerticalSize(10),
                  ),
                  CustomButton(
                    height: getVerticalSize(
                      32,
                    ),
                    width: getHorizontalSize(
                      137,
                    ),
                    onTap: () async {
                      AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
                        if (!isAllowed) {
                          // This is just a basic example. For real apps, you must show some
                          // friendly dialog box before call the request method.
                          // This is very important to not harm the user experience
                          AwesomeNotifications().requestPermissionToSendNotifications();
                        }
                      });

                      FirebaseMessaging.instance.requestPermission().then((value) {
                        FirebaseMessaging.onBackgroundMessage(_messageHandler);
                        FirebaseMessaging.instance.setAutoInitEnabled(true);
                        FirebaseMessaging.onMessage.listen((event) {
                          FlutterLocalNotificationService().showFlutterNotificationFromFirebase(event);
                        });

                      });
                      FirebaseMessaging.onBackgroundMessage(_messageHandler);
                      SharedPrefs.sharedPreferences.setBool('send_pushes', true);
                      Navigator.pop(context);
                      if(SharedPrefs.sharedPreferences.getBool('pill_reminders') == null) {
                          showDialog(        useSafeArea: false,

                              context: context,
                              builder: (_) => PillRemindersScreen());
                        }
                      },
                    text: "да".toUpperCase(),
                  ),
                ],
              )
            ],

          ),),
        ),
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}