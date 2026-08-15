import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/models/day_event_model.dart';

import '../../../../core/models/insight_model.dart';
import '../../../../core/services/insights/insight_engine.dart';
import '../../../../core/services/milestones/milestone_service.dart';
import '../../../../routes/app_routes.dart';
import '../add_emotion_screen/controller.dart';
import '../additional_emotions_screen/controller.dart';
import '../../../charts/charts_screen/controller.dart';
import '../../../records/records_screen/controller.dart';
import '../what_body_parts_screen/controller.dart';
import '../what_emotion_screen/controller.dart';
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
      InsightEngine().run().catchError((_) => <InsightModel>[]);
      await MilestoneService.maybeCelebrate(context, dayEventModel);
    } catch (_) {}

    // The "record saved" confirmation dialog that used to sit here was
    // redundant — the very next screen is the emotion-processing Path
    // itself, which already reads as continuation/confirmation.
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.path_final, (route) => false, arguments: dayEventModel);
    _deleteControllers();
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
