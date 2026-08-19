import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riva_psy/core/app_export.dart';

import '../core/services/google_play_billing_service.dart';
import '../core/user_data/user.dart';
import '../core/utils/subscription_links.dart';
import 'custom_button.dart';
import '../theme/app_icons.dart';

class GoToNewTariffWidget extends StatelessWidget {
  final VoidCallback? onSecondButtonTap;
  final double? height;
  final bool goToFreeRecommendation;
  const GoToNewTariffWidget({Key? key, this.height, this.onSecondButtonTap, this.goToFreeRecommendation = true}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? size.height - (240 + 53),
      width: size.width,
decoration: BoxDecoration(
  gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
    ColorConstant.gray200.withOpacity(0.5),
    ColorConstant.gray200,
    ColorConstant.gray200,
  ])

),      child: Container(
  margin: getMargin(bottom: 40),
  child: SingleChildScrollView(
    child: Column(
mainAxisAlignment: MainAxisAlignment.end,          children: [
              SizedBox(
                width: getHorizontalSize(
                  size.width - 34,
                ),
                child: Text(
                  'get_full_access'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyle.txtSFProDisplayLight16,
                ),
              ),
              SizedBox(height: 20,),
              SvgPicture.asset(ImageConstant.tariffImage, width: 140,),
      SizedBox(height: 20,),
      CustomButton(
                height: getVerticalSize(
                  54,
                ),
                width: getHorizontalSize(
                  288,
                ),
                text: 'subscribe_monthly'.tr().toUpperCase(),
                textIsFitted: true,
                onTap: () => _subscribe(context,
                    productId: GooglePlayBillingService.monthlyProductId,
                    stripeUrl: monthlyPaymentLinkUrl),
                fontStyle: ButtonFontStyle.SFProDisplayRegular12Cyan700,
                alignment: Alignment.center,
              ),
      SizedBox(height: 12,),
      CustomButton(
                height: getVerticalSize(
                  54,
                ),
                width: getHorizontalSize(
                  288,
                ),
                text: 'subscribe_yearly'.tr().toUpperCase(),
                textIsFitted: true,
                onTap: () => _subscribe(context,
                    productId: GooglePlayBillingService.yearlyProductId,
                    stripeUrl: yearlyPaymentLinkUrl),
                fontStyle: ButtonFontStyle.SFProDisplayRegular12Cyan700,
                alignment: Alignment.center,
              ),
              if(goToFreeRecommendation)
              CustomButton(
                height: getVerticalSize(
                  54,
                ),
                width: getHorizontalSize(
                  288,
                ),
                margin: getMargin(top: 40),
                suffixWidget: Padding(
                  padding: getPadding(left: 10),
                  child: Icon(AppIcons.caretRight, size: getSize(10), color: ColorConstant.deepPurple600,),
                ),
                text: 'to_free_recommendations'.tr().toUpperCase(),
                textIsFitted: true,
                onTap: () async {
                  if (onSecondButtonTap == null) {
                    Navigator.pushNamed(context, AppRoutes.recommendations);
                    AppRoutes.currentRoute = AppRoutes.recommendations;
                  } else onSecondButtonTap!();
                },
                alignment: Alignment.center,
              ),
              SizedBox(height: 13,),
              SizedBox(
                width: getHorizontalSize(
    280,
    ),
                  child: Text('in_free_version'.tr(), style: AppStyle.txtSFProDisplayLight12Gray800,)),
              SizedBox(height: 27,)
            ],
          ),
  ),
),
    );
  }
}

// Android buys through Google Play Billing (see GooglePlayBillingService for
// why — Stripe's "alternative payment system" registration in Play Console
// requires a registered company, which this account doesn't have yet).
// Non-Android platforms keep the original Stripe Payment Link, which is
// still how the future PWA/website checkout is meant to work.
Future<void> _subscribe(BuildContext context,
    {required String productId, required String stripeUrl}) async {
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
