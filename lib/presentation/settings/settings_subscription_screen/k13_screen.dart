import 'dart:io' show Platform;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../core/services/apple_billing_service.dart';
import '../../../core/services/google_play_billing_service.dart';
import '../../../core/user_data/user.dart';
import '../../../core/utils/subscription_links.dart';
import '../../../widgets/account_required_sheet.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';
import '../../../theme/app_colors.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K13Screen extends GetWidget {

  @override
  Widget build(BuildContext context) {
    Get.put(K13Controller());
    return GetBuilder(
      builder: (K13Controller c) => Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          body: SafeArea(
            child: SizedBox(
                width: size.width,
                child: SingleChildScrollView(
                    child: Padding(
                        padding: getPadding(left: 16, right: 16, bottom: 5),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CustomAppBar(widget: CustomPopButton(text: 'settings'.tr(),),),

                              Padding(
                                  padding: getPadding(top: 25),
                                  child: Text('subscription'.tr(),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtH1)),
                              Padding(
                                  padding: getPadding(left: 2, top: 57),
                                  child: Row(children: [
                                    Padding(
                                        padding: getPadding(top: 1),
                                        child: Text('current_tariff'.tr(),
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: AppStyle
                                                .txtSFProDisplayLight16)),
                                    Padding(
                                        padding:
                                            getPadding(left: 39, bottom: 1),
                                        child: Text(CurrentUser.user.currentTariff!.name,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: AppStyle
                                                .txtSFProDisplayLight16))
                                  ])),
                              Padding(
                                  padding: getPadding(top: 12),
                                  child: Text(
                                      CurrentUser.user.currentTariff!.description.tr(),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtSFProDisplayLight12Gray80096)),
                              Padding(
                                  padding: getPadding(top: 31),
                                  child: Visibility(
                                    visible: CurrentUser.user.currentTariff!.name != 'Базовый',
                                    child: Text("${'active_until'.tr()} ${CurrentUser.user.currentTariff!.endDate.day} ${CurrentUser.user.currentTariff!.endDate.month.monthInText().toLowerCase()} ${CurrentUser.user.currentTariff!.endDate.year}",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle
                                            .txtSFProDisplayLight14Gray800),
                                  )),
                              // "Управление подпиской" (Stripe Customer
                              // Portal) button removed — subscriptions are
                              // now sold via Google Play Billing, so
                              // management belongs in Google Play itself,
                              // not our Stripe portal.
                              GestureDetector(
                                  onTap: () => onTapBuySubscription(context),
                                  child: Container(
                                      margin: getMargin(top: 83),
                                      padding: getPadding(
                                          left: 5, top: 8, right: 5, bottom: 8),
                                      decoration: AppDecoration
                                          .outlineBluegray80014
                                          .copyWith(
                                          color: ColorConstant.grayLight,

                                          borderRadius: BorderRadiusStyle
                                                  .roundedBorder3),
                                      child: Row(children: [
                                        CustomImageView(
                                            svgPath: ImageConstant.imgCart,
                                            height: getVerticalSize(18),
                                            width: getHorizontalSize(22),
                                            margin:
                                                getMargin(top: 1, bottom: 1)),
                                        Padding(
                                            padding: getPadding(left: 16),
                                            child: Text('buy_subscription'.tr(),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle
                                                    .txtSFProDisplayLight16)),
                                        Spacer(),
                                        CustomImageView(
                                            svgPath: ImageConstant
                                                .imgArrowrightGray700,
                                            height: getVerticalSize(8),
                                            width: getHorizontalSize(4),
                                            margin: getMargin(
                                                top: 6, right: 8, bottom: 6))
                                      ]))),
                              GestureDetector(
                                  onTap: () {
                                    onTapRowgrid(context);
                                  },
                                  child: Container(
                                      margin: getMargin(top: 1),
                                      padding: getPadding(
                                          left: 6, top: 8, right: 6, bottom: 8),
                                      decoration: AppDecoration
                                          .outlineBluegray80014
                                          .copyWith(
                                          color: ColorConstant.grayLight,

                                          borderRadius: BorderRadiusStyle
                                                  .roundedBorder3),
                                      child: Row(children: [
                                        CustomImageView(
                                            svgPath: ImageConstant.imgGrid,
                                            height: getSize(20),
                                            width: getSize(20)),
                                        Padding(
                                            padding: getPadding(left: 17),
                                            child: Text('enter_promo_code'.tr(),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle
                                                    .txtSFProDisplayLight16)),
                                        Spacer(),
                                        CustomImageView(
                                            svgPath: ImageConstant
                                                .imgArrowrightGray700,
                                            height: getVerticalSize(8),
                                            width: getHorizontalSize(4),
                                            margin: getMargin(
                                                top: 6, right: 7, bottom: 6))
                                      ]))),
                              CustomButton(
                                  width: getHorizontalSize(146),
                                  text: 'settings'.tr().toUpperCase(),
                                  margin: getMargin(top: 150),
                                  padding: ButtonPadding.PaddingT8,
                                  prefixWidget: CustomImageView(
                                    margin: getMargin(right: 12),
                                    svgPath: ImageConstant.leftArrow,
                                  ),
                                  onTap: () => onTaptf(context),
                                  alignment: Alignment.center)
                            ])))),
          ),
          bottomNavigationBar:
              CustomBottomBar(onChanged: (BottomBarEnum type) {})),
    );
  }

  // Was the in-app YooKassa purchase flow (Navigator.pushNamed(..,
  // AppRoutes.buySubscription, ..)) — dead now that all billing lives on
  // the website via Stripe. Now opens a plan-choice sheet that links
  // straight to a Payment Link with the account's own email locked in —
  // same reasoning as go_to_new_tariff_widget.dart's two buttons: keeps
  // Stripe's webhook able to match the payment automatically instead of
  // it landing in UnmatchedStripePayments.
  onTapBuySubscription(BuildContext context) {
    // Same already-subscribed guard as onTapRowgrid below — was missing
    // here, so an Orion user tapping "Купить подписку" got sent straight
    // to checkout with no indication they already have an active plan.
    if (CurrentUser.tariffIsOrion()) {
      showDialog(
        context: context,
        builder: (BuildContext context) => CustomMessageBox(
          title: 'RIVA PSY',
          content: 'already_subscribed_until'.tr(args: [
            '${CurrentUser.user.currentTariff!.endDate.day}',
            CurrentUser.user.currentTariff!.endDate.month.monthInText(),
            '${CurrentUser.user.currentTariff!.endDate.year}'
          ]),
        ),
      );
      return;
    }
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
                await _subscribeK13(context,
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
                await _subscribeK13(context,
                    productId: GooglePlayBillingService.yearlyProductId,
                    stripeUrl: yearlyPaymentLinkUrl);
              },
            ),
          ],
        ),
      ),
    );
  }

  onTapRowgrid(BuildContext context) {
    if(CurrentUser.tariffIsOrion()){
      showDialog(
        context: context, builder: (BuildContext context) =>
          CustomMessageBox(
            title: 'RIVA PSY',
            content:
            'already_subscribed_until'.tr(args: ['${CurrentUser.user.currentTariff!.endDate.day}', CurrentUser.user.currentTariff!.endDate.month
                .monthInText(), '${CurrentUser.user.currentTariff!.endDate.year}']),
          ),);
    } else
    Navigator.pushNamed(context, AppRoutes.promo);
  }

  onTaptf(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
}

// Same Android/iOS-vs-rest split as go_to_new_tariff_widget.dart's
// _subscribe — see GooglePlayBillingService/AppleBillingService for why
// Android/iOS go through native store billing instead of the Stripe
// Payment Link now.
Future<void> _subscribeK13(BuildContext context,
    {required String productId, required String stripeUrl}) async {
  final hasAccount = await AccountRequiredSheet.ensure(context,
      reason: 'account_required_subscription_reason'.tr());
  if (!hasAccount || !context.mounted) return;

  if (Platform.isAndroid || Platform.isIOS) {
    try {
      if (Platform.isAndroid) {
        await GooglePlayBillingService.buy(productId);
      } else {
        await AppleBillingService.buy(productId);
      }
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
