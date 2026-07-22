import 'dart:convert';

import 'package:riva_psy/core/models/event_model.dart';

import '../../../../core/db/hive_db.dart';
import '../../../../core/utils/image_constant.dart';

class K26Repo {

  final _eventTag = HiveDBTags.persona;

  Future<List<EventModel>> getEvent() async {

    var listToReturn = (await HiveDB.getBox(_eventTag)).map((e) =>
        EventModel.fromJson(jsonDecode(e))).toList();
    if(listToReturn.isEmpty) {
      await updateEvent(standartEventList);
      listToReturn = standartEventList;
    }
    return listToReturn;
  }

  Future<void> updateEvent(List<EventModel> events) async {
    // TODO: implement updateTasks
    await HiveDB.deleteBox(_eventTag);
    List<EventModel> list = events.map((e) => EventModel(e.name, e.svgPath)).toList();
    for(var item in list) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  final standartEventList = <EventModel>[
    EventModel('я', ImageConstant.imgHome),
    EventModel('Мама', ImageConstant.imgMusicCyan70021x19),
    EventModel('Папа', ImageConstant.imgUserCyan70021x19),
    EventModel('Брат', ImageConstant.eventWho4),
    EventModel('Сестра', ImageConstant.eventWho5),
    EventModel('Друг', ImageConstant.imgTrash21x19),
    EventModel('Подруга', ImageConstant.imgMusic21x19),
    EventModel('Любимый человек', ImageConstant.imgGroupCyan70021x18),
    EventModel('Муж', ImageConstant.imgUser21x19),
    EventModel('Жена', ImageConstant.eventWho10),
    EventModel('Сын', ImageConstant.eventWho11),
    EventModel('Дочь', ImageConstant.imgUser1),
    EventModel('Бабушка', ImageConstant.eventWho13),
    EventModel('Дедушка', ImageConstant.eventWho14),
    EventModel('Тётя', ImageConstant.imgGroupCyan70021x20),
    EventModel('Дядя', ImageConstant.imgTrophyCyan700),
    EventModel('Близкий родственник', ImageConstant.imgGroup86),
    EventModel('Коллега', ImageConstant.eventColleague),
    EventModel('Одноклассник', ImageConstant.eventClassmate),
    EventModel('Знакомый', ImageConstant.eventFamiliar),
    EventModel('Прохожий', ImageConstant.imgAirplaneCyan70021x12),
    EventModel('Интернет друг', ImageConstant.eventInternetFriend),
    EventModel('Интернет человек', ImageConstant.eventInternetHuman),
    EventModel('Сотрудник организации', ImageConstant.eventEmployee),
    EventModel('Директор', ImageConstant.eventDirector),
    EventModel('Подчинёный', ImageConstant.eventSubordinate),
    EventModel('Домашнее животное', ImageConstant.eventPet),
    EventModel('Семья', ImageConstant.eventFamily),
  ];
}

