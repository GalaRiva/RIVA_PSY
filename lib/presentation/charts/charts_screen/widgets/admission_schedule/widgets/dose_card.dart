import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_icons.dart';
import 'package:riva_psy/theme/app_style.dart';

import '../../../../../settings/settings_pills/models/pill_model.dart';
import '../../../../../settings/settings_pills/widget/medication_icon_color_picker.dart';
import '../controller.dart';

class DoseCard extends StatelessWidget {
  final PillModel pill;
  final String time;
  final DoseStatus status;
  final VoidCallback onTake;
  final VoidCallback onSkip;
  final VoidCallback onReset;

  const DoseCard({
    Key? key,
    required this.pill,
    required this.time,
    required this.status,
    required this.onTake,
    required this.onSkip,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = Color(pill.colorValue);
    final instructionLabel = pill.instructionTiming != null ? pill.instructionTiming!.tr() : null;
    final subtitleParts = [
      if (pill.dosage != null && pill.dosage!.isNotEmpty) pill.dosage!,
      if (instructionLabel != null) instructionLabel,
    ];

    return Container(
      margin: getMargin(bottom: 10),
      padding: getPadding(all: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(getHorizontalSize(8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: getHorizontalSize(44),
                child: Text(
                  time,
                  style: AppStyle.txtSFProDisplayLight14
                      .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                width: getHorizontalSize(36),
                height: getHorizontalSize(36),
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Icon(medicationIconForType(pill.iconType), color: Colors.white, size: getHorizontalSize(18)),
              ),
              SizedBox(width: getHorizontalSize(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pill.name,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.txtSFProDisplayLight14
                          .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w500),
                    ),
                    if (subtitleParts.isNotEmpty)
                      Text(
                        subtitleParts.join(' • '),
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayLight11.copyWith(color: ColorConstant.gray800),
                      ),
                  ],
                ),
              ),
              SizedBox(width: getHorizontalSize(8)),
              _statusButton(),
            ],
          ),
          if (status == DoseStatus.pending)
            Padding(
              padding: getPadding(top: 4, left: 54),
              child: Align(
                alignment: Alignment.centerLeft,
                child: InkWell(
                  onTap: onSkip,
                  child: Padding(
                    padding: getPadding(top: 12, bottom: 12, right: 8),
                    child: Text(
                      'skip_dose'.tr(),
                      style: AppStyle.txtSFProDisplayLight11
                          .copyWith(color: ColorConstant.gray800),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statusButton() {
    if (status == DoseStatus.taken) {
      return _pill(
        onTap: onReset,
        color: Colors.green,
        icon: AppIcons.check,
        label: 'taken_status'.tr(),
      );
    }
    if (status == DoseStatus.skipped) {
      return _pill(
        onTap: onReset,
        color: Colors.orange,
        icon: AppIcons.x,
        label: 'skipped_status'.tr(),
      );
    }
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTake();
      },
      customBorder: const CircleBorder(),
      child: Container(
        width: getHorizontalSize(48),
        height: getHorizontalSize(48),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ColorConstant.cyan700, width: 2),
        ),
        child: Icon(AppIcons.check, color: ColorConstant.cyan700, size: getHorizontalSize(22)),
      ),
    );
  }

  Widget _pill({required VoidCallback onTap, required Color color, required IconData icon, required String label}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(getHorizontalSize(20)),
      child: Padding(
        padding: getPadding(top: 12, bottom: 12, left: 4, right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: getHorizontalSize(16)),
            SizedBox(width: getHorizontalSize(4)),
            Text(label, style: AppStyle.txtSFProDisplayLight11.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
