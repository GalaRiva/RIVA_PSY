import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../core/user_data/user.dart';
import '../../../core/utils/subscription_links.dart';
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
                              GestureDetector(
                                  onTap: () => onTapManageSubscription(context),
                                  child: Container(
                                      margin: getMargin(top: 83),
                                      padding: getPadding(
                                          left: 5, top: 8, right: 5, bottom: 8),
                                      decoration: AppDecoration.outlineBluegray80014
                                          .copyWith(
                                        color: ColorConstant.grayLight,
                                              borderRadius:
                                                  BorderRadiusStyle.roundedBorder3),
                                      child: Row(
                                          children: [
                                            CustomImageView(
                                                svgPath: ImageConstant.imgCart,
                                                height: getVerticalSize(18),
                                                width: getHorizontalSize(22),
                                                margin:
                                                    getMargin(top: 1, bottom: 1)),
                                            Padding(
                                                padding: getPadding(left: 16),
                                                child: Text(
                                                    'manage_subscription_on_website'.tr(),
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
                                  onTap: () => onTapBuySubscription(context),
                                  child: Container(
                                      margin: getMargin(top: 1),
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

  // Points at the Firebase Hosting magic-link page in front of Stripe's
  // Customer Portal (functions/index.js: createPortalSession). Update this
  // one line if the page ever moves to a different URL.
  static const String manageSubscriptionUrl = 'https://rigel-psy-9361c.web.app';

  onTapManageSubscription(BuildContext context) async {
    await launchUrl(Uri.parse(manageSubscriptionUrl), mode: LaunchMode.externalApplication);
  }

  // Was the in-app YooKassa purchase flow (Navigator.pushNamed(..,
  // AppRoutes.buySubscription, ..)) — dead now that all billing lives on
  // the website via Stripe. Same "static link out" pattern as
  // onTapManageSubscription above, not a new mechanism.
  onTapBuySubscription(BuildContext context) async {
    await launchUrl(Uri.parse(subscriptionUrlForLocale(context)), mode: LaunchMode.externalApplication);
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
