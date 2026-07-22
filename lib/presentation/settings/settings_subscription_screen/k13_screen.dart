import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_switch.dart';

import '../../../core/models/tariff_model.dart';
import '../../../core/user_data/user.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K13Screen extends GetWidget {

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K13Controller());
    return GetBuilder(
      builder: (K13Controller c) => Scaffold(
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
                              CustomAppBar(widget: CustomPopButton(text: 'Настройки',),),

                              Padding(
                                  padding: getPadding(top: 25),
                                  child: Text("Подписка",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtH1)),
                              Padding(
                                  padding: getPadding(left: 2, top: 57),
                                  child: Row(children: [
                                    Padding(
                                        padding: getPadding(top: 1),
                                        child: Text("Актуальный тариф",
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
                                      CurrentUser.user.currentTariff!.description,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtSFProDisplayLight12Gray80096)),
                              Padding(
                                  padding: getPadding(top: 31),
                                  child: Visibility(
                                    visible: CurrentUser.user.currentTariff!.name != 'Базовый',
                                    child: Text("Активна до ${CurrentUser.user.currentTariff!.endDate.day} ${CurrentUser.user.currentTariff!.endDate.month.monthInText().toLowerCase()} ${CurrentUser.user.currentTariff!.endDate.year}",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle
                                            .txtSFProDisplayLight14Gray800),
                                  )),
                              Container(
                                  margin: getMargin(top: 83),
                                  padding: getPadding(all: 4),
                                  decoration: AppDecoration.outlineBluegray80014
                                      .copyWith(
                                    color: ColorConstant.grayLight,
                                          borderRadius:
                                              BorderRadiusStyle.roundedBorder3),
                                  child: Row(

                                      children: [
                                        CustomImageView(
                                            svgPath: ImageConstant.imgClose,
                                            height: getSize(24),
                                            width: getSize(24),
                                            margin:
                                                getMargin(top: 5, bottom: 1)),
                                        Padding(
                                            padding: getPadding(
                                                left: 15, top: 5, bottom: 4,),
                                            child: Text(
                                                "Отключить автопродление",
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle
                                                    .txtSFProDisplayLight16)),
                                        Spacer(),
                                        CustomSwitch(
                                            margin:
                                                getMargin(right: 6, bottom: 2),
                                            value: controller.enableAutoRenewal,
                                            onChanged: (value) {
                                              controller.enableAutoRenewal = value;
                                              controller.update();
                                            })
                                      ])),
                              GestureDetector(
                                  onTap: () {
                                    onTapRowcart(context);
                                  },
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
                                            child: Text("Купить подписку",
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
                                            child: Text("Ввести  промокод",
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
                                  text: "настройки".toUpperCase(),
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

  onTapRowcart(BuildContext context) async {

    if(CurrentUser.tariffIsOrion()){
      showDialog(
        context: context, builder: (BuildContext context) =>
          CustomMessageBox(
            title: 'RIVA PSY',
            content:
            'Вы уже подписаны до ${CurrentUser.user.currentTariff!.endDate.day} ${CurrentUser.user.currentTariff!.endDate.month
                .monthInText()} ${CurrentUser.user.currentTariff!.endDate.year} г.',
          ),);
    }
    else {
      Navigator.pushNamed(context, AppRoutes.buySubscription,
          arguments: [
            if(!CurrentUser.usedOreonTrials)
              TariffModel.ORION_TARIFF_14_DAYS,
            TariffModel.ORION_TARIFF_MONTH,
            TariffModel.ORION_TARIFF_YEAR
          ]);
    }
  }

  onTapRowgrid(BuildContext context) {
    if(CurrentUser.tariffIsOrion()){
      showDialog(
        context: context, builder: (BuildContext context) =>
          CustomMessageBox(
            title: 'RIVA PSY',
            content:
            'Вы уже подписаны до ${CurrentUser.user.currentTariff!.endDate.day} ${CurrentUser.user.currentTariff!.endDate.month
                .monthInText()} ${CurrentUser.user.currentTariff!.endDate.year} г.',
          ),);
    } else
    Navigator.pushNamed(context, AppRoutes.promo);
  }

  onTaptf(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
}
