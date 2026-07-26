import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
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
    List<EventModel> list = events.map((e) => EventModel(e.name, e.svgPath, e.key)).toList();
    for(var item in list) {
      HiveDB.setBox(item.toJson(), _eventTag);
    }
  }

  final standartEventList = <EventModel>[
    EventModel('home'.tr(), ImageConstant.imgHome, 'home'),
    EventModel('public_transport'.tr(), ImageConstant.eventWhere2, 'public_transport'),
    EventModel('plane'.tr(), ImageConstant.imgAirplaneCyan70023x25, 'plane'),
    EventModel('car'.tr(), ImageConstant.imgCar, 'car'),
    EventModel('school'.tr(), ImageConstant.eventWhere5, 'school'),
    EventModel('university'.tr(), ImageConstant.eventWhere6, 'university'),
    EventModel('work'.tr(), ImageConstant.imgUser23x18, 'work'),
    EventModel('cinema'.tr(), ImageConstant.imgCalendarCyan700, 'cinema'),
    EventModel('cafe'.tr(), ImageConstant.imgClockCyan70019x21, 'cafe'),
    EventModel('restaurant'.tr(), ImageConstant.imgCamera, 'restaurant'),
    EventModel('street'.tr(), ImageConstant.eventWhere11, 'street'),
    EventModel('park'.tr(), ImageConstant.imgGroupCyan70017x22, 'park'),
    EventModel('bus_stop'.tr(), ImageConstant.eventWhere13, 'bus_stop'),
    EventModel('internet'.tr(), ImageConstant.eventWhere14, 'internet'),
    EventModel('social_media'.tr(), ImageConstant.imgUserCyan70021x14, 'social_media'),
    EventModel('shop'.tr(), ImageConstant.imgTrashCyan70019x20, 'shop'),
    EventModel('mall'.tr(), ImageConstant.eventWhere17, 'mall'),
    EventModel('elevator'.tr(), ImageConstant.imgClockCyan70019x22, 'elevator'),
    EventModel('public_event'.tr(), ImageConstant.eventWhere19, 'public_event'),
    EventModel('gym'.tr(), ImageConstant.eventWhere20, 'gym'),
    EventModel('club'.tr(), ImageConstant.imgHomeCyan700, 'club'),
    EventModel('service'.tr(), ImageConstant.imgUserCyan70024x27, 'service'),
    EventModel('beauty_salon'.tr(), ImageConstant.eventWhere23, 'beauty_salon'),
    EventModel('museum'.tr(), ImageConstant.eventWhere24, 'museum'),
    EventModel('theater'.tr(), ImageConstant.eventWhere25, 'theater'),
    EventModel('visiting'.tr(), ImageConstant.eventWhere26, 'visiting'),
    EventModel('cottage'.tr(), ImageConstant.imgHomeCyan70021x24, 'cottage'),
    EventModel('hospital'.tr(), ImageConstant.imgVideocamera17x17, 'hospital'),
    EventModel('clinic'.tr(), ImageConstant.eventWhere29, 'clinic'),
    EventModel('public_institution'.tr(), ImageConstant.imgComputerCyan700, 'public_institution'),
  ];
}

