import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../theme/app_style.dart';
import '../../../../../../widgets/custom_button.dart';
import '../../../../../settings/settings_pills/models/pill_model.dart';
import '../controller.dart';
import 'grid.dart';

Widget schedule(List<PillModel> pills, AdmissionScheduleController controller,
    BuildContext context) {
  return Padding(
    padding: getPadding(right: 16, left: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: getPadding(top: 31, right: 32),
          child: Text(
            '''Если приняли чуть позже, ничего страшного. 
Примите и поменяйте статус приема в течении дня, 
нажав на соответствующую ячейку в графике''',
            style: AppStyle.txtSFProDisplayLight12,
          ),
        ),
        Padding(
          padding: getPadding(top: 18, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomButton(
                height: getVerticalSize(42),
                width: (size.width - 64) / 3,
                padding: ButtonPadding.PaddingT8,
                centralWidget: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Показать 5 дней',
                    style: TextStyle(
                      color: ColorConstant.deepPurple600,
                      fontSize: getFontSize(
                        12,
                      ),
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: getVerticalSize(
                        1.25,
                      ),
                    ),
                  ),
                ),
                onTap: () => controller.changePillsListState(
                    SchedulePeriod.FiveDays, context),
                variant: controller.schedulePeriod == SchedulePeriod.FiveDays
                    ? ButtonVariant.White
                    : ButtonVariant.OutlineBluegray60014_1,
              ),
              CustomButton(
                height: getVerticalSize(42),
                width: (size.width - 64) / 3,
                padding: ButtonPadding.PaddingT8,
                centralWidget: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Показать месяц',
                    style: TextStyle(
                      color: ColorConstant.deepPurple600,
                      fontSize: getFontSize(
                        12,
                      ),
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: getVerticalSize(
                        1.25,
                      ),
                    ),
                  ),
                ),
                onTap: () => controller.changePillsListState(
                    SchedulePeriod.Month, context),
                variant: controller.schedulePeriod == SchedulePeriod.Month
                    ? ButtonVariant.White
                    : ButtonVariant.OutlineBluegray60014_1,
              ),
              CustomButton(
                height: getVerticalSize(42),
                width: (size.width - 64) / 3,
                padding: ButtonPadding.PaddingT8,
                centralWidget: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    controller.showCustomPeriod(),
                    style: TextStyle(
                      color: ColorConstant.deepPurple600,
                      fontSize: getFontSize(
                        12,
                      ),
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w400,
                      height: getVerticalSize(
                        1.25,
                      ),
                    ),
                  ),
                ),
                onTap: () => controller.changePillsListState(
                    SchedulePeriod.Custom, context),
                variant: controller.schedulePeriod == SchedulePeriod.Custom
                    ? ButtonVariant.White
                    : ButtonVariant.OutlineBluegray60014_1,
              ),
            ],
          ),
        ),
        SizedBox(height: getVerticalSize(33)),
        scheduleGrid(context,
            update: () => controller.update(),
            pills: pills,
            startPeriod: controller.startDate ?? DateTime.now(),
            endPeriod: controller.endDate ?? DateTime.now(),
            standardCellSize:
                controller.schedulePeriod == SchedulePeriod.FiveDays ? 30 : 15,
            showText: controller.schedulePeriod == SchedulePeriod.FiveDays),
        SizedBox(height: getVerticalSize(33)),
        CustomButton(
          text: 'изменить график приема препарата'.toUpperCase(),
          padding: ButtonPadding.PaddingAll8,
          onTap: () => Navigator.pushNamed(context, AppRoutes.pills)
              .then((value) => controller.update()),
        )
      ],
    ),
  );
}
