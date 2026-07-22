import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/presentation/settings/settings_pills/repository.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills_add_bottom_sheet/settings_pills_add_bottom_sheet.dart';

import '../../../../core/services/workmanager/workmanager_service.dart';
import '../models/pill_model.dart';
import 'pills_list_model.dart';
import 'widgets/pill_list_widget.dart';

class PillsController extends GetxController {
  var _currentPillsList = PillsList.actual;

  PillsList get currentPillsList => _currentPillsList;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  void addPill(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: ColorConstant.gray300,
        context: context,
        elevation: 0,
        builder: (context) => PillsAddBottomSheet()).then((value) {

          update();});
  }


  PillListWidget getListOnListType(PillsList currentType) {
    if(currentType == PillsList.onData) {
      return PillListWidget(pills: onDataPills, isSelected: _currentPillsList == currentType, update: update, title: 'По дате внесения');
    } else {
      return PillListWidget(pills: actualPills, isSelected: _currentPillsList == currentType, update: update, title: 'Актуальные назначения');
    }
  }

  void changePillsListState(PillsList state) {
    if (state == PillsList.onData)
      _currentPillsList = PillsList.onData;
    else
      _currentPillsList = PillsList.actual;
    update();
  }

   List<PillModel> actualPills = [];
   List<PillModel> onDataPills = [];

  final repo = PillsRepo();

  bool textIsVisible () {
    if (_currentPillsList == PillsList.actual) {
      if(actualPills.isEmpty) return false;
      return true;
    } else {
      if(onDataPills.isEmpty) return false;
      return true;
    }
  }

  Future<PillsListModel> getPills() async {
    final pills = await repo.getEvent();
    final actual = <PillModel>[];
    final onData = <PillModel>[];
    for (int i = 0; i < pills.length; i++) {
      final item = pills[i];
      if (item.actual()) {
          actual.add(item);
      }
        onData.add(item);

    }
    onDataPills = onData;
    actualPills = actual;

    onDataPills.sort((d1, d2) => d1.compareTo(d2));
    await repo.updateEvent(pills);
    return PillsListModel(actualList: actual, onDataList: onData);
  }

  bool checkDateInRange(DateTime date, DateTime startDate, DateTime endDate) {
    var start = DateTime(startDate.year, startDate.month, startDate.day - 1);
    var end = DateTime(startDate.year, startDate.month, startDate.day + 1);

    return date.isAfter(start) && date.isBefore(end);
  }
}

enum PillsList { actual, onData }
