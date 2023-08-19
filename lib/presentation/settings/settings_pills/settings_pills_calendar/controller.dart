import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/models/calendar/calendar_controller.dart';

import '../../../../core/models/calendar/day_model.dart';
import '../../../../core/models/calendar/month_model.dart';

class PillsCalendarController extends CalendarController {
  final BuildContext context;

  PillsCalendarController(this.context) : super(context);

  void _update () {
    state = PeriodState.Start;
    periodStart = null;
    periodEnd = null;
    state = PeriodState.Start;
    getDaysForRows = initializeDaysList();
  }

  DateTime? periodStart;
  DateTime? periodEnd;

  List<List<DayModel>> getDaysForRows = [];

  DateTime currentDate = DateTime.now();
  int year = DateTime.now().year;
  int month = DateTime.now().month;

  PeriodState state = PeriodState.Start;

  void popWithData(BuildContext context) {
    if (periodStart != null && periodEnd != null)
        Navigator.pop(context, {'start': periodStart, 'end': periodEnd});
      _update();
  }

  void _onTap(int d, int m) {
    if (state == PeriodState.Start) {
      periodStart = DateTime(currentDate.year, m, d);
      state = PeriodState.End;
      update();
    } else if (state == PeriodState.End) {
      var period = DateTime(currentDate.year, m, d);
      if(period.isBefore(periodStart!)) {
        periodEnd = periodStart;
        periodStart = period;
      } else {
        periodEnd = period;
      }

      update();
    } else
      return null;
  }

  List<List<DayModel>> initializeDaysList() {
    getDaysForRows = [];
    year = currentDate.year;
    month = currentDate.month;
    final monthModel =
    MonthModel(DayType.periods, currentMonth: currentDate, dayEvents: []);
    List<DayModel> listForReturn = monthModel.initializeMonthForPeriod(
        this, context, state, _onTap, periodStart, periodEnd);
    for (int i = 0; i < listForReturn.length / 7; i++) {
      final ind = i * 7;
      final list = listForReturn.getRange(ind, ind + 7).toList();
      getDaysForRows.add(list);
    }
    return getDaysForRows;
  }

  void onYearPlus() {
    year++;
    _acceptChanges();
  }

  void onYearMinus() {
    year--;
    _acceptChanges();
  }

  void onMonthPlus() {
    month++;
    _acceptChanges();
  }

  void onMonthMinus() {
    month--;
    _acceptChanges();
  }

  void _acceptChanges() {
    currentDate = DateTime(year, month, 1);
    getDaysForRows = [];
    getDaysForRows = initializeDaysList();
    update();
  }
  void cancel (BuildContext context) {
    _update();
    Navigator.pop(context);
  }
}