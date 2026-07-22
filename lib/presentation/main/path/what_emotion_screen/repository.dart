import 'dart:convert';

import 'package:riva_psy/core/models/event_model.dart';

import '../../../../core/db/hive_db.dart';
import '../../../../core/utils/image_constant.dart';

class K27Repo {

  static const _eventTag1 = HiveDBTags.emotions1;
  static const _eventTag2 = HiveDBTags.emotions2;
  static const _eventTag3 = HiveDBTags.emotions3;

  String getTag (int number) {
    switch(number) {
      case 1:
        return _eventTag1;
      case 2:
        return _eventTag2;
      default:
        return _eventTag3;
    }
  }

  Future<List<EventModel>> getEvent(String tag) async {
    var listToReturn = (await HiveDB.getBox(tag)).map((e) =>
        EventModel.fromJson(jsonDecode(e))).toList();
    if(listToReturn.isEmpty) {
      switch (tag){
        case _eventTag1:
          await updateEvent(standardEventListOne, tag);
          listToReturn = standardEventListOne;
          break;
        case _eventTag2:
          await updateEvent(standardEventListTwo, tag);
          listToReturn = standardEventListTwo;
          break;
        default:
          await updateEvent(standardEventListThree, tag);
          listToReturn = standardEventListThree;
          break;
      }
    }
    return listToReturn;
  }

  Future<void> updateEvent(List<EventModel> events, String tag) async {
    // TODO: implement updateTasks
    await HiveDB.deleteBox(tag);
    List<EventModel> list = events.map((e) => EventModel(e.name, e.svgPath)).toList();
    for(var item in list) {
      HiveDB.setBox(item.toJson(), tag);
    }
  }

  final standardEventListOne = <EventModel>[
    EventModel('Гнев (ярость)', ImageConstant.eventEmotion1_1),
    EventModel('Ненависть', ImageConstant.img047mad),
    EventModel('Злость', ImageConstant.imgClockCyan70020x20),
    EventModel('Раздражение', ImageConstant.imgTwitter),
    EventModel('Презрение', ImageConstant.imgTrophyCyan70021x21),
    EventModel('Негодование', ImageConstant.img013annoyance),
    EventModel('Обида', ImageConstant.imgTrophy21x21),
    EventModel('Ревность', ImageConstant.imgCarCyan700),
    EventModel('Уязвленность', ImageConstant.imgClockCyan70021x21),
    EventModel('Досада', ImageConstant.imgUserCyan70021x22),
    EventModel('Зависть', ImageConstant.imgClock21x21),
    EventModel('Неприязнь', ImageConstant.imgCarCyan70021x22),
    EventModel('Возмущение', ImageConstant.imgTrophyCyan70021x19),
    EventModel('Отвращение', ImageConstant.imgAlarm),
    EventModel('Страх', ImageConstant.imgAlarmCyan700),
    EventModel('Ужас', ImageConstant.img016surprised),
    EventModel('Отчаяние', ImageConstant.imgAirplaneCyan70021x22),
    EventModel('Испуг', ImageConstant.imgClockCyan70022x20),
    EventModel('Подозрение', ImageConstant.imgMusicCyan70021x22),
    EventModel('Тревога', ImageConstant.imgTrophy1),
    EventModel('Беспокойство', ImageConstant.imgTrash1),
    EventModel('Горечь', ImageConstant.imgTelevision),
    EventModel('Унижение', ImageConstant.imgTrashCyan70022x22),
    EventModel('Печаль', ImageConstant.img005crying),
    EventModel('Вина', ImageConstant.imgMusicCyan70021x21),
    EventModel('Стыд', ImageConstant.imgTrophy2),
    EventModel('Застенчивость', ImageConstant.imgTrophy3),
    EventModel('Опасение', ImageConstant.imgClock1),
    EventModel('Грусть', ImageConstant.img033sad),
    EventModel('Тоска', ImageConstant.imgTrashCyan70021x21),
    EventModel('Скорбь', ImageConstant.imgTrash21x21),
    EventModel('Лень', ImageConstant.imgClock2),
    EventModel('Жалость', ImageConstant.imgTrophyCyan70030x26),
    EventModel('Взвинченность', ImageConstant.imgAlarmCyan70030x31),
    EventModel('Беспомощность', ImageConstant.imgTrophyCyan70030x30),
    EventModel('Разочарование', ImageConstant.imgTrophy30x30),
    EventModel('Сожаление', ImageConstant.imgTrash2),
    EventModel('Неуверенность', ImageConstant.img046speechless),
    EventModel('Апатия', ImageConstant.img013amazed),
    EventModel('Одиночество', ImageConstant.img045sad),
    EventModel('Покинутость', ImageConstant.imgTrophy4),
    EventModel('Потерянность', ImageConstant.imgTrophy21x19),
    EventModel('Уныние', ImageConstant.imgTrophy5),
    EventModel('Суета', ImageConstant.imgTrophy6),
    EventModel('Бессилие', ImageConstant.img033sad),
    EventModel('Смятение', ImageConstant.imgCarCyan70030x30),
    EventModel('Меланхолия', ImageConstant.imgAlarm30x31),
    EventModel('Ненужность', ImageConstant.img009worried),
    EventModel('Обреченность', ImageConstant.imgLocationCyan700),
    EventModel('Отрешенность', ImageConstant.imgLightbulbCyan70021x21),
    EventModel('Прострация', ImageConstant.img013amazed),
    EventModel('Ожесточенность', ImageConstant.imgUserCyan70030x28),
    EventModel('Огорчение', ImageConstant.imgTrophy7),
    EventModel('Недоумение', ImageConstant.img042meh),
    EventModel('Обескураженность', ImageConstant.imgCarCyan70031x31),
    EventModel('Раскаяние', ImageConstant.imgCar30x30),
    EventModel('Растерянность', ImageConstant.imgTrash2),
    EventModel('Недоверие', ImageConstant.imgCar1),
    EventModel('Стыд', ImageConstant.img023regret),
    EventModel('Отторжение', ImageConstant.imgMegaphoneCyan700),
    EventModel('Замешательство', ImageConstant.imgAlarmCyan70030x30),
  ];

