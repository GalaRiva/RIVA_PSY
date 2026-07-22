import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/presentation/initial_setup/sign_in/presentation/reset_password_screen/controller.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_text_form_field.dart';
import '../../../../settings/settings_profile_screen/text_field_formatter.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  bool isPasswordCompliant(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    if (hasUppercase) {
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      if (hasDigits) {
        bool hasLowercase = password.contains(RegExp(r'[a-z]'));
        if (hasLowercase) {
          bool hasSpecialCharacters = password.contains(
              RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
          return hasSpecialCharacters;
        }
      }
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    final controller = Get.put(ResetPasswordController(context));
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: getPadding(left: 16, right: 16),
            child: Form(
              key: key,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                      padding: getPadding(top: 64),
                      child: Divider(
                          height: getVerticalSize(1),
                          thickness: getVerticalSize(1),
                          color: ColorConstant.gray50)),
                  Padding(
                      padding: getPadding(top: 26),
                      child: Text("Восстановить пароль",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtH1)),
                  Padding(
                      padding: getPadding(top: 48),
                      child: SizedBox(
                        width: getVerticalSize(243),
                        child: Text("Введите почту, которую указывали при регистрации",
                            textAlign: TextAlign.left,
                            style: AppStyle
                                .txtSFProDisplayLight16),
                      )),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Padding(
                          padding: getPadding(top: 15),
                          child: Text("На ${controller.useEmail ? 'эту почту' : 'этот номер'} отправим код-подтверждение",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle
                                  .txtSFProDisplayLight12)),

                      Visibility(
                        visible: !controller.useEmail,
                        child: CustomTextFormField(
                            focusNode: FocusNode(),
                            formatter: [NumberFieldFormatter()],
                            controller: controller.numberController,
                            hintText: "+7-911-111-22-33",
                            margin: getMargin(top: 14),
                            variant: TextFormFieldVariant
                                .UnderLineWhiteA700,
                            fontStyle: TextFormFieldFontStyle
                                .SFProDisplayRegular14,
                            textInputType: TextInputType.phone,
                            maxLength: 16,
                            counterText: '',
                            validator: (text) {
                              if(text!.trim() == "") return "Заполните поле";
                              else if (text!.trim().length != 16) {
                                return 'Пожалуйста введите верный формат номера телефона';
                              }
                            },
                            textInputAction:
                            TextInputAction.done),
                      ),
                      Visibility(
                        visible: controller.useEmail,
                        child: CustomTextFormField(
                            focusNode: FocusNode(),
                            controller: controller.email,
                            hintText: "example@mail.ru",
                            margin: getMargin(top: 14),
                            variant: TextFormFieldVariant
                                .UnderLineWhiteA700,
                            fontStyle: TextFormFieldFontStyle
                                .SFProDisplayRegular14,
                            textInputType:
                            TextInputType.emailAddress,
                            maxLength: 320,
                            counterText: '',
                            validator: (text) {
                              if (text!.trim() == "")
                                return "Заполните поле";
                              else if (!RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                  .hasMatch(text)) {
                                return 'Пожалуйста введите верный формат вашей почты';
                              }
                            },
                            textInputAction:
                            TextInputAction.done),)
                    ],
                  ),
                  /*Padding(
                      padding: getPadding(top: 69),
                      child: Text("Новый пароль",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle
                              .txtSFProDisplayLight16)),
                  CustomTextFormField(
                      focusNode: FocusNode(),
                      controller: controller.passwordController,
                      hintText: "",
                      margin: getMargin(top: 14),
                      variant: TextFormFieldVariant
                          .UnderLineWhiteA700,
                      fontStyle: TextFormFieldFontStyle
                          .SFProDisplayRegular14,
                      maxLength: 26,
                      counterText: '',
                      validator: (text) {
                        if(text!.trim() == "") return "Заполните поле";
                        else if (text!.trim().length < 8) {
                          return 'Длина пароля должна быть больше чем 8 символов';
                        }
                        else if (text!.trim().length > 26) {
                          return 'Длина пароля должна быть меньше чем 26 символов';
                        }

                        else if(!isPasswordCompliant(text)){
                          return 'Пароль должен содержать по крайней мере одну\nцифру, одну строчкую и заглавную букву\nи один уникальныйсимвол, такой как !#\$%&?';

                        }
                      },
                      textInputAction:
                      TextInputAction.done),
                  Padding(
                      padding: getPadding(top: 38),
                      child: Text("Подтвердждение пароля",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle
                              .txtSFProDisplayLight16)),
                  CustomTextFormField(
                      focusNode: FocusNode(),
                      controller: controller.repeatPasswordController,
                      hintText: "",
                      margin: getMargin(top: 14),
                      variant: TextFormFieldVariant
                          .UnderLineWhiteA700,
                      fontStyle: TextFormFieldFontStyle
                          .SFProDisplayRegular14,
                      maxLength: 26,
                      counterText: '',
                      validator: (text) {
                        if(text!.trim() == "") return "Заполните поле";
                        else if (text != controller.passwordController.text) {
                          return 'Пароли должны совпадать';
                        }
                      },
                      textInputAction:
                      TextInputAction.done),*/
                  /*Padding(
                    padding: getPadding(top: 42),
                    child: GetBuilder(
                      builder: (ResetPasswordController _c) => TextButton(
                        onPressed: () {
                          controller.changeResetPasswordMethod();
                        }, child: Text(_c.useEmail ? "Использовать для восстановления номер телефона" : "Использовать почту для восстановления",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle
                              .txtSFProDisplayLight16DeepPurple),
                      ),
                    ),
                  ),*/
                  Padding(padding: getPadding(top: 82),
                  child: Row(          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    CustomButton(
                      height: getVerticalSize(
                        32,
                      ),
                      width: getHorizontalSize(
                        147,
                      ),
                      variant: ButtonVariant.Base,
                      onTap: () => Navigator.pop(context),
                      text: "отменить".toUpperCase(),
                      margin: getMargin(
                      ),
                      alignment: Alignment.topCenter,
                    ),
                    CustomButton(
                      height: getVerticalSize(
                        32,
                      ),
                      width: getHorizontalSize(
                        147,
                      ),
                      variant: ButtonVariant.Base,
                      onTap: () async => controller.onConfirm(key),
                      text: "Сохранить".toUpperCase(),
                      margin: getMargin(
                        left: 13,
                      ),
                      alignment: Alignment.topCenter,
                    ),
                  ],),
                  )

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
