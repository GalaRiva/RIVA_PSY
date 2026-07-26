import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
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
    List<EventModel> list = events.map((e) => EventModel(e.name, e.svgPath, e.key)).toList();
    for(var item in list) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  final standartEventList = <EventModel>[
    EventModel('myself'.tr(), ImageConstant.imgHome, 'myself'),
    EventModel('mom'.tr(), ImageConstant.imgMusicCyan70021x19, 'mom'),
    EventModel('dad'.tr(), ImageConstant.imgUserCyan70021x19, 'dad'),
    EventModel('brother'.tr(), ImageConstant.eventWho4, 'brother'),
    EventModel('sister'.tr(), ImageConstant.eventWho5, 'sister'),
    EventModel('friend'.tr(), ImageConstant.imgTrash21x19, 'friend'),
    EventModel('girlfriend'.tr(), ImageConstant.imgMusic21x19, 'girlfriend'),
    EventModel('significant_other'.tr(), ImageConstant.imgGroupCyan70021x18, 'significant_other'),
    EventModel('husband'.tr(), ImageConstant.imgUser21x19, 'husband'),
    EventModel('wife'.tr(), ImageConstant.eventWho10, 'wife'),
    EventModel('son'.tr(), ImageConstant.eventWho11, 'son'),
    EventModel('daughter'.tr(), ImageConstant.imgUser1, 'daughter'),
    EventModel('grandma'.tr(), ImageConstant.eventWho13, 'grandma'),
    EventModel('grandpa'.tr(), ImageConstant.eventWho14, 'grandpa'),
    EventModel('aunt'.tr(), ImageConstant.imgGroupCyan70021x20, 'aunt'),
    EventModel('uncle'.tr(), ImageConstant.imgTrophyCyan700, 'uncle'),
    EventModel('close_relative'.tr(), ImageConstant.imgGroup86, 'close_relative'),
    EventModel('colleague'.tr(), ImageConstant.eventColleague, 'colleague'),
    EventModel('classmate'.tr(), ImageConstant.eventClassmate, 'classmate'),
    EventModel('acquaintance'.tr(), ImageConstant.eventFamiliar, 'acquaintance'),
    EventModel('passerby'.tr(), ImageConstant.imgAirplaneCyan70021x12, 'passerby'),
    EventModel('online_friend'.tr(), ImageConstant.eventInternetFriend, 'online_friend'),
    EventModel('online_person'.tr(), ImageConstant.eventInternetHuman, 'online_person'),
    EventModel('organization_employee'.tr(), ImageConstant.eventEmployee, 'organization_employee'),
    EventModel('director'.tr(), ImageConstant.eventDirector, 'director'),
    EventModel('subordinate'.tr(), ImageConstant.eventSubordinate, 'subordinate'),
    EventModel('pet'.tr(), ImageConstant.eventPet, 'pet'),
    EventModel('family'.tr(), ImageConstant.eventFamily, 'family'),
  ];
}

