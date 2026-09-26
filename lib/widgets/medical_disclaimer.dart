import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/utils/color_constant.dart';
import '../core/utils/size_utils.dart';
import '../theme/app_style.dart';

// App Store Review Guideline 1.4.1 / 5.1.1(ix): a mental-health app must be
// clear that it is a self-help tool, not a diagnosis or a replacement for a
// specialist. Shown on the About screen, the practice screen, the quiz
// result, every purchase screen and the consultation screen.
class MedicalDisclaimer extends StatelessWidget {
  final Color? textColor;
  final bool compact;

  const MedicalDisclaimer({Key? key, this.textColor, this.compact = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = textColor ?? ColorConstant.gray500;
    return Padding(
      padding: getPadding(top: compact ? 6 : 12, bottom: 4),
      child: Text(
        'medical_disclaimer'.tr(),
        textAlign: compact ? TextAlign.center : TextAlign.left,
        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: color),
      ),
    );
  }
}
