import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/utils/color_constant.dart';
import '../core/utils/size_utils.dart';
import '../routes/app_routes.dart';
import '../theme/app_style.dart';

// Required by App Store Review Guideline 3.1.2 (auto-renewing subscriptions
// must show their terms, with functional links to Privacy Policy and Terms
// of Use, on or immediately accessible from the purchase screen itself —
// not just somewhere in Settings) and good practice for Google Play too.
// Reuses the same legal text already shown in Settings -> About App
// (K7Screen/AppRoutes.aboutApp) instead of duplicating it here — both
// links go to that same screen, which has both sections.
class SubscriptionTermsDisclosure extends StatelessWidget {
  // Screens with a dark background (e.g. the quiz paywall) pass lighter
  // colors here — the default gray500/cyan700 pair is tuned for light
  // backgrounds and is barely legible on dark ones.
  final Color? textColor;
  final Color? linkColor;

  const SubscriptionTermsDisclosure({Key? key, this.textColor, this.linkColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color resolvedTextColor = textColor ?? ColorConstant.gray500;
    final Color resolvedLinkColor = linkColor ?? ColorConstant.cyan700;
    return Padding(
      padding: getPadding(top: 12, bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'subscription_terms_disclosure'.tr(),
            textAlign: TextAlign.center,
            style: AppStyle.txtSFProDisplayRegular11.copyWith(color: resolvedTextColor),
          ),
          SizedBox(height: getVerticalSize(6)),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.aboutApp),
                child: Text(
                  'privacy_policy'.tr(),
                  style: AppStyle.txtSFProDisplayRegular11.copyWith(
                    color: resolvedLinkColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Padding(
                padding: getPadding(left: 6, right: 6),
                child: Text('•',
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(color: resolvedTextColor)),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, AppRoutes.aboutApp),
                child: Text(
                  'terms_of_use'.tr(),
                  style: AppStyle.txtSFProDisplayRegular11.copyWith(
                    color: resolvedLinkColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
