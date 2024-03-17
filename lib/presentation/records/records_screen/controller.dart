import 'dart:async';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/models/day_event_model.dart';

import 'repository.dart';
import 'package:path_provider/path_provider.dart';

class K49Controller extends GetxController {
  final _repo = K49Repo();
  bool isEmpty = true;
  double listHeight = 0;
  List<List<DayEventModel>> events = [];
  List<DayEventModel> list = [];

  Future<List<DayEventModel>> initializeList() async {
    return _repo.getEvent();
  }

  Future<List<List<DayEventModel>>> init() async {
    events = [];
    list = [];
    try {
      list = (await initializeList());
      for (int i = 0; i < list.length; i++) {
        if (events.isEmpty) {
          events.add([list[i]]);
          listHeight += 185 + 16;
          isEmpty = false;
        } else
          for (var element in events) {
            bool createNew = true;
            for (var _element in element) {
              if (_element.date!.month == list[i].date!.month &&
                  _element.date!.day == list[i].date!.day &&
                  _element.date!.year == list[i].date!.year) {
                element.add(list[i]);
                listHeight += 185 + 16;
                createNew = false;
                break;
              }
            }
            if (createNew) {
              events.add([list[i]]);
              listHeight += 185 + 16;
              isEmpty = false;
              break;
            }
          }
      }
    } catch (_) {}
    update();
    return events.reversed.toList();
  }
}
