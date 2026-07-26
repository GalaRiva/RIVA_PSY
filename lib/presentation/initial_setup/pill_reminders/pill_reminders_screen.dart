import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/presentation/initial_setup/send_pushes_screen/send_pushe_screen.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills_add_bottom_sheet/settings_pills_add_bottom_sheet.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../core/models/tariff_model.dart';
import '../../../core/user_data/user.dart';
import '../recomendation_buy_tariff_screen/recomendation_buy_tariff_screen.dart';
import '../set_reminders_screen/k3_screen.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class PillRemindersScreen extends StatelessWidget {
  TextEditingController group993Controller = TextEditingController();

  TextEditingController group995Controller = TextEditingController();

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: ColorConstant.gray300,
        resizeToAvoidBottomInset: false,
        body: Container(
            height: size.height,
            width: double.maxFinite,
            padding: getPadding(left: 6, right: 6),
            decoration: AppDecoration.txt,
            child: Align(alignment: Alignment.center,
                child: Container(margin: getMargin(
                    left: 1, top: 64),
                    padding: getPadding(left: 11,
                        top: 27,
                        right: 11,
                        bottom: 27),
                    decoration: AppDecoration.outlineWhiteA700
                        .copyWith(
                        borderRadius: BorderRadiusStyle
                            .roundedBorder3),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment
                            .start,
                        children: [
                          Align(alignment: Alignment.centerLeft,
                              child: Text('reminders'.tr(),
                                  overflow: TextOverflow
                                      .ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtH1)),
                          Padding(padding: getPadding(
                              top: 10, right: 5),
                              child: Text(
                                  'can_set_reminders_time'.tr(),
                                  maxLines: null,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtH2)),
                          CustomImageView(
                              svgPath: ImageConstant.pillReminders,
                              height: getVerticalSize(256),
                              width: getHorizontalSize(143),
                              margin: getMargin(top: 23)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              CustomButton(
                                  height: getVerticalSize(32),
                                  width: size.width / 2 - 60,
                                  text: 'later'.tr().toUpperCase(),
                                  margin: getMargin(
                                      top: 14, bottom: 6),
                                  variant: ButtonVariant
                                      .OutlineBluegray60014,
                                  onTap: () {
                                    SharedPrefs.sharedPreferences.setBool('pill_reminders', true);

                                    Navigator.pop(context);

                                  }),
                              CustomButton(
                                  height: getVerticalSize(32),
                                  width: size.width / 2 - 60,
                                  text: 'setup'.tr().toUpperCase(),
                                  margin: getMargin(
                                      top: 14, bottom: 6),
                                  variant: ButtonVariant
                                      .OutlineBluegray60014,
                                  onTap: () => onTapOne(context)),
                            ],
                          )
                        ])))));
  }

  onTapOne(BuildContext context) {
    SharedPrefs.sharedPreferences.setBool('pill_reminders', true);

    Navigator.pop(context);
      showModalBottomSheet(
          elevation: 0,
          backgroundColor: ColorConstant.gray300.withOpacity(1),

          context: context, builder: (_) {
        return PillsAddBottomSheet();
      });



  }
}