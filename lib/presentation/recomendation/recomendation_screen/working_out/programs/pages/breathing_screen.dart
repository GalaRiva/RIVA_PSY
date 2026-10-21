import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/helpline_link.dart';

import '../widgets/breath_circle.dart';
import '../widgets/course_ui.dart';

// "10 длинных выдохов" on its own: the breathing circle without any program
// around it. Opened from the Panic / Affect tab, and usable by anyone — no
// subscription, no account, nothing is saved or scored.
class BreathingScreen extends StatelessWidget {
  const BreathingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CourseTextScale(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: getPadding(left: 22, right: 22, top: 10, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                    tooltip: 'back'.tr(),
                    onImage: false),
                SizedBox(height: getVerticalSize(22)),
                Text('breathing_screen_title'.tr(),
                    style: AppStyle.txtH1
                        .copyWith(color: AppColors.textPrimary, fontSize: getFontSize(28), height: 1.15)),
                SizedBox(height: getVerticalSize(12)),
                Text('breathing_screen_body'.tr(),
                    style: AppStyle.txtSFProDisplayLight16.copyWith(
                        color: AppColors.textPrimary.withOpacity(0.78), height: 1.6, fontSize: getFontSize(17))),
                Center(child: const BreathCircle(inhale: 4, exhale: 6, cycles: 10)),
                SizedBox(height: getVerticalSize(22)),
                Text('breathing_dizzy_note'.tr(),
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary, height: 1.5)),
                const HelplineLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
