import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../core/user_data/user.dart';
import '../../../core/utils/build_info.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';
import 'drop_text_widget.dart';

class K7Screen extends StatelessWidget {
  TextEditingController group1006Controller = TextEditingController();

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = K7Controller();
    return Scaffold(
        backgroundColor: ColorConstant.gray300,
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
                            Container(
                                height: getVerticalSize(12),
                                width: getHorizontalSize(328),
                                margin: getMargin(top: 39),
                                child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child:  CustomPopButton( text: 'settings'.tr(),)),
                                      Align(
                                          alignment:
                                          Alignment.bottomCenter,
                                          child: Padding(
                                              padding:
                                              getPadding(bottom: 2, top: 22),
                                              child: SizedBox(
                                                  width:
                                                  getHorizontalSize(
                                                      MediaQuery.of(context).size.width - 32),
                                                  child: Divider(
                                                      height:
                                                      getVerticalSize(
                                                          1),
                                                      thickness:
                                                      getVerticalSize(
                                                          1),
                                                      color: ColorConstant
                                                          .gray50))))
                                    ])),
                            Padding(
                                padding: getPadding(top: 25),
                                child: Text('about_app'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Padding(
                                padding: getPadding(left: 4, top: 82),
                                child: DropTextWidget(model: controller.termsOfUse,)),
                            Padding(
                                padding: getPadding(left: 4, top: 96),
                                child: DropTextWidget(model: controller.privacyPolicy,)),
                            Padding(
                                padding: getPadding(left: 4, top: 16),
                                child: Text(
                                    'build ${BuildInfo.gitHash} · ${BuildInfo.buildTime}',
                                    style: AppStyle.txtSFProDisplayLight10Gray800)),
                            // Temporary on-screen tariff/session diagnostic —
                            // lets the account's actual runtime state be read
                            // off a screenshot when USB/logcat access isn't
                            // available. See PROJECT_CONTEXT.md, the
                            // "tariff says Орион but app won't unlock" thread.
                            Padding(
                                padding: getPadding(left: 4, top: 12),
                                child: SelectableText(
                                    'email: ${CurrentUser.user.email}\n'
                                    'userId(): ${CurrentUser.repo.userId()}\n'
                                    'currentTariff: ${CurrentUser.user.currentTariff?.name}\n'
                                    'tariffIsOrion(): ${CurrentUser.tariffIsOrion()}',
                                    style: AppStyle.txtSFProDisplayLight10Gray800)),
                            CustomButton(
                                height: getVerticalSize(32),
                                width: getHorizontalSize(146),
                                text: AppRoutes.currentRoute == AppRoutes.settings? 'settings'.tr().toUpperCase() : 'back'.tr().toUpperCase(),
                                margin: getMargin(top: 154),
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
        AppRoutes.currentRoute == AppRoutes.settings?CustomBottomBar(onChanged: (BottomBarEnum type) {}):null);
  }

  onTaptf(BuildContext context) {
    Navigator.pop(context);
  }
}
