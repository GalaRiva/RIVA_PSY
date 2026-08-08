import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/calendar/month_model.dart';
import 'package:riva_psy/presentation/charts/charts_screen/controller.dart';
import 'package:riva_psy/presentation/charts/charts_screen/widgets/admission_schedule/controller.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../settings/settings_pills/models/pill_model.dart';
import 'widgets/schedule.dart';

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
                : schedule(controller.pills, controller, context),
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

}
