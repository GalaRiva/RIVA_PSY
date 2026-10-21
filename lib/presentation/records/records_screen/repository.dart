import 'dart:convert';

import '../../initial_setup/onboarding/onboarding_concern.dart';
import '../../../core/db/hive_db.dart';
import '../../../core/models/day_event_model.dart';

class K49Repo {
  static const _eventTag = HiveDBTags.dayEvents;

  Future<List<DayEventModel>> getEvent() async {
    var listToReturn = (await HiveDB.getBox(_eventTag))
        .map((e) => DayEventModel.fromJson(jsonDecode(e)))
        .toList();
    if(listToReturn.isEmpty) {
      listToReturn = [];
    }
    return listToReturn;
  }

  Future<void> updateEvent(List<DayEventModel> events) async {
    // TODO: implement updateTasks
    await HiveDB.openBox(_eventTag);
    await HiveDB.deleteBox(_eventTag);
    events.sort((d1,d2) => d1.compareTo(d2));
    for (var item in events) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
    OnboardingPrefs.changes.value++; // first-steps checklist re-reads
  }
}
