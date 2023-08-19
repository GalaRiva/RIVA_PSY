import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/models/calendar/calendar_controller.dart';

import '../../../presentation/charts/charts_calendar/controller.dart';
import '../../../routes/app_routes.dart';
import '../day_event_model.dart';
import 'day_model.dart';

class MonthModel {
  final DateTime currentMonth;
  final List<DayEventModel> dayEvents;
  final DayType dayType;

  MonthModel(this.dayType,
      {required this.currentMonth, required this.dayEvents});

  bool _dateInRange(DateTime date, DateTime dateStart, DateTime dateEnd) {
    final start = DateTime(dateStart.year, dateStart.month, dateStart.day - 1);
    final end = DateTime(dateEnd.year, dateEnd.month, dateEnd.day + 1);

    if (date.isAfter(start) && date.isBefore(end)) {
      return true;
    }
    return false;
  }

  final List<Map> _dayEventsInCurrentMonth = [];
  List<int> _indexes = [];

  List<DayModel> initializeMonth(BuildContext context, CalendarType type) {
    final DateTime previousMonth =
        DateTime(currentMonth.year, currentMonth.month - 1);
    final DateTime nextMonth =
        DateTime(currentMonth.year, currentMonth.month + 1);
    List<DayModel> dayList = [];

    _getDayEventsInCurrentMonth();
    for (int i = 0; i < _getMonthLength(currentMonth); i++) {
      dynamic dayEventModel = null;
      for (int _i = 0; _i < _indexes.length; _i++) {
        if (_indexes[_i] == i + 1) {
          dayEventModel = _dayEventsInCurrentMonth[_i]['model'];
        }
      }
      void _onTap() {
        if (dayEventModel != null && type == CalendarType.Change) {
          Navigator.pushNamed(context, AppRoutes.record_edit,
              arguments: dayEventModel);
        } else if (type == CalendarType.Add) {
          Navigator.pushNamed(context, AppRoutes.record_add,
              arguments:
                  DateTime(currentMonth.year, currentMonth.month, i + 1));
        } else
          null;
      }

      dayList.add(DayModel(
        month: currentMonth.month, year: currentMonth.year,

          type: dayType,
          day: i + 1,
          isActive: true,
          dayEventModel: dayEventModel,
          onTap: _onTap));
    }
    dayList = _getInactiveDays(previousMonth, onTap: (i, m) {

    }).reversed.toList() +
        dayList +
        _getInactiveDays(nextMonth, onTap: (i, m) {

        });
    return dayList;
  }

  List<DayModel> initializeMonthForPeriod(
      CalendarController controller,
      BuildContext context,
      PeriodState state,
      Function(int date, int month) onTap,
      DateTime? start,
      DateTime? end) {
    final DateTime previousMonth =
        DateTime(currentMonth.year, currentMonth.month - 1);
    final DateTime nextMonth =
        DateTime(currentMonth.year, currentMonth.month + 1);
    List<DayModel> dayList = [];

    for (int i = 0; i < _getMonthLength(currentMonth); i++) {
      bool inPeriod = false;
      bool isStart = false;
      bool isEnd = false;
      if (start != null &&
          end != null &&
          _dateInRange(DateTime(currentMonth.year, currentMonth.month, i + 1),
              start, end)) {
        inPeriod = true;
      }
      if(start == DateTime(currentMonth.year, currentMonth.month, i+1)) isStart = true;
      if(end == DateTime(currentMonth.year, currentMonth.month, i+1)) isEnd = true;
      dayList.add(DayModel(
        month: currentMonth.month, year: currentMonth.year,

          type: dayType,
          day: i + 1,
          isActive: true,
          onTap: () {
            onTap(i + 1,currentMonth.month);
            controller.getDaysForRows = controller.initializeDaysList();
            controller.update();
          },
          periodEnd: isEnd,
          periodStart: isStart,
          inPeriod: inPeriod));
    }
    dayList = _getInactiveDays(previousMonth, onTap: (int i, m) {
      onTap(i, m);
      controller.getDaysForRows = controller.initializeDaysList();
      controller.update();
    },
    start: start, end: end).reversed.toList() +
        dayList +
        _getInactiveDays(nextMonth,   onTap: (int i, m) {
          onTap(i, m);
          controller.getDaysForRows = controller.initializeDaysList();
          controller.update();
        }, start: start, end: end);
    return dayList;
  }

