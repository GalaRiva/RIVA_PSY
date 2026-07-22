import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/data/repository.dart';

import '../../../../../core/models/calendar/calendar_controller.dart';
import '../../../../../core/models/calendar/day_model.dart';
import '../../../../../core/models/calendar/month_model.dart';

class WorkingOutCalendarController extends CalendarController {
  final BuildContext context;

  WorkingOutCalendarController(this.context) : super(context);

  void init() {
    state = PeriodState.Start;
    periodStart = null;
    periodEnd = null;
    state = PeriodState.Start;
    getDaysForRows = initializeDaysList();
  }

  DateTime? periodStart;
  DateTime? periodEnd;

  late DateTime currentDate = DateTime.now();
  List<List<DayModel>> getDaysForRows = [];
  late int year;
  late int month;

  PeriodState state = PeriodState.Start;

  void popWithData(BuildContext context) {
    if (periodStart != null && periodEnd != null)
      Navigator.pop(context, {'start': periodStart, 'end': periodEnd});
    Get.delete<WorkingOutCalendarController>();
  }

  void _onTap(int i, int m) {
    if (state == PeriodState.Start) {
      periodStart = DateTime(currentDate.year, m, i);
      state = PeriodState.End;
      update();
    } else if (state == PeriodState.End) {
      var period = DateTime(currentDate.year, m, i);
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
  final _repo = WorkingOutRepo();

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
}
