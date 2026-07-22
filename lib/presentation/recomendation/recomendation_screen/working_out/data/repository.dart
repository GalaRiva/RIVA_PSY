import 'dart:convert';

import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/models/spent_record_model.dart';

import '../../../../../core/db/hive_db.dart';
import '../../../../../core/models/day_event_model.dart';

class WorkingOutRepo {
  static const _eventTag = HiveDBTags.spentRecords;

  Future<List<SpentRecordModel>> getEvent() async {
    var listToReturn = (await HiveDB.getBox(_eventTag))
        .map((e) => SpentRecordModel.fromJson(jsonDecode(e)))
        .toList();
    return listToReturn;
  }

  Future<void> updateEvent(List<SpentRecordModel> events) async {
    // TODO: implement updateTasks
    await HiveDB.openBox(_eventTag);
    await HiveDB.deleteBox(_eventTag);
    events.sort((d1,d2) => d1.compareTo(d2));
    for (var item in events) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  Future<List<DayEventModel>> getDayEvent() async {
    var listToReturn = (await HiveDB.getBox(HiveDBTags.dayEvents))
        .map((e) => DayEventModel.fromJson(jsonDecode(e)))
        .toList();
    return listToReturn;
  }

  Future<void> updateDayEventEvent(List<DayEventModel> events) async {
    // TODO: implement updateTasks
    await HiveDB.openBox(HiveDBTags.dayEvents);
    await HiveDB.deleteBox(HiveDBTags.dayEvents);
    events.sort((d1,d2) => d1.compareTo(d2));
    for (var item in events) {
      HiveDB.setBox(item.toJson(), HiveDBTags.dayEvents);
    }
  }
}
