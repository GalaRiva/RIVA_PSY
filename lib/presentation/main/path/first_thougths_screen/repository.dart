import 'dart:convert';

import '../../../../core/db/hive_db.dart';
import '../../../../core/models/day_event_model.dart';

class K38Repo {
  static const _eventTag = HiveDBTags.dayEvents;
  static const _eventTag2 = HiveDBTags.notCompleteDayEvents;

  Future<List<DayEventModel>> getEvent() async {
    List<DayEventModel> listToReturn = [];
    try {
      listToReturn = (await HiveDB.getBox(_eventTag))
          .map((e) => DayEventModel.fromJson(jsonDecode(e)))
          .toList();
    } catch (_) {

    }
    if(listToReturn.isEmpty) {
      listToReturn = [];
    }
    return listToReturn;
  }

  Future<void> updateEvent(List<DayEventModel> events) async {
    // TODO: implement updateTasks
    await HiveDB.deleteBox(_eventTag);
    events.sort((d1,d2) => d1.compareTo(d2));
    for (var item in events) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  Future<void> updateNotCompleteDaysEvent(List<DayEventModel> events) async {
    // TODO: implement updateTasks

    await HiveDB.deleteBox(_eventTag2);
    for(var item in events)
      HiveDB.setBox(item.toJson(), _eventTag2);

  }

  Future<List<DayEventModel>> getNotCompleteEvent() async {
    List<DayEventModel> listToReturn = [];
    try {
      listToReturn = (await HiveDB.getBox(_eventTag2))
          .map((e) => DayEventModel.fromJson(jsonDecode(e)))
          .toList();
    } catch (_) {

    }
    if(listToReturn.isEmpty) {
      listToReturn = [];
    }
    return listToReturn;
  }


}
