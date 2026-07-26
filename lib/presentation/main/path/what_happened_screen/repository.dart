import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:riva_psy/core/models/event_model.dart';

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
    List<EventModel> list = events.map((e) => EventModel(e.name, e.svgPath, e.key)).toList();
    for(var item in list) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  final standartEventList = <EventModel>[
    EventModel('rest'.tr(), ImageConstant.imgBag, 'rest'),
    EventModel('sleep'.tr(), ImageConstant.eventSleep, 'sleep'),
    EventModel('waking_up'.tr(), ImageConstant.imgClockCyan700, 'waking_up'),
    EventModel('sports'.tr(), ImageConstant.eventSport, 'sports'),
    EventModel('reading'.tr(), ImageConstant.eventReading, 'reading'),
    EventModel('shopping'.tr(), ImageConstant.eventCard, 'shopping'),
    EventModel('playing_video_game'.tr(), ImageConstant.eventComputerGame, 'playing_video_game'),
    EventModel('watching_movie_series'.tr(), ImageConstant.eventFilms, 'watching_movie_series'),
    EventModel('meeting_people'.tr(), ImageConstant.eventMeeting, 'meeting_people'),
    EventModel('communication'.tr(), ImageConstant.eventTalking, 'communication'),
    EventModel('walk'.tr(), ImageConstant.eventWalking, 'walk'),
    EventModel('performance'.tr(), ImageConstant.eventPerformance, 'performance'),
    EventModel('exam'.tr(), ImageConstant.eventExams, 'exam'),
    EventModel('test'.tr(), ImageConstant.eventTest, 'test'),
    EventModel('cleaning'.tr(), ImageConstant.eventCleaning, 'cleaning'),
    EventModel('cooking'.tr(), ImageConstant.eventCooking, 'cooking'),
    EventModel('unexpected_encounter'.tr(), ImageConstant.eventMeeting2, 'unexpected_encounter'),
    EventModel('waiting_for_person'.tr(), ImageConstant.eventWaiting, 'waiting_for_person'),
    EventModel('meeting'.tr(), ImageConstant.eventCollection, 'meeting'),
    EventModel('business_meeting'.tr(), ImageConstant.eventBusinessMeet, 'business_meeting'),
    EventModel('falling_asleep'.tr(), ImageConstant.eventFallingAsleep, 'falling_asleep'),
    EventModel('nightmare'.tr(), ImageConstant.eventNightmarish, 'nightmare'),
    EventModel('night_awakenings'.tr(), ImageConstant.eventAwakening, 'night_awakenings'),
    EventModel('insomnia'.tr(), ImageConstant.eventInsomnia, 'insomnia'),
    EventModel('being_late'.tr(), ImageConstant.eventDelay, 'being_late'),
    EventModel('watching_news'.tr(), ImageConstant.eventViewing, 'watching_news'),
    EventModel('online_communication'.tr(), ImageConstant.eventInInternet, 'online_communication'),
    EventModel('alcohol_intoxication'.tr(), ImageConstant.eventIntoxication, 'alcohol_intoxication'),
    EventModel('hangover'.tr(), ImageConstant.eventHangover, 'hangover'),
    EventModel('lack_of_sleep'.tr(), ImageConstant.eventLackOfSleep, 'lack_of_sleep'),
    EventModel('self_care'.tr(), ImageConstant.eventGoOut, 'self_care'),
    EventModel('sex'.tr(), ImageConstant.eventSex, 'sex'),
    EventModel('being_ignored'.tr(), ImageConstant.eventUpcoming, 'being_ignored'),
    EventModel('upcoming_conversation'.tr(), ImageConstant.eventRescheduled, 'upcoming_conversation'),
    EventModel('meeting_expectations'.tr(), ImageConstant.eventWaitingCollection, 'meeting_expectations'),
    EventModel('meeting_rescheduled'.tr(), ImageConstant.eventRescheduled, 'meeting_rescheduled'),
    EventModel('commute_to_work'.tr(), ImageConstant.eventTrip, 'commute_to_work'),
    EventModel('commute_to_school'.tr(), ImageConstant.eventInSchool, 'commute_to_school'),
    EventModel('argument'.tr(), ImageConstant.eventQuarrel, 'argument'),
    EventModel('guests_arriving'.tr(), ImageConstant.eventComing, 'guests_arriving'),
    EventModel('lost_item'.tr(), ImageConstant.eventLoss, 'lost_item'),
    EventModel('event_preparation'.tr(), ImageConstant.eventPreparation, 'event_preparation'),
    EventModel('deception'.tr(), ImageConstant.eventLie, 'deception'),
    EventModel('illness'.tr(), ImageConstant.eventHangover, 'illness'),
    EventModel('hobby'.tr(), ImageConstant.eventHobby, 'hobby'),
    EventModel('dance'.tr(), ImageConstant.eventDance, 'dance'),
    EventModel('music'.tr(), ImageConstant.eventMusic, 'music'),
  ];
}

