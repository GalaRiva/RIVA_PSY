import 'dart:async';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/models/day_event_model.dart';

import '../../charts/charts_screen/models/report_model.dart';
import 'repository.dart';
import 'package:path_provider/path_provider.dart';

class K49Controller extends GetxController {
  final _repo = K49Repo();
  bool isEmpty = true;
  double listHeight = 0;
  List<List<DayEventModel>> events = [];
  List<DayEventModel> list = [];

  // SMER report (moved here from the Charts screen — it's fundamentally
  // about these diary entries, not the analytics tabs). Deliberately
  // independent of K61Controller: its own date range, its own event fetch,
  // so removing the Charts tab can't affect any of the other 8 tabs there.
  final reportModel = ReportModel();
  var reportDateStart = DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1));
  var reportDateEnd = DateTime.now().add(Duration(days: 7 - DateTime.now().weekday));

  bool _inReportRange(DateTime date) {
    final start = DateTime(reportDateStart.year, reportDateStart.month, reportDateStart.day - 1);
    final end = DateTime(reportDateEnd.year, reportDateEnd.month, reportDateEnd.day + 1);
    return start.isBefore(date) && end.isAfter(date);
  }

  Future<List<DayEventModel>> getReportEvents() async {
    final dayEvents = (await _repo.getEvent()).where((e) => e.showInCharts).toList();
    return dayEvents.where((e) => _inReportRange(e.date ?? DateTime.now())).toList();
  }

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
