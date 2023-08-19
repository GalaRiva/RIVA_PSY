import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'day_model.dart';

abstract class CalendarController extends GetxController {
  final BuildContext context;
  CalendarController(this.context);

  List<List<DayModel>> getDaysForRows = [];

  List<List<DayModel>> initializeDaysList();

  void popWithData(BuildContext context);

  void onYearPlus();

  void onYearMinus();

  void onMonthPlus();

  void onMonthMinus();


}