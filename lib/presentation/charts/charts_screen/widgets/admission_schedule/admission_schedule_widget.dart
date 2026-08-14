import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/charts/charts_screen/widgets/admission_schedule/controller.dart';
import 'package:riva_psy/widgets/chip_selector.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import 'widgets/calendar_ribbon.dart';
import 'widgets/daily_timeline.dart';
import 'widgets/insight_card.dart';
import 'widgets/monthly_stats_view.dart';

class AdmissionScheduleWidget extends StatelessWidget {

  const AdmissionScheduleWidget({Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdmissionScheduleController());
    return Container(
      width: size.width,
      decoration: AppDecoration.glassCard,
      child: FutureBuilder(
        future: controller.initialize(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(
                  color: ColorConstant.cyan700,
                ),
              ),
            );
          }
          return GetBuilder(
            builder: (AdmissionScheduleController _c) => !controller.scheduleWasCreated
                ? _createScheduleButton(controller, context)
                : _trackerView(controller, context),
          );
        },
      ),
    );
  }

  Widget _createScheduleButton(AdmissionScheduleController controller, BuildContext context) {
    return Padding(
      padding: getPadding(top: 42),
      child: CustomButton(
        variant: ButtonVariant.Base,
        onTap: () => controller.createSchedule(context),
        padding: ButtonPadding.PaddingAll8,
        text: 'add_medication_intake_schedule'.tr().toUpperCase(),
        width: getHorizontalSize(315),
        alignment: Alignment.center,
        height: getVerticalSize(32),
        suffixWidget: CustomImageView(
          svgPath: ImageConstant.imgVector46,
          width: getHorizontalSize(4),
          margin: getMargin(left: 10),
          height: getVerticalSize(8),
        ),
      ),
    );
  }

  Widget _trackerView(AdmissionScheduleController controller, BuildContext context) {
    return Padding(
      padding: getPadding(top: 20, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChipSelector<TrackerView>(
            selected: controller.view,
            onSelected: controller.setView,
            options: [
              ChipOption(value: TrackerView.daily, label: 'daily_plan'.tr()),
              ChipOption(value: TrackerView.stats, label: 'monthly_stats'.tr()),
            ],
          ),
          SizedBox(height: getVerticalSize(18)),
          if (controller.view == TrackerView.daily) ...[
            CalendarRibbon(
              selectedDate: controller.selectedDate,
              onSelected: controller.selectDate,
              indicatorFor: controller.dayIndicatorStatus,
            ),
            SizedBox(height: getVerticalSize(18)),
            DailyTimeline(
              date: controller.selectedDate,
              doses: controller.dosesOn(controller.selectedDate),
              controller: controller,
            ),
            SizedBox(height: getVerticalSize(18)),
            const InsightSection(),
          ] else
            MonthlyStatsView(adherence: controller.monthlyAdherence()),
          SizedBox(height: getVerticalSize(20)),
          CustomButton(
            text: 'change_medication_intake_schedule'.tr().toUpperCase(),
            padding: ButtonPadding.PaddingAll8,
            onTap: () => Navigator.pushNamed(context, AppRoutes.pills)
                .then((value) => controller.update()),
          ),
          SizedBox(height: getVerticalSize(10)),
        ],
      ),
    );
  }

}
