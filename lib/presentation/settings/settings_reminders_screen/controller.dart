import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import '../../../core/services/workmanager/workmanager_service.dart';
import '../../../core/user_data/user.dart';
import 'models/model.dart';
import 'models/notification_model.dart';

class K12Controller extends GetxController {

  final DateTime date = CurrentUser().registrationDate;

  void init() {
    if(CurrentUser.user.registrationDate.month != DateTime.now().month || CurrentUser.user.registrationDate.year != DateTime.now().year)
      if(list.length <= 4)
      list.insert(0, K12Model(0));
      notificationList!.value = [];
      for (int i = 0; i < CurrentUser.user.reminderTimeInStr.length; i++) {
        notificationList!.add(K12NotificationModel(
            hour: int.parse(CurrentUser.user.reminderTimeInStr[i][0] +
                CurrentUser.user.reminderTimeInStr[i][1]),
            minutes: int.parse(CurrentUser.user.reminderTimeInStr[i][3] +
                CurrentUser.user.reminderTimeInStr[i][4]),
            title: 'reminder_no_n'.tr(args: ['${i + 1}'])));
      }
      for (var value in list) {
        if (value.quantity == CurrentUser.user.reminderTime) {
          value.selected = true;
          break;
        }
      }
      if(CurrentUser.user.reminderTimeInStr.isEmpty)
      generateNewNotifications(
          CurrentUser.user.reminderTime!, notificationList ?? []);
    }

  Future updateData (int index, String time) async {
    CurrentUser.user.reminderTimeInStr[index] = time;
    await CurrentUser.repo.setLocalUserData(reminderTimeInStr: CurrentUser.user.reminderTimeInStr);
    await WorkManagerService().initService();

  }

  RxList<K12Model> list = [
    K12Model(1),
    K12Model(2),
    K12Model(3),
    K12Model(4),
  ].obs;

  RxList<K12NotificationModel>? notificationList = RxList<
      K12NotificationModel>();

  Future<List<K12NotificationModel>> generateNewNotifications(int quantity,
      List<K12NotificationModel> lastNotifications) async {

    if (quantity < lastNotifications.length) {
      while (lastNotifications.length != quantity) {
        lastNotifications.removeLast();
        CurrentUser.user.reminderTimeInStr.removeLast();
      }
    } else {
      while (lastNotifications.length != quantity) {
        var hour = Random().nextInt(20);
        var minutes = Random().nextInt(59);
        lastNotifications.add(K12NotificationModel(
            hour: hour,
            minutes: minutes,
            title: 'reminder_no_n'.tr(args: ['${lastNotifications.length + 1}'])));
        CurrentUser.user.reminderTimeInStr.add(hour.timeFormatted() + ':' + minutes.timeFormatted());
      }
    }
    await CurrentUser.repo.setLocalUserData(reminderTimeInStr: CurrentUser.user.reminderTimeInStr,reminderTime: quantity);
    await WorkManagerService().initService();

    return lastNotifications;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
