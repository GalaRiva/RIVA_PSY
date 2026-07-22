import 'dart:convert';

import 'package:riva_psy/core/models/event_model.dart';

import '../../../core/db/hive_db.dart';
import '../../../core/models/body_parts_model.dart';
import '../../../core/models/day_event_model.dart';
import '../../main/path/what_body_parts_screen/repository.dart';
import '../../main/path/what_emotion_screen/repository.dart';
import '../../main/path/what_happened_screen/repository.dart';
import '../../main/path/where_happened_screen/repository.dart';
import '../../main/path/with_who_happened_screen/repository.dart';
import '../records_screen/repository.dart';


class K52Repo {
  final _eventRepo = K22Repo();
  final _placeRepo = K25Repo();
  final _personaRepo = K26Repo();
  final _emotionRepo = K27Repo();
  final _bodyPartsRepo = K32Repo();
  final _dayEventRepo = K49Repo();

  final _emotionTag1 = HiveDBTags.emotions1;
  final _emotionTag2 = HiveDBTags.emotions2;
  final _emotionTag3 = HiveDBTags.emotions3;


  Future<dynamic> getEventByEnum(RepoEvent enumenator) async {
    switch (enumenator) {
      case RepoEvent.event:
        return _eventRepo.getEvent();
      case RepoEvent.place:
        return _placeRepo.getEvent();
      case RepoEvent.persona:
        return _personaRepo.getEvent();
      case RepoEvent.emotion1:
        final list = await _emotionRepo.getEvent(_emotionTag1);
        return list;
      case RepoEvent.bodyParts:
        return _bodyPartsRepo.getEvent();
      case RepoEvent.dayEvent:
        return _dayEventRepo.getEvent();
      case RepoEvent.emotion2:
        final list = await _emotionRepo.getEvent(_emotionTag2);
        return list;
      case RepoEvent.emotion3:
        final list =await _emotionRepo.getEvent(_emotionTag3);
        return list;
    }
  }

  Future<dynamic> updateEventByEnum(RepoEvent enumenator, {List<EventModel>? events, List<BodyPartsModel>? bodyParts, List<DayEventModel>? dayEvents}) async {
    switch (enumenator) {
      case RepoEvent.event:
        return _eventRepo.updateEvent(events!);
      case RepoEvent.place:
        return _placeRepo.updateEvent(events!);
      case RepoEvent.persona:
        return _personaRepo.updateEvent(events!);
      case RepoEvent.emotion1:
        return await _emotionRepo.updateEvent(events!, _emotionTag1);
      case RepoEvent.bodyParts:
        return _bodyPartsRepo.updateEvent(bodyParts!);
      case RepoEvent.dayEvent:
        await HiveDB.deleteBox(HiveDBTags.dayEvents);
        return await _dayEventRepo.updateEvent(dayEvents!);
      case RepoEvent.emotion2:
        return await _emotionRepo.updateEvent(events!, _emotionTag2);
      case RepoEvent.emotion3:
        return await _emotionRepo.updateEvent(events!, _emotionTag3);
    }
  }
}

enum RepoEvent { event, place, persona, emotion1, emotion2, emotion3,  bodyParts, dayEvent }