  void _getDayEventsInCurrentMonth() {
    for (int i = 0; i < dayEvents.length; i++) {
      if (dayEvents[i].date!.month == currentMonth.month &&
          dayEvents[i].date!.year == currentMonth.year &&
          !_indexes.contains(dayEvents[i].date!.day)) {
        _dayEventsInCurrentMonth.add({
          'day': dayEvents[i].date!.day,
          'model': dayEvents[i],
        });
        _indexes.add(dayEvents[i].date!.day);
      }
    }
  }

  List<DayModel> _getInactiveDays(DateTime someMonth, {required Function(int day, int month) onTap,  DateTime? start, DateTime? end}) {
    List<DayModel> list = [];
    if (someMonth.month < currentMonth.month &&
        someMonth.year <= currentMonth.year) {
      final DateTime firstDayInCurrentMonth =
          DateTime(currentMonth.year, currentMonth.month, 1);
      if (firstDayInCurrentMonth.weekday > 1)
        for (int i = 1; i < firstDayInCurrentMonth.weekday; i++) {

          bool inPeriod = false;
          bool isStart = false;
          bool isEnd = false;
          if (start != null &&
              end != null &&
              _dateInRange(DateTime(someMonth.year, someMonth.month,  _getMonthLength(someMonth) + 1 - i),
                  start, end)) {
            inPeriod = true;
          }
          if(start == DateTime(someMonth.year, someMonth.month,  _getMonthLength(someMonth) + 1 - i)) isStart = true;
          if(end == DateTime(someMonth.year, someMonth.month,  _getMonthLength(someMonth) + 1 - i)) isEnd = true;


          list.add(DayModel(
            month: someMonth.month, year: someMonth.year,
              onTap: () =>onTap(_getMonthLength(someMonth) + 1 - i, someMonth.month),
              day: _getMonthLength(someMonth) + 1 - i,
              isActive: false,
              type: dayType,
              inPeriod: inPeriod,
            periodEnd: isEnd,
            periodStart: isStart,

          ));
        }
    } else if (someMonth.month > currentMonth.month &&
        someMonth.year < currentMonth.year) {
      final DateTime firstDayInCurrentMonth =
          DateTime(currentMonth.year, currentMonth.month, 1);
      if (firstDayInCurrentMonth.weekday > 1)
        for (int i = 1; i < firstDayInCurrentMonth.weekday; i++) {
int day = _getMonthLength(someMonth) - 1 - i;
          bool inPeriod = false;
          bool isStart = false;
          bool isEnd = false;
          if (start != null &&
              end != null &&
              _dateInRange(DateTime(someMonth.year, someMonth.month, day),
                  start, end)) {
            inPeriod = true;
          }
          if(start == DateTime(someMonth.year, someMonth.month, day)) isStart = true;
          if(end == DateTime(someMonth.year, someMonth.month, day)) isEnd = true;


          list.add(DayModel(
            month: someMonth.month, year: someMonth.year,
              onTap: () =>onTap(day,someMonth.month),

              day: _getMonthLength(someMonth) - 1 - i,
              isActive: false,
              type: dayType,inPeriod: inPeriod,periodEnd: isEnd, periodStart: isStart,));
        }
    } else {
      final DateTime lastDayInCurrentMonth = DateTime(
          currentMonth.year, currentMonth.month, _getMonthLength(currentMonth));
      if (lastDayInCurrentMonth.weekday < 7)
        for (int i = 1; i <= 7 - lastDayInCurrentMonth.weekday; i++) {

          int day = i;
          bool inPeriod = false;
          bool isStart = false;
          bool isEnd = false;
          if (start != null &&
              end != null &&
              _dateInRange(DateTime(someMonth.year, someMonth.month, day),
                  start, end)) {
            inPeriod = true;
          }
          if(start == DateTime(someMonth.year, someMonth.month, day)) isStart = true;
          if(end == DateTime(someMonth.year, someMonth.month, day)) isEnd = true;



          list.add(DayModel(
              onTap: () => onTap(i,someMonth.month),
              inPeriod: inPeriod,
              periodStart: isStart,
              periodEnd: isEnd,
              month: someMonth.month, year: someMonth.year,
              day: i, isActive: false, type: dayType));
        }
    }
    return list;
  }

  int _getMonthLength(DateTime currentMonth) =>
      new DateTime(currentMonth.year, currentMonth.month + 1, 0).day;
}

enum CalendarType { Add, Change }

enum PeriodState { Start, End }