  final standardEventListTwo = <EventModel>[
    EventModel('Радость', ImageConstant.img001happy),
    EventModel('Счастье', ImageConstant.imgClockCyan70021x19),
    EventModel('Восторг', ImageConstant.imgMusic21x21),
    EventModel('Ликование', ImageConstant.imgTicket),
    EventModel('Приподнятость', ImageConstant.imgTrophy8),
    EventModel('Оживление', ImageConstant.imgFolder),
    EventModel('Умиротворение', ImageConstant.imgTrophy9),
    EventModel('Интерес', ImageConstant.img030silly),
    EventModel('Забота', ImageConstant.imgSave),
    EventModel('Ожидание', ImageConstant.imgMusic2),
    EventModel('Возбуждение', ImageConstant.eventEmotion2_11),
    EventModel('Предвкушение', ImageConstant.imgClock21x19),
    EventModel('Надежда', ImageConstant.imgTrophy10),
    EventModel('Благодарность', ImageConstant.imgTrophy11),
    EventModel('Освобождение', ImageConstant.imgClock3),
    EventModel('Приятие', ImageConstant.imgClock4),
    EventModel('Принятие', ImageConstant.imgLocationCyan70021x21),
    EventModel('Вера', ImageConstant.imgCartCyan70021x19),
    EventModel('Любовь', ImageConstant.imgAlarmCyan70030x28),
    EventModel('Надежность', ImageConstant.img037ill),
    EventModel('Доверие', ImageConstant.imgTrophy12),
    EventModel('Спокойствие', ImageConstant.imgTwitterCyan700),
    EventModel('Симпатия', ImageConstant.imgMusic3),
    EventModel('Идентичность', ImageConstant.imgClockCyan70021x22),
    EventModel('Гордость', ImageConstant.imgAirplaneCyan70021x21),
    EventModel('Восхищение', ImageConstant.imgCartCyan70021x21),
    EventModel('Уважение', ImageConstant.imgTrophyCyan70030x28),
    EventModel('Самоценность', ImageConstant.img024sleeping),
    EventModel('Влюбленность', ImageConstant.imgTrophyCyan70030x27),
    EventModel('Любовь к себе', ImageConstant.imgTrophy13),
    EventModel('Очарованность', ImageConstant.imgTrophy14),
    EventModel('Смирение', ImageConstant.imgClock5),
    EventModel('Дружелюбие', ImageConstant.imgCarCyan70021x21),
    EventModel('Доброта', ImageConstant.img005laugh),
    EventModel('Гармония', ImageConstant.imgMusic4),
    EventModel('Блаженство', ImageConstant.img050wink),
    EventModel('Эйфория', ImageConstant.imgCarCyan70030x28),
    EventModel('Воодушевление', ImageConstant.imgTrophy15),
    EventModel('Бодрость', ImageConstant.imgClock6),
    EventModel('Наслаждение', ImageConstant.imgMusic21x22),
    EventModel('Вдохновение', ImageConstant.imgInstagram),
    EventModel('Энтузиазм', ImageConstant.imgMusic5),
    EventModel('Задор', ImageConstant.imgMusic6),
    EventModel('Умиление', ImageConstant.imgClock7),
    EventModel('Благоговение', ImageConstant.imgAlarmCyan70021x21),
    EventModel('Признательность', ImageConstant.img008happy),
    EventModel('Патриотизм', ImageConstant.imgMegaphoneCyan70021x21),
  ];

