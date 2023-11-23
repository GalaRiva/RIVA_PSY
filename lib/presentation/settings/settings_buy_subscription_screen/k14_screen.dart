import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../core/models/tariff_model.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';

class K14Screen extends StatelessWidget {

  const K14Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final TariffModel? tariff;
    String? promo;
    final _args = ModalRoute.of(context)!.settings.arguments;
    if (_args is TariffModel) {
      tariff = _args;
    } else {
      tariff = TariffModel.fromJson ((_args as Map<String, dynamic>)['tariff']);
      promo = _args['promo'];
    }
    final controller = Get.put(BuySubscriptionController(promo));
    return SafeArea(
        child: Scaffold(
            backgroundColor: ColorConstant.gray300,
            resizeToAvoidBottomInset: false,
            body: SizedBox(
                width: size.width,
                child: SingleChildScrollView(
                    child: Padding(
                        padding: getPadding(left: 16, right: 16, bottom: 5),
                        child: Column(
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
                                            child:  Row(
                                              children: [
                                                CustomPopButton(text: 'Настройки'),
                                                Text(' | Подписка ', style: AppStyle.txtSFProDisplayLight10Gray800,),
                                                Text('| Купить подписку', style: AppStyle.txtSFProDisplayLight10,)
                                              ],
                                            )),
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
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                      padding: getPadding(top: 26),
                                      child: Text("Купить подписку",
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: AppStyle.txtH1))),
                              Padding(
                                  padding: getPadding(top: 50),
                                  child: Text(tariff!.name,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtSFProDisplayLight16)),
                              CustomImageView(
                                  svgPath: ImageConstant.imgGroup74,
                                  height: getVerticalSize(138),
                                  width: getHorizontalSize(143),
                                  margin: getMargin(top: 10)),
                              Padding(
                                padding: getPadding(top: 7, left: 20),
                                child: SizedBox(
                                  height: getVerticalSize(36 * tariff.advantages!.length.toDouble()) ,
                                  child: ListView.separated(
                                    physics: NeverScrollableScrollPhysics(),
                                      itemBuilder: (context,index) => Row(children: [
                                    CustomImageView(
                                        svgPath: ImageConstant.imgStar,
                                        height: getVerticalSize(30),
                                        width: getHorizontalSize(15)),
                                    Padding(
                                        padding: getPadding(
                                            left: 9, top: 7, bottom: 5),
                                        child: Text(
                                            tariff!.advantages[index],
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: AppStyle
                                                .txtSFProDisplayLight14Gray800))
                                  ]), separatorBuilder: (context, index) => SizedBox(height: getVerticalSize(6)), itemCount: tariff.advantages!.length),
                                ),
                              ),
                              CustomButton(
                                  height: getVerticalSize(54),
                                  text:
                                      "Перейти на тариф \"Орион\"".toUpperCase(),
                                  margin:
                                      getMargin(left: 20, top: 19, right: 19),
                                  variant: ButtonVariant.OutlineBluegray60014,
                                  padding: ButtonPadding.PaddingAll19,
                                  fontStyle: ButtonFontStyle
                                      .SFProDisplayRegular12Cyan700,
                                  onTap: () async => await controller.onTapGoToTariff(tariff!, context)),
                              Padding(
                                  padding: getPadding(top: 14),
                                  child: Text("за  ${tariff.cost.toInt()} ₽/год",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtSFProDisplayLight16Cyan700)),
                              CustomButton(
                                  height: getVerticalSize(32),
                                  width: getHorizontalSize(146),
                                  text: "подписка".toUpperCase(),
                                  margin: getMargin(top: 42),
                                  padding: ButtonPadding.PaddingT8,
                                  prefixWidget: CustomImageView(
                                    margin: getMargin(right: 12),
                                    svgPath: ImageConstant.leftArrow,
                                  ),
                                  onTap: () => onTaptf1(context),
                                  alignment: Alignment.center)
                            ])))),
            bottomNavigationBar:
                CustomBottomBar(onChanged: (BottomBarEnum type) {})));
    }



  onTaptf1(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.subscription);
  }
}
