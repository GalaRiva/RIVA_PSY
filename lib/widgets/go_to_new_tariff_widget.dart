import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riva_psy/core/app_export.dart';

import '../core/services/apple_billing_service.dart';
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
      // Was a 3-stop gradient where only the top ~1/3 was actually
      // translucent (0.5) and the rest fully opaque — meant to look like a
      // teaser over real content, but in practice covered almost the whole
      // area with solid color. One flat, more transparent fill throughout.
      decoration: BoxDecoration(
        color: ColorConstant.gray200.withOpacity(0.72),
      ),
      child: Container(
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
// iOS goes through AppleBillingService for the same reason. Non-Android/iOS
// platforms keep the original Stripe Payment Link, which is still how the
// future PWA/website checkout is meant to work.
Future<void> _subscribe(BuildContext context,
    {required String productId, required String stripeUrl}) async {
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
