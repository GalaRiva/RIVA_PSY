import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

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
                                          child:  CustomPopButton( text: 'Настройки',)),
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
                                child: Text("О приложении",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Padding(
                                padding: getPadding(left: 4, top: 82),
                                child: DropTextWidget(model: controller.termsOfUse,)),
                            Padding(
                                padding: getPadding(left: 4, top: 96),
                                child: DropTextWidget(model: controller.privacyPolicy,)),
                            CustomButton(
                                height: getVerticalSize(32),
                                width: getHorizontalSize(146),
                                text: AppRoutes.currentRoute == AppRoutes.settings? "настройки".toUpperCase() : "назад".toUpperCase(),
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
