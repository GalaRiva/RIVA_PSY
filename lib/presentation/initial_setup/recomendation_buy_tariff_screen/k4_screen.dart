import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_text_form_field.dart';

import '../../../core/models/tariff_model.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class K4Screen extends StatelessWidget {
  TextEditingController group993Controller = TextEditingController();

  TextEditingController group995Controller = TextEditingController();

  @override Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(backgroundColor: ColorConstant.gray300,
        resizeToAvoidBottomInset: false,
        body: Container(width: double.maxFinite,
            child: Column(mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(child: SingleChildScrollView(child: Container(
                      height: getVerticalSize(782),
                      width: double.maxFinite,
                      padding: getPadding(left: 6, right: 6),
                      decoration: AppDecoration.txt,
                      child: Stack(alignment: Alignment.topCenter,
                          children: [
                            Align(alignment: Alignment.topCenter,
                                child: Container(margin: getMargin(
                                    left: 1, top: 64),
                                    padding: getPadding(left: 11,
                                        top: 27,
                                        right: 11,
                                        bottom: 27),
                                    decoration: AppDecoration.outlineWhiteA700
                                        .copyWith(
                                        borderRadius: BorderRadiusStyle
                                            .roundedBorder3),
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment: MainAxisAlignment
                                            .start,
                                        children: [
                                          Align(alignment: Alignment.centerLeft,
                                              child: Text("Тариф",
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                  textAlign: TextAlign.left,
                                                  style: AppStyle.txtH1)),
                                          Padding(padding: getPadding(
                                              top: 10, right: 5),
                                              child: Text(
                                                  "Для хранения всех вводимых данных на вашем смартфоне и максимальной конфиденциальности переходите \nна тариф Стандарт. Получите полный доступ к рекомендациям, статистике и аудио",
                                                  maxLines: null,
                                                  textAlign: TextAlign.left,
                                                  style: AppStyle.txtH2)),
                                          CustomImageView(
                                              svgPath: ImageConstant.imgGroup74,
                                              height: getVerticalSize(138),
                                              width: getHorizontalSize(143),
                                              margin: getMargin(top: 23)),
                                          CustomButton(
                                              height: getVerticalSize(54),
                                              text: "Перейти на тариф стандарт"
                                                  .toUpperCase(),
                                              onTap: () {
                                                Navigator.pushNamed(context,
                                                    AppRoutes.buySubscription,
                                                    arguments: TariffModel.ORION_TARIFF);
                                              },margin: getMargin(
                                                  left: 18, top: 19, right: 18),
                                              variant: ButtonVariant
                                                  .OutlineBluegray60014,
                                              padding: ButtonPadding
                                                  .PaddingAll19,
                                              fontStyle: ButtonFontStyle
                                                  .SFProDisplayRegular12Cyan700),
                                          Padding(padding: getPadding(top: 64),
                                              child: Text(
                                                  "В бесплатной версии резервные копии будут хранится в вашем облачном хранилище.",
                                                  maxLines: null,
                                                  textAlign: TextAlign.left,
                                                  style: AppStyle
                                                      .txtSFProDisplayThin12)),
                                          CustomButton(
                                              height: getVerticalSize(32),
                                              width: getHorizontalSize(178),
                                              text: "Далее".toUpperCase(),
                                              margin: getMargin(
                                                  top: 14, bottom: 6),
                                              variant: ButtonVariant
                                                  .OutlineBluegray60014,
                                              onTap: () => onTapOne(context))
                                        ])))
                          ]))))
                ]))));
  }

  onTapOne(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.send_pushes);
  }
}
