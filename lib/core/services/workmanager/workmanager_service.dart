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
    /*  workmanager.initialize(callbackDispatcher,
        isInDebugMode: true
    );
    // Periodic task registration
    await workmanager.cancelAll();*/
    final AwesomeNotificationService notificationService = AwesomeNotificationService();
    notificationService.canselAllSchedules();
    List<Map<String, dynamic>> _time = [];
    _time += await _getReminders();
    _time += await _getRemindersAboutPills();

    final _now = DateTime.now();
    for(int i = 0; i < _time.length; i++) {
      final workmanagerModel = WorkManagerModel.fromJson(_time[i]);
      final date = DateTime(_now.year, _now.month, _now.day, workmanagerModel.hour, workmanagerModel.minute);
      print(workmanagerModel.hour.toString() + ' ' + workmanagerModel.minute.toString());
      final dur = _getTimeRemaining(date);
      workmanagerModel.duration = dur;
      print('dur $dur');
      await notificationService.init(workmanagerModel);
      try {
        await notificationService.showNotification(workmanagerModel, dur);
      } catch (_) {

      }
      /*await workmanager.registerPeriodicTask(
          i.toString(),
          "simplePeriodicTask $i",
          frequency: Duration(hours: 24),
          initialDelay: dur,
        inputData: workmanagerModel.toJson()
      );*/
    }
  }

  Future<List<Map<String, dynamic>>> _getReminders () async {
    final list = await CurrentUser.repo.getReminderTimeInStr();
    List<Map<String, dynamic>> time = list.map((e) => {
      'hour': int.parse(e[0]+e[1]),
      'minute': int.parse(e[3]+e[4]),
      'end': DateTime.now().add(Duration(days: 30))
    }).toList();
    return time;
  }

  Future<List<Map<String, dynamic>>> _getRemindersAboutPills () async {
    final list = await PillsRepo().getEvent();
    List<Map<String, dynamic>> time = [];
    for (final item in list) {
      if(item.actual()) {

        time += item.hoursOfTakingPills
            .map((e) => {
                  'hour': int.parse(e[0] + e[1]),
                  'minute': int.parse(e[3] + e[4]),
                  'pillName': item.name,
                  'end': item.endDate
                })
            .toList();
      }
    }
    return time;
  }
}

Duration _getTimeRemaining(DateTime targetDateTime) {
  DateTime now = DateTime.now();
  if (now.isAfter(targetDateTime)) {
    final newDate = DateTime(targetDateTime.year, targetDateTime.month, targetDateTime.day + 1, targetDateTime.hour, targetDateTime.minute);
    return newDate.difference(now);
  }
  return targetDateTime.difference(now);
}