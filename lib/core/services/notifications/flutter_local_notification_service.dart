import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:listenmebaby71_s_application17/core/services/notifications/notification_service.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/models/pill_model.dart';

import '../workmanager/workmanager_model.dart';

class FlutterLocalNotificationService extends NotificationService{
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