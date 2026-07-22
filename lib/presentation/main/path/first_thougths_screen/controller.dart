import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/utils/date_extension.dart';

import '../../../../core/db/hive_db.dart';
import '../../../../routes/app_routes.dart';
import '../../../../widgets/custom_message_box.dart';
import '../add_emotion_screen/controller.dart';
import '../additional_emotions_screen/controller.dart';
import '../../../charts/charts_screen/controller.dart';
import '../../../records/records_screen/controller.dart';
import '../what_body_parts_screen/controller.dart';
import '../what_emotion_screen/controller.dart';
import '../what_emotion_screen/repository.dart';
import '../what_happened_screen/controller.dart';
import '../where_happened_screen/controller.dart';
import '../with_who_happened_screen/controller.dart';
import 'repository.dart';

class K38Controller extends GetxController {

  final _repo = K38Repo();
  void createNewDayEvent (DayEventModel dayEventModel, BuildContext context) async {
    try {
      final events = await _repo.getEvent();
      events.add(dayEventModel);
      await _repo.updateEvent(events);
    } catch (_) {}

    showDialog(context: context, builder: (BuildContext context) =>
      CustomMessageBox(
        onPop: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.path_final, arguments: dayEventModel);
          _deleteControllers();

        },
        title: 'Создана запись',
        content:
        'Запись ${DateTime.now().day} ${DateTime.now().month.monthInText()} ${DateTime.now().year} г ${DateTime.now().hour.timeFormatted()}:${DateTime.now().minute.timeFormatted()} сохранена',
      ),
    ).then((value) async {

          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.path_final, (route) => false, arguments: dayEventModel);

      _deleteControllers();
    });
  }

  void _deleteControllers (){
    Get.delete<K22Controller>();
    Get.delete<K24Controller>();
    Get.delete<K25Controller>();
    Get.delete<K26Controller>();
    Get.delete<K27Controller>();
    Get.delete<K31Controller>();
    Get.delete<K32Controller>();
    Get.delete<K38Controller>();
    Get.delete<K49Controller>();
    Get.delete<K61Controller>();
  }
}
