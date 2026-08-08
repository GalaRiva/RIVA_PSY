import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/initial_setup/pill_reminders/pill_reminders_screen.dart';
import 'package:riva_psy/widgets/custom_message_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notifications/flutter_local_notification_service.dart';
import '../../../core/utils/shared_prefs.dart';
import '../../../widgets/custom_button.dart';
import '../../../theme/app_colors.dart';

class SendPushesScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: AppDecoration.txt,
        child: Center(
          child: CustomMessageBox(
            canPop: false,
            title: 'notifications'.tr(), content: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(width: getHorizontalSize(305),
              child: Text('allow_for_app'.tr(), style: AppStyle.txtSFProDisplayLight16,),)

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
                      SharedPrefs.sharedPreferences.setBool('send_pushes', true);
                      Navigator.pop(context);
                    },
                    text: 'no'.tr().toUpperCase(),
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
                          // The package's default permission list (Alert,
                          // Sound, Badge, Vibration, Light) does NOT include
                          // PreciseAlarms — without it, Android 12+ can
                          // silently downgrade every scheduled reminder to
                          // an inexact alarm, which is exactly why Pills
                          // and diary reminders kept not firing even after
                          // the cancelAllSchedules() race was fixed and
                          // POST_NOTIFICATIONS was declared. Requesting it
                          // explicitly here is what actually triggers
                          // Android's "Alarms & reminders" settings prompt.
                          AwesomeNotifications().requestPermissionToSendNotifications(
                            permissions: [
                              NotificationPermission.Alert,
                              NotificationPermission.Sound,
                              NotificationPermission.Badge,
                              NotificationPermission.Vibration,
                              NotificationPermission.Light,
                              NotificationPermission.PreciseAlarms,
                            ],
                          );
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
                    text: 'yes'.tr().toUpperCase(),
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