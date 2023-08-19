import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/db/hive_db.dart';
import 'models/pill_model.dart';

class PillsRepo {

  static const _eventTag = HiveDBTags.pills;

  Future<List<PillModel>> getEvent() async {
    var listToReturn = (await HiveDB.getBox(_eventTag))
        .map((e) => PillModel.fromJson(jsonDecode(e)))
        .toList();
    if(listToReturn.isEmpty) return [];
    return listToReturn;
  }

  Future<void> updateEvent(List<PillModel> events) async {
    // TODO: implement updateTasks
    await HiveDB.openBox(_eventTag);
    await HiveDB.deleteBox(_eventTag);
    for (var item in events) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  Future<bool> scheduleIsCreated () async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('scheduleIsCreated') ?? false;
}

  Future setSchedule (bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('scheduleIsCreated', val);
  }
}