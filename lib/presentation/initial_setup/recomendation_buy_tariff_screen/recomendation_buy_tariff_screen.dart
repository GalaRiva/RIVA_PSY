import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/presentation/initial_setup/pill_reminders/pill_reminders_screen.dart';
import 'package:riva_psy/presentation/initial_setup/send_pushes_screen/send_pushe_screen.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../core/utils/subscription_links.dart';
import '../../../theme/app_colors.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class RecommendationBuyTariffScreen extends StatelessWidget {
  TextEditingController group993Controller = TextEditingController();

  TextEditingController group995Controller = TextEditingController();

  @override Widget build(BuildContext context) {
    return Scaffold(backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: Center(
          child: Container(
              height: size.height,
              width: double.maxFinite,
              padding: getPadding(left: 6, right: 6),
              decoration: AppDecoration.txt,
              child: Center(
                child: Container(margin: getMargin(),
                    padding: getPadding(left: 11,
                        top: 27,
                        right: 11,),
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
                              child: Text('tariff_title'.tr(),
                                  overflow: TextOverflow
                                      .ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtH1)),
                          Padding(padding: getPadding(
                              top: 10, right: 5),
                              child: Text(
                                  'for_storing_data_go_to_orion'.tr(),
                                  maxLines: null,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtH2)),
                          CustomImageView(
                              svgPath: ImageConstant.imgGroup74,
                              height: getVerticalSize(138),
                              width: getHorizontalSize(143),
                              margin: getMargin(top: 23)),
                          CustomButton(
                              height: getVerticalSize(54),
                              text: "${'go_to_tariff'.tr()}${'orion_tariff_name'.tr()}"
                                  .toUpperCase(),
                              onTap: () async {
                                // Was Navigator.pushNamed(.., AppRoutes.buySubscription, ..)
                                // — in-app YooKassa flow, retired.
                                await launchUrl(Uri.parse(subscriptionUrlForLocale(context)),
                                    mode: LaunchMode.externalApplication);
                              },margin: getMargin(
                              left: 18, top: 19, right: 18),
                              variant: ButtonVariant
                                  .OutlineBluegray60014,
                              padding: ButtonPadding
                                  .PaddingAll19,
                              fontStyle: ButtonFontStyle
                                  .SFProDisplayRegular12Cyan700),
                          Padding(padding: getPadding(top: 64),
                              child: Text(
                                  'in_free_version'.tr(),
                                  maxLines: null,
                                  textAlign: TextAlign.left,
                                  style: AppStyle
                                      .txtSFProDisplayThin12)),
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
                                  onTap: () =>       onTapOne(context, false)),
                              CustomButton(
                                  height: getVerticalSize(32),
                                  width: size.width / 2 - 60,
                                  text: 'continue'.tr().toUpperCase(),
                                  margin: getMargin(
                                      top: 14, bottom: 6),
                                  variant: ButtonVariant
                                      .OutlineBluegray60014,
                                  onTap: () => onTapOne(context, true)),
                            ],
                          )
                        ])),
              )),
        ));
  }

  onTapOne(BuildContext context, [bool continu = false]) {
    SharedPrefs.sharedPreferences.setBool('recommendation_buy_tariff', true);
    Navigator.pop(context);
    if(continu) {
      if (SharedPrefs.sharedPreferences.getBool('send_pushes') == null) {
        showDialog(
            useSafeArea: false,
            context: context,
            builder: (_) => SendPushesScreen());
      } else if (SharedPrefs.sharedPreferences.getBool('pill_reminders') ==
          null) {
        showDialog(
            useSafeArea: false,
            context: context,
            builder: (_) => PillRemindersScreen());
      }
    }
  }
}