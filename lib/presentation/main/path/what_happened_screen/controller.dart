import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/utils/image_constant.dart';
import 'repository.dart';

class K22Controller extends GetxController {

  final _repo = K22Repo();

  final searchController = TextEditingController();
  final addEventController = TextEditingController();

  EventModel? whatHappened;

  late List<EventModel> currentEventList = _repo.standartEventList;
   List<EventModel> eventListAfterInit = [];

  bool contain (EventModel _event) {
    if(whatHappened != null && whatHappened!.identity == _event.identity) {
      return true;
    }
    return false;
  }

  void changeCurrentEventList (String text) async {
    if(text.isNotEmpty) {
      if (currentEventList.isNotEmpty)
        currentEventList = [];
      for (final event in await initCurrentEventList()) {
        if (event.name.toLowerCase().contains(text.toLowerCase())) currentEventList.add(event);
      }
      eventListAfterInit = currentEventList;
    } else {
      currentEventList = await initCurrentEventList();
    }
  }

  Future<List<EventModel>> updateCurrentEventList (EventModel model) async {
    final listToUpdate = await initCurrentEventList();
    listToUpdate.add(model);
    await _repo.updateEvent(listToUpdate);
    return listToUpdate;
  }

  Future<List<EventModel>> initCurrentEventList () async {
    return _repo.getEvent();
  }
}
