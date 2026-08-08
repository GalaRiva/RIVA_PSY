import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/core/utils/shared_prefs.dart';
import 'package:riva_psy/presentation/initial_setup/pill_reminders/pill_reminders_screen.dart';
import 'package:riva_psy/presentation/initial_setup/recomendation_buy_tariff_screen/recomendation_buy_tariff_screen.dart';
import 'package:riva_psy/presentation/initial_setup/send_pushes_screen/send_pushe_screen.dart';
import 'controller.dart';
import '../../../core/services/workmanager/workmanager_service.dart';
import '../../../core/user_data/user.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../widgets/custom_checkbox_notification.dart';
import '../../../theme/app_colors.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K3Screen extends GetWidget<K3Controller> {
  TextEditingController group928Controller = TextEditingController();

  TextEditingController group930Controller = TextEditingController();
  final controller = Get.put(K3Controller());
  int quantity = 1;

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
                padding:
                    getPadding(left: 6, top: 64, right: 6, bottom: 64),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          padding: getPadding(
                              left: 11, top: 26, right: 11, bottom: 26),
                          decoration: AppDecoration.outlineWhiteA700
                              .copyWith(
                                  borderRadius:
                                      BorderRadiusStyle.roundedBorder3),
                          child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.start,
                              children: [
                                Text('notifications'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1),
                                Padding(
                                    padding:
                                        getPadding(top: 10, right: 22),
                                    child: Text(
                                        'select_reminder_time'.tr(),
                                        maxLines: null,
                                        textAlign: TextAlign.left,
                                        style: AppStyle.txtH2)),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                        padding: getPadding(
                                            left: 30,
                                            top: 65,
                                            right: 11),
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: getPadding(
                                                      top: 8,
                                                      bottom: 7),
                                                  child: GetBuilder(
                                                    builder: (K3Controller
                                                            _controller) =>
                                                        SizedBox(
                                                      height:
                                                          (40 + 15) * 5,
                                                      width: 150,
                                                      child: ListView
                                                          .builder(
                                                        physics:
                                                            NeverScrollableScrollPhysics(),
                                                        itemCount:
                                                            controller
                                                                .list
                                                                .length,
                                                        itemBuilder:
                                                            (BuildContext
                                                                    context,
                                                                int index) {
                                                          return Padding(
                                                            padding: const EdgeInsets
                                                                    .only(
                                                                bottom:
                                                                    40),
                                                            child: GestureDetector(
                                                              behavior: HitTestBehavior.opaque,
                                                              onTap: () {
                                                                if (!controller.list[index].selected) {
                                                                  for (var item in controller.list) item.selected = false;
                                                                  controller.list[index].selected = true;
                                                                  quantity = controller.list[index].quantity;
                                                                  controller.update();
                                                                }
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment.center,
                                                                children: [
                                                                  CustomCheckboxNotification(controller.list[index].selected),
                                                                  Padding(
                                                                      padding: getPadding(left: 18, top: 1),
                                                                      child: Text("${controller.list[index].quantity} ${'times_per_day'.tr()}", overflow: TextOverflow.ellipsis, textAlign: TextAlign.left, style: controller.list[index].selected ? AppStyle.txtSFProDisplayLight12 : AppStyle.txtSFProDisplayLight12Gray500))
                                                                ]),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                    height:
                                                        getVerticalSize(
                                                            203),
                                                    width:
                                                        getHorizontalSize(
                                                            145),
                                                    child: Stack(
                                                        alignment:
                                                            Alignment
                                                                .topLeft,
                                                        children: [
                                                          CustomImageView(
                                                              svgPath:
                                                                  ImageConstant
                                                                      .imgVectorGray50,
                                                              height:
                                                                  getVerticalSize(
                                                                      53),
                                                              width:
                                                                  getHorizontalSize(
                                                                      33),
                                                              alignment:
                                                                  Alignment
                                                                      .topRight,
                                                              margin: getMargin(
                                                                  top:
                                                                      30,
                                                                  right:
                                                                      38)),
                                                          CustomImageView(
                                                              svgPath:
                                                                  ImageConstant
                                                                      .imgVectorTeal200,
                                                              height:
                                                                  getVerticalSize(
                                                                      196),
                                                              width:
                                                                  getHorizontalSize(
                                                                      56),
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              margin: getMargin(
                                                                  left:
                                                                      7)),
                                                          CustomImageView(
                                                              svgPath:
                                                                  ImageConstant
                                                                      .imgVectorGray5039x41,
                                                              height:
                                                                  getVerticalSize(
                                                                      39),
                                                              width:
                                                                  getHorizontalSize(
                                                                      41),
                                                              alignment:
                                                                  Alignment
                                                                      .topLeft,
                                                              margin: getMargin(
                                                                  top:
                                                                      27)),
                                                          CustomImageView(
                                                              svgPath:
                                                                  ImageConstant
                                                                      .imgGroupGray800,
                                                              height:
                                                                  getVerticalSize(
                                                                      192),
                                                              width: getHorizontalSize(
                                                                  137),
                                                              alignment:
                                                                  Alignment
                                                                      .centerRight)
                                                        ]))
                                              ]),
                                        ))),
                                Padding(
                                    padding: getPadding(top: 53),
                                    child: Row(children: [
                                      Text(
                                          'change_time'.tr(),
                                          style: TextStyle(
                                              color:
                                                  ColorConstant.gray800,
                                              fontSize: getFontSize(12),
                                              fontFamily:
                                                  'Manrope',
                                              fontWeight:
                                                  FontWeight.w300)),
                                      GestureDetector(
                                        onTap: () =>
                                            Navigator.pushNamed(context,
                                                AppRoutes.settings),
                                        child: Text('in_settings'.tr(),
                                            style: TextStyle(
                                                color: ColorConstant
                                                    .cyan700,
                                                fontSize:
                                                    getFontSize(12),
                                                fontFamily:
                                                    'Manrope',
                                                fontWeight:
                                                    FontWeight.w300,
                                                decoration:
                                                    TextDecoration
                                                        .underline)),
                                      )
                                    ])),
                                Padding(
                                    padding: getPadding(top: 13),
                                    child: Text(
                                        "${'you_can_refuse'.tr()} ${controller.date.day} ${controller.date.month.monthInText()} ${controller.date.year} ",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle
                                            .txtSFProDisplayLight12)),
                                CustomButton(
                                    height: getVerticalSize(32),
                                    onTap: () {
                                      onTapColumnten(context, true);
                                    },
                                    width: getHorizontalSize(178),
                                    text: 'continue'.tr().toUpperCase(),
                                    margin:
                                        getMargin(top: 19, bottom: 7),
                                    variant: ButtonVariant
                                        .OutlineBluegray60014,
                                    alignment: Alignment.center)
                              ]))
                    ]))));
  }

  onTapColumnten(BuildContext context, [bool continu= false]) async {
    CurrentUser.user.reminderTime = quantity;
    await _generateReminderTime();
    await CurrentUser.repo.setLocalUserData(reminderTime: quantity);
    SharedPrefs.sharedPreferences.setBool('set_reminders', true);
    Navigator.pop(context);
    if(continu) {
      if (
          SharedPrefs.sharedPreferences.getBool('send_pushes') == null)
        showDialog(
            useSafeArea: false,
            context: context,
            builder: (_) => SendPushesScreen());
      else if (SharedPrefs.sharedPreferences
              .getBool('recommendation_buy_tariff') ==
          null) {
        showDialog(
            useSafeArea: false,
            context: context,
            builder: (_) => RecommendationBuyTariffScreen());
      } else if (SharedPrefs.sharedPreferences.getBool('pill_reminders') ==
          null) {
        showDialog(
            useSafeArea: false,
            context: context,
            builder: (_) => PillRemindersScreen());
      }
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
