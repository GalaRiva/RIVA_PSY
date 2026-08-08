import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/pill_model.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills_add_bottom_sheet/settings_pills_add_bottom_sheet.dart';

import '../../../../settings/settings_pills/repository.dart';
import '../../../../../theme/app_colors.dart';

class AdmissionScheduleController extends GetxController {
  bool scheduleWasCreated = false;
  var pills = <PillModel>[];
  DateTime? startDate;
  DateTime? endDate;
  var _schedulePeriod = SchedulePeriod.FiveDays;

  SchedulePeriod get schedulePeriod => _schedulePeriod;
  final _now = DateTime.now();


  void changePillsListState(SchedulePeriod period, BuildContext context) {
    if (period == SchedulePeriod.FiveDays) {
      startDate =
          DateTime(_now!.year, _now!.month, _now!.day - 5);
      endDate = DateTime.now();
      _schedulePeriod = SchedulePeriod.FiveDays;
    }
    if (period == SchedulePeriod.Month) {
      startDate =
          DateTime(_now!.year, _now!.month, _now!.day - 30);
      endDate = DateTime.now();
      _schedulePeriod = SchedulePeriod.Month;
    } if (period == SchedulePeriod.Custom) {
      Navigator.pushNamed(context, AppRoutes.charts_calendar).then((value) {
        if (value != null && value is Map<String, dynamic>) {
          startDate = value['start'];
          endDate = value['end'];
          _schedulePeriod = SchedulePeriod.Custom;
          update();
        }
      });
    }

    update();
  }

  String showCustomPeriod() {
    if(startDate == null || endDate == null || _schedulePeriod != SchedulePeriod.Custom) return 'select_period'.tr();
    return '${startDate!.format('dd.MM.yyyy')}-${endDate!.format('dd.MM.yyyy')}';
  }

  Future initialize() async {
    pills = await _pillsRepo.getEvent();
    scheduleWasCreated = pills.isNotEmpty;
    startDate =
        DateTime(_now!.year, _now!.month, _now!.day - 5);
    endDate = DateTime.now();
  }

  final _pillsRepo = PillsRepo();

  Future createSchedule(BuildContext context) async {
    if (!scheduleWasCreated) {
      showModalBottomSheet(
        backgroundColor: AppColors.background,
          context: context,
          builder: (context) => PillsAddBottomSheet()).then((value) async {
        scheduleWasCreated = (await _pillsRepo.getEvent()).isNotEmpty;
      });
      update();
    }
  }
}

enum SchedulePeriod { FiveDays, Month, Custom }
