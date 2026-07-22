import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/models/calendar/month_model.dart';

import '../../../core/models/calendar/day_model.dart';
import '../../../core/models/day_event_model.dart';

class K50Controller extends GetxController {

  final List<DayEventModel>? dayEvents;
  final BuildContext context;

  K50Controller(this.dayEvents, this.context);

  late DateTime currentDate = DateTime.now();
  List<List<DayModel>> getDaysForRows = [];
  late int year;
  late int month;


  List<List<DayModel>> initializeDaysList () {
    getDaysForRows=[];
    year = currentDate.year;
    month = currentDate.month;
    final monthModel = MonthModel(DayType.dayEvents,currentMonth: currentDate, dayEvents: dayEvents ?? []);
    final listForReturn = monthModel.initializeMonth(context, CalendarType.Change);
    for(int i = 0; i < listForReturn.length / 7; i++) {
      final ind = i * 7;
      final list = listForReturn.getRange(ind, ind + 7).toList();
      getDaysForRows.add(list);
    }
    return getDaysForRows;
  }

  void onYearPlus () {
    year++;
    _acceptChanges();
  }

  void onYearMinus () {
    year--;
    _acceptChanges();
  }

  void onMonthPlus () {
    month++;
    _acceptChanges();
  }

  void onMonthMinus () {
    month--;
    _acceptChanges();
  }

  void _acceptChanges () {
    currentDate = DateTime(year, month, 1);
    getDaysForRows = [];
    getDaysForRows = initializeDaysList();
    update();
  }
}