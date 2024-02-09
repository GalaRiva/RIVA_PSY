import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import '../../../core/user_data/user.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_password_field.dart';
import '../../../widgets/custom_pop_button.dart';
import'controller.dart';

class K9Screen extends GetWidget<K9Controller> {

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K9Controller())
;    var data = ModalRoute.of(context)?.settings.arguments  as String;
    if(controller.passField == null)
    controller.passField = CustomPasswordField(password: data, textEditingController: controller.passController,  onChange: () {
      controller.update();
    }, onSubmit: (text, password) async{
      if (text.length >= 4 && text == password) {
        showDialog(context: context, builder: (BuildContext context) => CustomMessageBox(
          title: 'Пароль',
          content:
          'Пароль успешно сохранён',
        ), );
        CurrentUser.user.password = text;
        await CurrentUser.repo.setLocalUserData(password: text);
      } if (text.length >= 4 && text != password) {
        showDialog(context: context, builder: (BuildContext context) => CustomMessageBox(
          title: 'Пароль',
          content:
          'Пароли не совпадают',
        ), );

      }
    }).obs;
    return Scaffold(
        backgroundColor: ColorConstant.gray300,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                      padding: getPadding(left: 16, right: 16, bottom: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomAppBar(widget: CustomPopButton(text: 'Настройки',),),

                            Padding(
                                padding: getPadding(top: 26),
                                child: Text("Пароль",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Align(
                                alignment: Alignment.center,
                                child: Padding(
                                    padding: getPadding(top: 111),
                                    child: Text("Подтвердите пароль",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle
                                            .txtSFProDisplayLight16))),
                            Container(
                              margin: getMargin(top: 58),
                              child: GetBuilder(
                                  builder: (K9Controller _c) => Center(
                                    child: controller.passField!.value
                                        .widget(context, Colors.black),
                                  )),
                            ),
                            CustomButton(
                                height: getVerticalSize(32),
                                width: getHorizontalSize(146),
                                text: "настройки".toUpperCase(),
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
            CustomBottomBar(onChanged: (BottomBarEnum type) {}));
  }

  onTaptf(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
}
