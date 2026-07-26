import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/utils/image_constant.dart';
import 'repository.dart';

class K25Controller extends GetxController {

  final _repo = K25Repo();

  final searchController = TextEditingController();
  final addEventController = TextEditingController();

  late List<EventModel> currentEventList = _repo.standartEventList;
  List<EventModel> eventListAfterInit = [];
  EventModel? whereHappened;

  bool contain (EventModel _event) {
    if(whereHappened!= null && whereHappened!.identity == _event.identity) {
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
