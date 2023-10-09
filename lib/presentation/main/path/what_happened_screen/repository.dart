import 'dart:convert';

import 'package:listenmebaby71_s_application17/core/models/event_model.dart';

import '../../../../core/db/hive_db.dart';
import '../../../../core/utils/image_constant.dart';

class K22Repo {

  final _eventTag = HiveDBTags.events;

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
    EventModel('Отдых', ImageConstant.imgBag),
    EventModel('Сон', ImageConstant.eventSleep),
    EventModel('Пробуждение', ImageConstant.imgClockCyan700),
    EventModel('Спорт', ImageConstant.eventSport),
    EventModel('Чтение', ImageConstant.eventReading),
    EventModel('Покупки', ImageConstant.eventCard),
    EventModel('Компьютерная\nигра видеоигра', ImageConstant.eventComputerGame),
    EventModel('Просмотр\nфильма, сериала', ImageConstant.eventFilms),
    EventModel('Знакомство', ImageConstant.eventMeeting),
    EventModel('Общение', ImageConstant.eventTalking),
    EventModel('Прогулка', ImageConstant.eventWalking),
    EventModel('Выступление', ImageConstant.eventPerformance),
    EventModel('Экзамен', ImageConstant.eventExams),
    EventModel('Тест', ImageConstant.eventTest),
    EventModel('Уборка', ImageConstant.eventCleaning),
    EventModel('Готовка', ImageConstant.eventCooking),
    EventModel('Неожиданная\nвстреча', ImageConstant.eventMeeting2),
    EventModel('Ожидание\nчеловека', ImageConstant.eventWaiting),
    EventModel('Собрание', ImageConstant.eventCollection),
    EventModel('Деловая\nвстреча', ImageConstant.eventBusinessMeet),
    EventModel('Засыпание', ImageConstant.eventFallingAsleep),
    EventModel('Кошмарный\nсон', ImageConstant.eventNightmarish),
    EventModel('Ночные\nпробуждения', ImageConstant.eventAwakening),
    EventModel('Бессоница', ImageConstant.eventInsomnia),
    EventModel('Опоздание', ImageConstant.eventDelay),
    EventModel('Просмотр\nновостей', ImageConstant.eventViewing),
    EventModel('Общение \nв интернете', ImageConstant.eventInInternet),
    EventModel('Алкогольное\n опьянение', ImageConstant.eventIntoxication),
    EventModel('Похмелье', ImageConstant.eventHangover),
    EventModel('Недосып', ImageConstant.eventLackOfSleep),
    EventModel('Уход за собой', ImageConstant.eventGoOut),
    EventModel('Секс', ImageConstant.eventSex),
    EventModel('Игнорирование\nвас', ImageConstant.eventUpcoming),
    EventModel('Предстоящий\nразговор', ImageConstant.eventRescheduled),
    EventModel('Ожидание\nвстречи', ImageConstant.eventWaitingCollection),
    EventModel('Перенесли\nвстречу', ImageConstant.eventRescheduled),
    EventModel('Поездка на\nработу', ImageConstant.eventTrip),
    EventModel('Поездка в\nшколу', ImageConstant.eventInSchool),
    EventModel('Ссора', ImageConstant.eventQuarrel),
    EventModel('Приход гостей', ImageConstant.eventComing),
    EventModel('Потеря вещи', ImageConstant.eventLoss),
    EventModel('Подготовка\nк событию', ImageConstant.eventPreparation),
    EventModel('Обман', ImageConstant.eventLie),
    EventModel('Болезнь', ImageConstant.eventHangover),
    EventModel('Хобби', ImageConstant.eventHobby),
    EventModel('Танец', ImageConstant.eventDance),
    EventModel('Музыка', ImageConstant.eventMusic),
  ];
}

