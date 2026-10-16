import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/crisis_links.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_pop_button.dart';

// Settings -> "Мне сейчас тяжело": for someone with thoughts of self-harm or
// in danger. Deliberately only this — straight to a call and to the numbers
// by country. The "stop and ground yourself" instruction during an exercise
// is a different thing and lives in the pause sheet at the end of the Path.
// Calm page, no alarm colours.
class HelpNowScreen extends StatelessWidget {
  const HelpNowScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: getPadding(left: 16, right: 16, top: 12, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPopButton(text: 'settings'.tr()),
              SizedBox(height: getVerticalSize(22)),
              Text('helpline_settings'.tr(), style: AppStyle.txtH1),
              SizedBox(height: getVerticalSize(16)),
              Text('helpnow_crisis_intro'.tr(),
                  style: AppStyle.txtSFProDisplayLight16
                      .copyWith(color: ColorConstant.gray800, height: 1.5)),
              SizedBox(height: getVerticalSize(22)),
              CustomButton(
                height: getVerticalSize(48),
                width: double.infinity,
                text: 'helpnow_call_112'.tr().toUpperCase(),
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: () => launchUrl(Uri.parse('tel:112')),
              ),
              SizedBox(height: getVerticalSize(8)),
              Text('helpline_emergency'.tr(),
                  style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
              SizedBox(height: getVerticalSize(20)),
              CustomButton(
                height: getVerticalSize(48),
                width: double.infinity,
                text: 'helpnow_numbers_btn'.tr().toUpperCase(),
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: () => openHelplines(context),
              ),
              SizedBox(height: getVerticalSize(18)),
              Text('helpnow_not_emergency'.tr(),
                  style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
            ],
          ),
        ),
      ),
    );
  }
}
