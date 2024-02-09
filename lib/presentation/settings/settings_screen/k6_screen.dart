import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';

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
                                title: 'О приложении',
                                svgIcon: ImageConstant.imgRefresh,
                                controller: controller,
                                svgSize: 24),
                            GetBuilder(
                              builder: (K6Controller _c) => CardSettingsButtonWidget(context,
                                  onTap: () => controller.password
                                      ? onTapRowlock(context)
                                      : null,
                                  title: 'Пароль',
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
                              title: 'Данные и востановление',
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
                                    title: 'Напоминания о приеме',
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
                              title: 'Предложение по улучшению',
                              svgIcon: ImageConstant.imgCheckmarkGray800,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowcheckmarkone(context),
                              title: 'Сообщить об ошибке',
                              svgIcon: ImageConstant.imgCheckmarkGray80024x24,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.reminders),
                              title: 'Напоминания',
                              svgIcon: ImageConstant.imgClockGray800,
                              controller: controller,
                              svgSize: 24,
                            ),
                            CardSettingsButtonWidget(
                              context,
                              onTap: () => onTapRowclose(context),
                              title: 'Подписка',
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
                              title: 'Ваш профиль',
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
