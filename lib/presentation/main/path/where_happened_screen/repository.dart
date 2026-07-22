import 'dart:convert';

import 'package:riva_psy/core/models/event_model.dart';

import '../../../../core/db/hive_db.dart';
import '../../../../core/utils/image_constant.dart';

class K25Repo {

  final _eventTag = HiveDBTags.place;

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
    EventModel('Дом', ImageConstant.imgHome),
    EventModel('Общественный траспорт', ImageConstant.eventWhere2),
    EventModel('Самолёт', ImageConstant.imgAirplaneCyan70023x25),
    EventModel('Машина', ImageConstant.imgCar),
    EventModel('Школа', ImageConstant.eventWhere5),
    EventModel('Университет', ImageConstant.eventWhere6),
    EventModel('Работа', ImageConstant.imgUser23x18),
    EventModel('Кино', ImageConstant.imgCalendarCyan700),
    EventModel('Кафе', ImageConstant.imgClockCyan70019x21),
    EventModel('Ресторан', ImageConstant.imgCamera),
    EventModel('Улица', ImageConstant.eventWhere11),
    EventModel('Парк', ImageConstant.imgGroupCyan70017x22),
    EventModel('Остановка', ImageConstant.eventWhere13),
    EventModel('Интернет', ImageConstant.eventWhere14),
    EventModel('Соц сети', ImageConstant.imgUserCyan70021x14),
    EventModel('Магазин', ImageConstant.imgTrashCyan70019x20),
    EventModel('Торговый центр', ImageConstant.eventWhere17),
    EventModel('Лифт', ImageConstant.imgClockCyan70019x22),
    EventModel('Общественное мероприятие', ImageConstant.eventWhere19),
    EventModel('Спортзал', ImageConstant.eventWhere20),
    EventModel('Клуб', ImageConstant.imgHomeCyan700),
    EventModel('Сервис', ImageConstant.imgUserCyan70024x27),
    EventModel('Салон красоты', ImageConstant.eventWhere23),
    EventModel('Музей', ImageConstant.eventWhere24),
    EventModel('Театр', ImageConstant.eventWhere25),
    EventModel('В гостях', ImageConstant.eventWhere26),
    EventModel('На даче', ImageConstant.imgHomeCyan70021x24),
    EventModel('Больница', ImageConstant.imgVideocamera17x17),
    EventModel('Клиника', ImageConstant.eventWhere29),
    EventModel('Общественное учереждение', ImageConstant.imgComputerCyan700),
  ];
}

