import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/presentation/initial_setup/send_pushes_screen/send_pushe_screen.dart';
import 'controller.dart';
import '../../../core/services/workmanager/workmanager_service.dart';
import '../../../core/user_data/user.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../theme/app_colors.dart';

class K3Screen extends GetWidget<K3Controller> {
  final controller = Get.put(K3Controller());
  int quantity = 1;

  K3Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: Container(
            width: size.width,
            height: size.height,
            decoration: AppDecoration.txt,
            child: Container(
                alignment: Alignment.center,
                padding: getPadding(left: 6, top: 40, right: 6, bottom: 40),
                child: SingleChildScrollView(
                  child: Container(
                      padding:
                          getPadding(left: 20, top: 26, right: 20, bottom: 24),
                      decoration: AppDecoration.outlineWhiteA700
                          .copyWith(borderRadius: BorderRadiusStyle.roundedBorder3),
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('notifications'.tr(),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtH1),
                            Padding(
                              padding: getPadding(top: 16),
                              child: Container(
                                padding: getPadding(
                                    left: 14, top: 12, right: 14, bottom: 12),
                                decoration: BoxDecoration(
                                  color: ColorConstant.cyan700.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded,
                                        color: ColorConstant.cyan700,
                                        size: getSize(18)),
                                    SizedBox(width: getHorizontalSize(10)),
                                    Expanded(
                                      child: Text(
                                        'reminders_recommendation'.tr(),
                                        style: AppStyle.txtSFProDisplayLight12
                                            .copyWith(
                                                color: ColorConstant.cyan700,
                                                height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: getPadding(top: 22),
                              child: GetBuilder<K3Controller>(
                                builder: (_) => Column(
                                  children:
                                      List.generate(controller.list.length, (index) {
                                    final item = controller.list[index];
                                    return Padding(
                                      padding: getPadding(bottom: 12),
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          if (!item.selected) {
                                            for (var i in controller.list)
                                              i.selected = false;
                                            item.selected = true;
                                            quantity = item.quantity;
                                            controller.update();
                                          }
                                        },
                                        child: Container(
                                          padding: getPadding(
                                              left: 16,
                                              top: 14,
                                              right: 16,
                                              bottom: 14),
                                          decoration: BoxDecoration(
                                            color: item.selected
                                                ? ColorConstant.cyan700
                                                    .withOpacity(0.08)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: item.selected
                                                  ? ColorConstant.cyan700
                                                  : ColorConstant.fromHex(
                                                      '#E4E8E8'),
                                              width: item.selected ? 1.6 : 1,
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: getSize(22),
                                                height: getSize(22),
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: item.selected
                                                      ? ColorConstant.cyan700
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: item.selected
                                                        ? ColorConstant.cyan700
                                                        : ColorConstant.fromHex(
                                                            '#BCBFD1'),
                                                    width: 1.6,
                                                  ),
                                                ),
                                                child: item.selected
                                                    ? Icon(Icons.check_rounded,
                                                        color: Colors.white,
                                                        size: getSize(14))
                                                    : null,
                                              ),
                                              SizedBox(
                                                  width: getHorizontalSize(14)),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          _optionTitleKey(
                                                                  item.quantity)
                                                              .tr(),
                                                          style: AppStyle
                                                              .txtSFProDisplayRegular14
                                                              .copyWith(
                                                            color:
                                                                ColorConstant
                                                                    .gray800,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                        if (item.quantity ==
                                                            1) ...[
                                                          SizedBox(
                                                              width:
                                                                  getHorizontalSize(
                                                                      8)),
                                                          Container(
                                                            padding: getPadding(
                                                                left: 8,
                                                                top: 2,
                                                                right: 8,
                                                                bottom: 2),
                                                            decoration:
                                                                BoxDecoration(
                                                              color:
                                                                  ColorConstant
                                                                      .cyan700,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                            ),
                                                            child: Text(
                                                              'reminders_recommended_badge'
                                                                  .tr(),
                                                              style: AppStyle
                                                                  .txtSFProDisplayRegular11
                                                                  .copyWith(
                                                                color:
                                                                    Colors.white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ],
                                                    ),
                                                    Text(
                                                      _optionSubtitleKey(
                                                              item.quantity)
                                                          .tr(),
                                                      style: AppStyle
                                                          .txtSFProDisplayLight12
                                                          .copyWith(
                                                              color:
                                                                  ColorConstant
                                                                      .gray500),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            ),
                            Padding(
                              padding: getPadding(top: 20),
                              child: Center(
                                child: SizedBox(
                                  height: getVerticalSize(150),
                                  width: getHorizontalSize(107),
                                  child: Stack(
                                    alignment: Alignment.topLeft,
                                    children: [
                                      CustomImageView(
                                          svgPath: ImageConstant.imgVectorGray50,
                                          height: getVerticalSize(53),
                                          width: getHorizontalSize(33),
                                          alignment: Alignment.topRight,
                                          margin:
                                              getMargin(top: 22, right: 28)),
                                      CustomImageView(
                                          svgPath: ImageConstant.imgVectorTeal200,
                                          height: getVerticalSize(147),
                                          width: getHorizontalSize(42),
                                          alignment: Alignment.topLeft,
                                          margin: getMargin(left: 5)),
                                      CustomImageView(
                                          svgPath:
                                              ImageConstant.imgVectorGray5039x41,
                                          height: getVerticalSize(39),
                                          width: getHorizontalSize(41),
                                          alignment: Alignment.topLeft,
                                          margin: getMargin(top: 20)),
                                      CustomImageView(
                                          svgPath: ImageConstant.imgGroupGray800,
                                          height: getVerticalSize(144),
                                          width: getHorizontalSize(103),
                                          alignment: Alignment.centerRight),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: getPadding(top: 16),
                                child: Row(children: [
                                  Text('change_time'.tr(),
                                      style: TextStyle(
                                          color: ColorConstant.gray800,
                                          fontSize: getFontSize(12),
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w300)),
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                        context, AppRoutes.settings),
                                    child: Text('in_settings'.tr(),
                                        style: TextStyle(
                                            color: ColorConstant.cyan700,
                                            fontSize: getFontSize(12),
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w300,
                                            decoration:
                                                TextDecoration.underline)),
                                  )
                                ])),
                            Padding(
                              padding: getPadding(top: 20),
                              child: CustomButton(
                                  height: getVerticalSize(44),
                                  onTap: () {
                                    onTapColumnten(context, true);
                                  },
                                  width: double.infinity,
                                  text: 'continue'.tr().toUpperCase(),
                                  variant: ButtonVariant.Cyan,
                                  fontStyle: ButtonFontStyle.White16,
                                  alignment: Alignment.center),
                            ),
                          ])),
                ))));
  }

  String _optionTitleKey(int quantity) {
    switch (quantity) {
      case 1:
        return 'reminders_option_daily_title';
      case 2:
        return 'reminders_option_twice_title';
      default:
        return 'reminders_option_none_title';
    }
  }

  String _optionSubtitleKey(int quantity) {
    switch (quantity) {
      case 1:
        return 'reminders_option_daily_subtitle';
      case 2:
        return 'reminders_option_twice_subtitle';
      default:
        return 'reminders_option_none_subtitle';
    }
  }

  onTapColumnten(BuildContext context, [bool continu = false]) async {
    CurrentUser.user.reminderTime = quantity;
    if (quantity > 0) {
      await _generateReminderTime();
    } else {
      await CurrentUser.repo.setLocalUserData(reminderTimeInStr: <String>[]);
    }
    await CurrentUser.repo.setLocalUserData(reminderTime: quantity);
    SharedPrefs.sharedPreferences.setBool('set_reminders', true);
    Navigator.pop(context);
    if (continu) {
      // Always continues to the OS notification-permission ask next, even
      // if "Не уведомлять" was picked here — that permission also covers
      // insight nudges, pill reminders, etc., not just diary reminders, so
      // skipping it here would risk losing it for those too.
      if (SharedPrefs.sharedPreferences.getBool('send_pushes') == null)
        showDialog(
            useSafeArea: false,
            context: context,
            builder: (_) => SendPushesScreen());
      // "Тариф" recommendation popup (RecommendationBuyTariffScreen) removed
      // from this chain by request — see the matching removal in
      // main_screen/controller.dart's openMessages() for why.
    }
  }

  _generateReminderTime() async {
    var lastNotifications = <String>[];

    while (lastNotifications.length != quantity)
      lastNotifications.add((Random().nextInt(20)).timeFormatted() +
          ':' +
          (Random().nextInt(59)).timeFormatted());
    CurrentUser.repo.setLocalUserData(reminderTimeInStr: lastNotifications);
    await WorkManagerService().initService();
  }
}
