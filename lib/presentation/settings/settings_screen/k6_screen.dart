import 'package:flutter/material.dart';
import 'package:get/get.dart' ;
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/utils/string_extension.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:easy_localization/easy_localization.dart' ;

import 'controller.dart';
import 'widgets/card_settings_button_widget.dart';

class K6Screen extends GetWidget {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K6Controller());
    return Scaffold(
        backgroundColor: ColorConstant.gray300,
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
                            Padding(
                                padding: getPadding(top: 64),
                                child: Divider(
                                    height: getVerticalSize(1),
                                    thickness: getVerticalSize(1),
                                    color: ColorConstant.gray50)),
                            Padding(
                                padding: getPadding(top: 25),
                                child: Text("Настройки",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            SizedBox(
                              height: getVerticalSize(78),
                            ),
                            CardSettingsButtonWidget(context,
                                onTap: () => onTapRowrefresh(context),
                                title: 'about_app',
                                svgIcon: ImageConstant.imgRefresh,
                                controller: controller,
                                svgSize: 24),
                            GetBuilder(
                              builder: (K6Controller _c) => CardSettingsButtonWidget(context,
                                  onTap: () => controller.password
                                      ? onTapRowlock(context)
                                      : null,
                                  title: 'passwprd',
                                  svgIcon: ImageConstant.imgLock,
                                  controller: controller,
                                  svgSize: 20,
                                  onSwitch: (value) {
                                    controller.changePasswordState(context);
                                    controller.update();
                                  },
                                  valueForSwitch: controller.password),
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () =>
                                  controller.onTapDataAndRecovery(context),
                              title: 'data_and_recovery',
                              svgIcon: ImageConstant.imgClip,
                              controller: controller,
                              svgSize: 20,
                            ),
                            SizedBox(
                              height: getVerticalSize(21),
                            ),
                            Visibility(
                                child: CardSettingsButtonWidget(context,
                                    onTap: () async =>
                                        await controller.onTapPill(
                                            context,
                                            GlobalKey<
                                                ScaffoldMessengerState>()),
                                    title: 'apoinment_reminders',
                                    svgIcon: ImageConstant.imgPill,
                                    controller: controller,
                                    svgSize: 24,
                                    height: 53)),
                            SizedBox(
                              height: getVerticalSize(21),
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowcheckmark(context),
                              title: 'suggestions',
                              svgIcon: ImageConstant.imgCheckmarkGray800,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowcheckmarkone(context),
                              title: 'report_an_error',
                              svgIcon: ImageConstant.imgCheckmarkGray80024x24,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.reminders),
                              title: 'reminders',
                              svgIcon: ImageConstant.imgClockGray800,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowclose(context),
                              title: 'subscription',
                              svgIcon: ImageConstant.imgClose,
                              controller: controller,
                              svgSize: 24,
                            ),
                            SizedBox(
                              height: getVerticalSize(40),
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.profile),
                              title: 'your_profile',
                              svgIcon: ImageConstant.imgUser,
                              controller: controller,
                              svgSize: 24,
                            ),
                            if(false)
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.selectLanguage),
                              title: 'language',
                              svgIcon: ImageConstant.imgUser,
                              controller: controller,
                              svgSize: 24,
                            ),
                          ])))),
        ),
        bottomNavigationBar:
            CustomBottomBar(onChanged: (BottomBarEnum type) {}));
  }

  onTapRowrefresh(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.aboutApp);
  }

  onTapRowlock(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.setPassword);
  }

  onTapRowcheckmark(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.offers);
  }

  onTapRowcheckmarkone(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.errors);
  }

  onTapRowclose(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.subscription);
  }
}
