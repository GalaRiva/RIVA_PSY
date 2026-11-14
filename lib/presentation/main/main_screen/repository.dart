import 'dart:convert';

import '../../../core/db/hive_db.dart';
import '../../../core/models/emotional_state_model.dart';
import '../../../core/utils/image_constant.dart';

class K20Repo {

  final _eventTag = HiveDBTags.emotionalState;

  Future<List<EmotionalStateModel>> getEvent() async {
    var listToReturn = (await HiveDB.getBox(_eventTag)).map((e) =>
        EmotionalStateModel.fromJson(jsonDecode(e))).toList();
    if(listToReturn.isEmpty) {
      listToReturn = [];
    }
    return listToReturn;
  }

  Future<void> updateEvent(EmotionalStateModel event) async {
    // TODO: implement updateTasks
    final list = await getEvent();
    list.add(event);
    await HiveDB.deleteBox(_eventTag);
    for(var item in list) {
      // Awaited: a second save right after this one must not read a half-written box.
      await HiveDB.setBox(item.toJson(), _eventTag);
    }
  }
}

