import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/presentation/initial_setup/send_pushes_screen/send_pushe_screen.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../core/services/google_play_billing_service.dart';
import '../../../core/user_data/user.dart';
import '../../../core/utils/subscription_links.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/account_required_sheet.dart';
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
                              onTap: () => _openPlanChooser(context),
                              margin: getMargin(
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

  // Same reasoning as go_to_new_tariff_widget.dart / k13_screen.dart: opens
  // the Payment Link directly with the account's own email locked in, so
  // Stripe's webhook can match the payment automatically instead of it
  // landing in UnmatchedStripePayments.
  void _openPlanChooser(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background.withOpacity(1),
      elevation: 0,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: getPadding(left: 16, right: 16, top: 24, bottom: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              height: getVerticalSize(54),
              width: double.maxFinite,
              text: 'subscribe_monthly'.tr().toUpperCase(),
              textIsFitted: true,
              onTap: () async {
                Navigator.pop(context);
                await _subscribeBuyTariff(context,
                    productId: GooglePlayBillingService.monthlyProductId,
                    stripeUrl: monthlyPaymentLinkUrl);
              },
            ),
            SizedBox(height: getVerticalSize(12)),
            CustomButton(
              height: getVerticalSize(54),
              width: double.maxFinite,
              text: 'subscribe_yearly'.tr().toUpperCase(),
              textIsFitted: true,
              onTap: () async {
                Navigator.pop(context);
                await _subscribeBuyTariff(context,
                    productId: GooglePlayBillingService.yearlyProductId,
                    stripeUrl: yearlyPaymentLinkUrl);
              },
            ),
          ],
        ),
      ),
    );
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
      }
      // PillRemindersScreen popup removed from this chain by request.
    }
  }
}

Future<void> _subscribeBuyTariff(BuildContext context,
    {required String productId, required String stripeUrl}) async {
  final hasAccount = await AccountRequiredSheet.ensure(context,
      reason: 'account_required_subscription_reason'.tr());
  if (!hasAccount || !context.mounted) return;

  if (Platform.isAndroid) {
    try {
      await GooglePlayBillingService.buy(productId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось начать покупку: $e')),
        );
      }
    }
  } else {
    await launchUrl(
        Uri.parse(paymentLinkUrlForEmail(stripeUrl, CurrentUser.user.email)),
        mode: LaunchMode.externalApplication);
  }
}