  final standardEventListThree = <EventModel>[
    EventModel('Сомнение +', ImageConstant.imgBagCyan700),
    EventModel('Удивление +', ImageConstant.imgUserCyan70030x27),
    EventModel('Сомнение -', ImageConstant.imgBagCyan700),
    EventModel('Удивление -', ImageConstant.imgUserCyan70030x27),
    EventModel('Равнодушие +', ImageConstant.imgFloatingicon),
    EventModel('Азарт +', ImageConstant.imgTwitterCyan70021x21),
    EventModel('Равнодушие -', ImageConstant.imgFloatingicon),
    EventModel('Азарт -', ImageConstant.imgTwitterCyan70021x21),
    EventModel('Упоение +', ImageConstant.imgTrophy10),
    EventModel('Ажиотаж +', ImageConstant.imgTrophy16),
    EventModel('Упоение -', ImageConstant.imgTrophy10),
    EventModel('Ажиотаж -', ImageConstant.imgTrophy16),
    EventModel('Взволнованность +', ImageConstant.imgFileCyan700),
    EventModel('Волнение +', ImageConstant.imgTrophy18),
    EventModel('Взволнованность -', ImageConstant.imgFileCyan700),
    EventModel('Волнение -', ImageConstant.imgTrophy18),
    EventModel('Нетерпение +', ImageConstant.img050dizzy),
    EventModel('Ностальгия +', ImageConstant.imgTrash4),
    EventModel('Нетерпение -', ImageConstant.img050dizzy),
    EventModel('Ностальгия -', ImageConstant.imgTrash4),
    EventModel('Любопытсво +', ImageConstant.imgAlarm21x21),
    EventModel('Смущение +', ImageConstant.img005laugh),
    EventModel('Любопытсво -', ImageConstant.imgAlarm21x21),
    EventModel('Смущение -', ImageConstant.img005laugh),
    EventModel('Обожание +', ImageConstant.imgSettings21x21),
    EventModel('Сострадание +', ImageConstant.imgCutCyan70021x19),
    EventModel('Обожание -', ImageConstant.imgSettings21x21),
    EventModel('Сострадание -', ImageConstant.imgCutCyan70021x19),
    EventModel('Сопричастность +', ImageConstant.imgCutCyan70034x34),
    EventModel('Сочувствие +', ImageConstant.imgClock21x22),
    EventModel('Сопричастность -', ImageConstant.imgCutCyan70034x34),
    EventModel('Сочувствие -', ImageConstant.imgClock21x22),
  ];
}

