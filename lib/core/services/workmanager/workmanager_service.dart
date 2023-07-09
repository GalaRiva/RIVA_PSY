import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:listenmebaby71_s_application17/core/services/notifications/flutter_local_notification_service.dart';
import 'package:listenmebaby71_s_application17/core/services/notifications/notification_service.dart';
import 'package:listenmebaby71_s_application17/core/user_data/user.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/repository.dart';
import 'package:workmanager/workmanager.dart';

import '../notifications/awesome_notification_service.dart';
import 'workmanager_model.dart';

class WorkManagerService {
  final workmanager = Workmanager();
  Future initService() async {
    workmanager.initialize(callbackDispatcher,
        isInDebugMode: false
    );
    // Periodic task registration
    await workmanager.cancelAll();

    List<Map<String, dynamic>> _time = [];
    _time += await _getReminders();
    _time += await _getRemindersAboutPills();

    final _now = DateTime.now();

    for(int i = 0; i < _time.length; i++) {
      final workmanagerModel = WorkManagerModel.fromJson(_time[i]);
      final date = DateTime(_now.year, _now.month, _now.day, workmanagerModel.hour, workmanagerModel.minute);
      print(workmanagerModel.hour.toString() + ' ' + workmanagerModel.minute.toString());
      final dur = Duration(hours: date.hour < _now.hour ? 24 -  (_now.hour - date.hour) : date.hour == _now.hour && date.minute < _now.minute ? 24 : date.hour - _now.hour, minutes: date.minute <= _now.minute ? 60 - (_now.minute - date.minute) : (date.minute - _now.minute) );

      print(dur);
      await workmanager.registerPeriodicTask(
          i.toString(),
          "simplePeriodicTask $i",
          frequency: Duration(hours: 24),
          initialDelay: dur,
        inputData: workmanagerModel.toJson()
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getReminders () async {
    final list = await CurrentUser.repo.getReminderTimeInStr();
    List<Map<String, dynamic>> time = list.map((e) => {
      'hour': int.parse(e[0]+e[1]),
      'minute': int.parse(e[3]+e[4]),
    }).toList();
    return time;
  }

  Future<List<Map<String, dynamic>>> _getRemindersAboutPills () async {
    final list = await PillsRepo().getEvent();
    List<Map<String, dynamic>> time = [];
    for (final item in list) {
      time += item.hoursOfTakingPills.map((e) => {
        'hour': int.parse(e[0]+e[1]),
        'minute': int.parse(e[3]+e[4]),
        'pillName': item.name
      }).toList();
    }
    return time;
  }
}



void callbackDispatcher() async{
  Workmanager().executeTask((task, inputData) async{

    final workmanagerModel = WorkManagerModel.fromJson(inputData!);

    final NotificationService notificationService = FlutterLocalNotificationService();
    await notificationService.showNotification(workmanagerModel);
    return Future.value(true);
  });
}



