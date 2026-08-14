import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_style.dart';

import '../controller.dart';
import 'dose_card.dart';

class DailyTimeline extends StatelessWidget {
  final DateTime date;
  final List<ScheduledDose> doses;
  final AdmissionScheduleController controller;

  const DailyTimeline({
    Key? key,
    required this.date,
    required this.doses,
    required this.controller,
  }) : super(key: key);

  int _hour(String time) => int.tryParse(time.split(':')[0]) ?? 0;

  @override
  Widget build(BuildContext context) {
    if (doses.isEmpty) {
      return Padding(
        padding: getPadding(top: 20, bottom: 20),
        child: Text(
          'no_doses_today'.tr(),
          style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800),
        ),
      );
    }

    final morning = doses.where((d) => _hour(d.time) < 12).toList();
    final lunch = doses.where((d) => _hour(d.time) >= 12 && _hour(d.time) < 17).toList();
    final evening = doses.where((d) => _hour(d.time) >= 17).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (morning.isNotEmpty) _group('time_morning'.tr(), morning),
        if (lunch.isNotEmpty) _group('time_lunch'.tr(), lunch),
        if (evening.isNotEmpty) _group('time_evening'.tr(), evening),
      ],
    );
  }

  Widget _group(String title, List<ScheduledDose> groupDoses) {
    return Padding(
      padding: getPadding(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: getPadding(bottom: 8),
            child: Text(
              title,
              style: AppStyle.txtSFProDisplayLight11.copyWith(color: ColorConstant.gray800),
            ),
          ),
          ...groupDoses.map((d) => DoseCard(
                pill: d.pill,
                time: d.time,
                status: controller.statusOf(d.pill, date, d.time),
                onTake: () => controller.markTaken(d.pill, date, d.time),
                onSkip: () => controller.markSkipped(d.pill, date, d.time),
                onReset: () => controller.resetStatus(d.pill, date, d.time),
              )),
        ],
      ),
    );
  }
}
