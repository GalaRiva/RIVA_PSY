import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_password_field.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';
import '../../../theme/app_colors.dart';
// ignore_for_file: must_be_immutable

// ignore_for_file: must_be_immutable
class OneScreen extends GetWidget<OneScreenController> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OneScreenController());
    controller.passField = Get.put(CustomPasswordField(onChange: () => controller.update(), textEditingController: controller.passController, onSubmit: (text, _ ) {
      Navigator.pushNamed(context, AppRoutes.repeatPassword, arguments: text);

    }).obs);
    return Scaffold(
        backgroundColor: AppColors.background,
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
                            CustomAppBar(widget: CustomPopButton(text: 'settings'.tr(),),),

                            Padding(
                                padding: getPadding(top: 26),
                                child: Text('passwprd'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Align(
                                alignment: Alignment.center,
                                child: Padding(
                                    padding: getPadding(top: 111),
                                    child: Text('enter_password'.tr(),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style:
                                            AppStyle.txtSFProDisplayLight16))),
                            Container(
                              margin: getMargin(top: 58),
                              child: GetBuilder(
                                  builder: (OneScreenController _c) => Center(
                                    child: controller.passField.value
                                        .widget(context, Colors.black),
                                  )),
                            ),
                            SizedBox(height: getVerticalSize(60),),
                            SelectableText.rich(
                              TextSpan(
                                text: 'password_recovery_not_provided'.tr(), // default text style
                                children: <TextSpan>[
                                  TextSpan(text: 'password_recovery_reason1'.tr(), style: AppStyle.txtSFProDisplayLight16),
                                  TextSpan(text: 'password_recovery_reason2'.tr()),
                                  TextSpan(text: 'password_recovery_reason3'.tr(), style: AppStyle.txtSFProDisplayLight16),

                                ],
                              ),
                              style: AppStyle.txtSFProDisplayLight16.copyWith(fontWeight: FontWeight.bold),
                            ),
                            CustomButton(
                                height: getVerticalSize(32),
                                width: getHorizontalSize(146),
                                text: 'settings'.tr().toUpperCase(),
                                margin: getMargin(top: 44),
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
