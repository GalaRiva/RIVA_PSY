import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/pill_model.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills_edit_bottom_sheet/settings_pills_edit_bottom_sheet.dart';
import 'package:riva_psy/presentation/settings/settings_pills/widget/medication_icon_color_picker.dart';
import 'package:riva_psy/theme/app_icons.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../theme/app_colors.dart';

Widget PillCardWidget(BuildContext context, {required PillModel pillModel, required bool isSelected, required Function update}) {

  _onTap () {
    showModalBottomSheet (
        backgroundColor: AppColors.background,
        elevation: 0,
        isScrollControlled: true,
        context: context, builder: (context) => PillsEditBottomSheet(pill: pillModel)).then((value) {
          update();});
  }

  final color = Color(pillModel.colorValue);
  final totalDays = pillModel.endDate.difference(pillModel.startDate).inDays;
  final showProgress = isSelected && totalDays > 0 && totalDays <= 366;
  final dayOfCourse = showProgress
      ? (DateTime.now().difference(pillModel.startDate).inDays + 1).clamp(1, totalDays)
      : 0;
  final progress = showProgress ? dayOfCourse / totalDays : 0.0;

  final instructionLabel = pillModel.instructionTiming != null
      ? pillModel.instructionTiming!.tr()
      : null;
  final subtitleParts = [
    if (pillModel.dosage != null && pillModel.dosage!.isNotEmpty) pillModel.dosage!,
    if (pillModel.hoursOfTakingPills.isNotEmpty) pillModel.hoursOfTakingPills.join(', '),
    if (instructionLabel != null) instructionLabel,
  ];

  return Container(
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getHorizontalSize(8))),
    child: Padding(
      padding: getPadding(all: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: getHorizontalSize(40),
                height: getHorizontalSize(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                ),
                child: Icon(
                  medicationIconForType(pillModel.iconType),
                  color: Colors.white,
                  size: getHorizontalSize(20),
                ),
              ),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pillModel.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.txtSFProDisplayLight16.copyWith(
                          color: ColorConstant.gray800, fontWeight: FontWeight.w500),
                    ),
                    if (subtitleParts.isNotEmpty)
                      Padding(
                        padding: getPadding(top: 4),
                        child: Text(
                          subtitleParts.join(' • '),
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.txtSFProDisplayLight11
                              .copyWith(color: ColorConstant.gray800),
                        ),
                      ),
                  ],
                ),
              ),
              InkWell(
                onTap: _onTap,
                child: Icon(
                  AppIcons.pencilSimple,
                  size: getHorizontalSize(18),
                  color: ColorConstant.gray800,
                ),
              ),
            ],
          ),
          if (showProgress) ...[
            SizedBox(height: getVerticalSize(10)),
            ClipRRect(
              borderRadius: BorderRadius.circular(getHorizontalSize(3)),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: getVerticalSize(4),
                backgroundColor: ColorConstant.grayLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            SizedBox(height: getVerticalSize(4)),
            Text(
              'day_n_of_m'.tr(args: ['$dayOfCourse', '$totalDays']),
              style: AppStyle.txtSFProDisplayLight11.copyWith(color: ColorConstant.gray800),
            ),
          ],
        ],
      ),
    ),
  );
}
