import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_radio_button.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_pop_button.dart';
import '../../../widgets/custom_text_form_field.dart';
import 'controller.dart';
import 'widgets/retractable_container_widget.dart';
import '../../../theme/app_colors.dart';

class K18Screen extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K18Controller());
    final key = GlobalKey<FormState>();
    // Anonymous (local-UUID-only) users have no Firebase Auth session — the
    // form below assumes a real account at every save/password/logout
    // action, so it's swapped for a plain "create an account" prompt
    // instead of being left to silently fail or crash.
    final isAnonymous = FirebaseAuth.instance.currentUser == null;

    return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
                padding: getPadding(left: 16, right: 16, bottom: 5),
                child: Form(
                  key: key,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomAppBar(
                          widget: CustomPopButton(
                            text: 'settings'.tr(),
                          ),
                        ),
                        Padding(
                            padding: getPadding(top: 26),
                            child: Text('profile'.tr(),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtH1)),
                        if (isAnonymous) ...[
                          Padding(
                            padding: getPadding(top: 24),
                            child: Text(
                              'anonymous_profile_notice'.tr(),
                              textAlign: TextAlign.left,
                              style: AppStyle.txtSFProDisplayLight14Gray800,
                            ),
                          ),
                          CustomButton(
                            height: getVerticalSize(47),
                            width: double.infinity,
                            margin: getMargin(top: 24, bottom: 40),
                            text: 'account_required_cta'.tr().toUpperCase(),
                            variant: ButtonVariant.Cyan,
                            fontStyle: ButtonFontStyle.White16,
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.signUp,
                                arguments: {'contextual': true}),
                          ),
                        ] else ...[
                        Padding(
                            padding: getPadding(top: 37),
                            child: Text('login'.tr(),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight16)),
                        Padding(
                            padding: getPadding(left: 3, top: 16),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GetBuilder(
                                    builder: (K18Controller _c) => Text(
                                        controller.loginController.text,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle.txtSFProDisplayRegular14),
                                  ),
                                  Spacer(),
                                  InkWell(
                                    onTap: () async {
                                      String result = await controller
                                          .showLoginDialog(context, controller);
                                      if (result != null) {

                                        controller.update();
                                      }
                                    },
                                    child: Text('change'.tr(),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle
                                            .txtSFProDisplayLight12Deeppurple600.copyWith(
                                            decoration: TextDecoration.underline
                                        ))
                                  ),
                                ])),
                        Padding(
                            padding: getPadding(top: 9),
                            child: Divider(
                                height: getVerticalSize(1),
                                thickness: getVerticalSize(1),
                                color: ColorConstant.gray8008c)),
                        /*Padding(
                            padding: getPadding(top: 39),
                            child: Text("Номер телефона",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight16)),*/

                        /*GetBuilder(
                          builder: (K18Controller _c) => Padding(
                              padding: getPadding(left: 3, top: 14),
                              child: Row(children: [
                                Text(controller.numberController.text,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayRegular14),
                                Spacer(),
                                InkWell(
                                  onTap: () async {
                                    String result = await controller
                                        .showNumberDialog(context, controller);
                                    if (result != null) {
                                      await controller.updateNumber(
                                          context, result);
                                      controller.update();
                                    }
                                  },
                                  child: Text("Изменить",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtSFProDisplayLight12Deeppurple600.copyWith(
                                          decoration: TextDecoration.underline
                                      ))
                                ),
                              ])),
                        ),*/
                        /*Padding(
                            padding: getPadding(top: 9),
                            child: Divider(
                                height: getVerticalSize(1),
                                thickness: getVerticalSize(1),
                                color: ColorConstant.gray8008c)),*/
                        Visibility(
                          visible: CurrentUser.repo.authService.trim() == '',
                          child: GetBuilder(
                            builder: (K18Controller _c) => RetractableContainerWidget(
                              update: controller.update,
                              padding: getPadding(top: 39),
                              title: 'passwprd'.tr(),
                              subtitle:
                                  'password_should'.tr(),
                              hintText: '',
                              textController: controller.oldPasswordController,
                              child: (password) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'old_password'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight16,
                                  ),
                                  Padding(
                                      padding: getPadding(left: 3, top: 16, bottom: 16),
                                      child:
                                      CustomTextFormField(
                                        focusNode: FocusNode(),
                                        isObscureText: false,
                                        controller: controller.newPasswordController,
                                        margin: getMargin(top: 16),
                                        maxLength: 26,
                                        variant: TextFormFieldVariant
                                            .UnderLineWhiteA700,
                                        counterText: '',
                                        fontStyle: TextFormFieldFontStyle
                                            .SFProDisplayRegular14,
                                        validator: (text) {
                                          if (text!.trim() != "")

                                          if(text.trim() != controller.newPasswordController.text) {
                                            return 'passwords_do_not_match'.tr();
                                          }
                                        },

                                      )),

                                  Text(
                                    'new_password'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight16,
                                  ),
                                  Padding(
                                      padding: getPadding(left: 3, top: 16,bottom: 16),
                                      child:
                                      CustomTextFormField(
                                        focusNode: FocusNode(),
                                        isObscureText: false,
                                        controller: controller.passwordRepeatController,
                                        margin: getMargin(top: 16),
                                        maxLength: 26,
                                        variant: TextFormFieldVariant
                                            .UnderLineWhiteA700,
                                        counterText: '',
                                        fontStyle: TextFormFieldFontStyle
                                            .SFProDisplayRegular14,
                                        validator: (text) {
                                          if (controller.newPasswordController.text != '' || controller.passwordRepeatController.text.isNotEmpty || text!.trim() == "") return 'fill_the_field'.tr();

                                        },

                                      )),
                                  Text(
                                    'password_confirmation'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight16,
                                  ),

                                ],
                              ),
                            ),
                          ),
                        ),

                        Padding(
                            padding: getPadding(left: 2, top: 53),
                            child: Row(children: [
                              Padding(
                                  padding: getPadding(top: 1),
                                  child: Text('age'.tr(),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtSFProDisplayLight16)),
                              Padding(
                                  padding: getPadding(left: 110, bottom: 1),
                                  child: Text('gender'.tr(),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtSFProDisplayLight16))
                            ])),
                        Padding(
                            padding: getPadding(left: 3, top: 13),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GetBuilder(
                                    builder: (K18Controller _c) => Padding(
                                        padding: getPadding(bottom: 3),
                                        child: Text(
                                            controller.oldController.text,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.left,
                                            style: AppStyle
                                                .txtSFProDisplayRegular14)),
                                  ),
                                  InkWell(
                                    onTap: () async {
                                      int returnedValue = await controller
                                          .showOldDialog(context, controller);
                                      if (returnedValue != null) {

                                        controller.update();
                                      }
                                    },
                                    child: Row(
                                      children: [
                                        Padding(
                                            padding:
                                                getPadding(left: 34, bottom: 4),
                                            child: Text('change'.tr(),
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.left,
                                                style: AppStyle
                                                    .txtSFProDisplayLight12Deeppurple600)),
                                        CustomImageView(
                                            svgPath: ImageConstant.imgVector46,
                                            height: getVerticalSize(8),
                                            width: getHorizontalSize(4),
                                            radius: BorderRadius.circular(
                                                getHorizontalSize(1)),
                                            margin: getMargin(
                                                left: 6, top: 4, bottom: 8)),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: getHorizontalSize(55),
                                  ),
                                  Padding(
                                      padding: getPadding(top: 4),
                                      child: GetBuilder(
                                        builder: (K18Controller _c) =>
                                            Row(children: [
                                          CustomRadioButton(
                                              text: 'male'.tr(),
                                              isTrue: CurrentUser.user.male,
                                              value: '',
                                              fontStyle: CurrentUser.user.male!
                                                  ? RadioFontStyle
                                                      .SFProDisplayBlack12
                                                  : RadioFontStyle
                                                      .SFProDisplayLight12,
                                              onChange: (value) async {
                                                CurrentUser.user.male = true;
                                                controller.update();
                                              }),
                                          CustomRadioButton(
                                              text: 'female'.tr(),
                                              value: '',
                                              isTrue: !CurrentUser.user.male!,
                                              iconSize: getHorizontalSize(15),
                                              margin:
                                                  getMargin(left: 10, bottom: 1),
                                              fontStyle: !CurrentUser.user.male!
                                                  ? RadioFontStyle
                                                      .SFProDisplayBlack12
                                                  : RadioFontStyle
                                                      .SFProDisplayLight12,
                                              onChange: (value) async {
                                                CurrentUser.user.male = false;

                                                controller.update();
                                              })
                                        ]),
                                      ))
                                ])),
                        Padding(
                            padding: getPadding(top: 5),
                            child: SizedBox(
                                width: getHorizontalSize(116),
                                child: Divider(
                                    height: getVerticalSize(1),
                                    thickness: getVerticalSize(1),
                                    color: ColorConstant.gray8008c))),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                                height: getVerticalSize(32),
                                width: getHorizontalSize(146),
                                text: 'cancel'.tr().toUpperCase(),
                                margin: getMargin(top: 40),
                                padding: ButtonPadding.PaddingT8,
                                prefixWidget: CustomImageView(
                                  margin: getMargin(right: 12),
                                  svgPath: ImageConstant.leftArrow,
                                ),
                                onTap: () => onTaptf(context),
                                alignment: Alignment.center),
                            CustomButton(
                                height: getVerticalSize(32),
                                width: getHorizontalSize(146),
                                text: 'save'.tr().toUpperCase(),
                                margin: getMargin(top: 40,left: 10),
                                padding: ButtonPadding.PaddingT8,
                                onTap: () async => key.currentState!.validate() ? await controller.saveData(context) : null,
                                alignment: Alignment.center),

                          ],
                        ),
                        CustomButton(
                            height: getVerticalSize(32),
                            width: getHorizontalSize(250),
                            text: 'logout'.tr().toUpperCase(),
                            margin: getMargin(top: 40),
                            padding: ButtonPadding.PaddingT8,
                            prefixWidget: CustomImageView(
                              margin: getMargin(right: 12),
                              svgPath: ImageConstant.leftArrow,
                            ),
                            onTap: ()async  =>await  controller.signOut(context),
                            alignment: Alignment.center),
                        ],
                      ]),
                )),
          ),
        ),
        bottomNavigationBar:
            CustomBottomBar(onChanged: (BottomBarEnum type) {}));
  }

  onTaptf(BuildContext context) {
    Navigator.pop(context);
  }
}
