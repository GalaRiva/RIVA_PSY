import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_getx_widget.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import '../../../../settings/settings_profile_screen/text_field_formatter.dart';
import '../widgets/services_button.dart';
import 'k2_controller.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_checkbox.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_text_form_field.dart';

class K2Screen extends GetWidget<K2Controller> {
  TextEditingController group887Controller = TextEditingController();

  TextEditingController group889Controller = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  TextEditingController passwordRepeatController = TextEditingController();

  final emailController = TextEditingController();

  bool checkbox = false;

  bool checkbox1 = false;

  bool isPasswordCompliant(String password) {
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    if (hasUppercase) {
      bool hasDigits = password.contains(RegExp(r'[0-9]'));
      if (hasDigits) {
        bool hasLowercase = password.contains(RegExp(r'[a-z]'));
        if (hasLowercase) {
          bool hasSpecialCharacters =
              password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
          return hasSpecialCharacters;
        }
      }
    }

    return false;
  }

  final controller = Get.put(K2Controller());
  var dividerColor1 = ColorConstant.cyan70078;
  var dividerColor2 = ColorConstant.cyan70078;

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    return Scaffold(
        backgroundColor: ColorConstant.gray300,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
                padding: getPadding(left: 16, right: 16),
                child: Form(
                  key: key,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                            padding: getPadding(top: 64),
                            child: Divider(
                                height: getVerticalSize(1),
                                thickness: getVerticalSize(1),
                                color: ColorConstant.gray50)),
                        Padding(
                            padding: getPadding(top: 26),
                            child: Text("Регистрация",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtH1)),
                        Padding(
                            padding: getPadding(top: 10, right: 29),
                            child: Text(
                                "Мы используем ващу почту только для безопасности ваших записей,  данные не передаются третьим лицам и обезличены",
                                maxLines: null,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtH2)),
                        Padding(
                          padding: getPadding(top: 26, bottom: 10),
                          child: SizedBox(
                            width: size.width,
                            child: Column(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: ServicesButton(
                                          svgIcon: ImageConstant.appleSVG,
                                          serviceName: 'Apple',
                                          onTap: () async => await controller
                                              .authWithApple(context)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ServicesButton(
                                          svgIcon: ImageConstant.googleSVG,
                                          serviceName: 'Google',
                                          onTap: () async => await controller
                                              .authWithGoogle(context)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                            padding: getPadding(top: 36),
                            child: Text("Логин",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style:
                                    AppStyle.txtSFProDisplayLight16)),
                        CustomTextFormField(
                          focusNode: FocusNode(),
                          formatter: [TextInputLoginFormatter()],
                          controller: group887Controller,
                          hintText: "Ваш логин",
                          margin: getMargin(top: 16),
                          variant:
                              TextFormFieldVariant.UnderLineWhiteA700,
                          fontStyle: TextFormFieldFontStyle
                              .SFProDisplayRegular14,
                          validator: (text) {
                            if (text!.trim() == "")
                              return "Заполните поле";
                          },
                        ),
                        GetBuilder(
                          builder: (K2Controller _c) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: getPadding(top: 38),
                                  child: Text(
                                      controller.useEmail
                                          ? "Ваша почта"
                                          : "Номер телефона",
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtSFProDisplayLight16)),
                              Visibility(
                                visible: !controller.useEmail,
                                child: CustomTextFormField(
                                    focusNode: FocusNode(),
                                    formatter: [NumberFieldFormatter()],
                                    controller: group889Controller,
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
                                      if (text!.trim() == "")
                                        return "Заполните поле";
                                      else if (text!.trim().length !=
                                          16) {
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
                                    controller: emailController,
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
                                        TextInputAction.done),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: getPadding(top: 38),
                            child: Text("Пароль",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style:
                                    AppStyle.txtSFProDisplayLight16)),
                        Padding(
                            padding: getPadding(top: 10),
                            child: SizedBox(
                              width: size.width - 32,
                              child: Text(
                                  "Пароль должен содержать 8 символов и по крайне мере, одну цифру и один символ, такой как !·\$%&?",
                                  textAlign: TextAlign.left,
                                  style: AppStyle
                                      .txtSFProDisplayLight12),
                            )),
                        CustomTextFormField(
                            focusNode: FocusNode(),
                            controller: passwordController,
                            hintText: "",
                            margin: getMargin(top: 14),
                            variant: TextFormFieldVariant
                                .UnderLineWhiteA700,
                            fontStyle: TextFormFieldFontStyle
                                .SFProDisplayRegular14,
                            maxLength: 26,
                            counterText: '',
                            validator: (text) {
                              if (text!.trim() == "")
                                return "Заполните поле";
                              else if (text!.trim().length < 8) {
                                return 'Длина пароля должна быть больше чем 8 символов';
                              } else if (text!.trim().length > 26) {
                                return 'Длина пароля должна быть меньше чем 26 символов';
                              } else if (!isPasswordCompliant(text)) {
                                return 'Пароль должен содержать по крайней мере одну\nцифру, одну строчкую и заглавную букву\nи один уникальныйсимвол, такой как !#\$%&?';
                              }
                            },
                            textInputAction: TextInputAction.done),
                        Padding(
                            padding: getPadding(top: 38),
                            child: Text("Подтверждение пароля",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style:
                                    AppStyle.txtSFProDisplayLight16)),
                        CustomTextFormField(
                            focusNode: FocusNode(),
                            controller: passwordRepeatController,
                            hintText: "",
                            margin: getMargin(top: 14),
                            variant: TextFormFieldVariant
                                .UnderLineWhiteA700,
                            fontStyle: TextFormFieldFontStyle
                                .SFProDisplayRegular14,
                            maxLength: 26,
                            counterText: '',
                            validator: (text) {
                              if (text!.trim() == "")
                                return "Заполните поле";
                              else if (text !=
                                  passwordController.text) {
                                return 'Пароли должны совпадать';
                              }
                            },
                            textInputAction: TextInputAction.done),
                        SizedBox(height: 26,),

                        GetBuilder(
                          builder: (K2Controller controller) =>
                              Column(
                            children: [
                              CustomCheckbox(
                                  text:
                                      "Принимаю Согласие на обработку персональных данных ",
                                  value: checkbox,
                                  onTapOnText: () =>
                                      Navigator.pushNamed(context,
                                          AppRoutes.aboutApp),
                                  fontStyle: CheckboxFontStyle
                                      .SFProDisplayLight12,
                                  onChange: (value) {
                                    checkbox = value;
                                    controller.update();
                                  }),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                      padding: getPadding(top: 2),
                                      child: Divider(
                                          height: getVerticalSize(1),
                                          thickness:
                                              getVerticalSize(1),
                                          color: dividerColor1))),
                              CustomCheckbox(
                                  text:
                                      "Принимаю Пользовательское соглашение",
                                  value: checkbox1,
                                  onTapOnText: () =>
                                      Navigator.pushNamed(context,
                                          AppRoutes.aboutApp),
                                  margin: getMargin(top: 39),
                                  fontStyle: CheckboxFontStyle
                                      .SFProDisplayLight12,
                                  onChange: (value) {
                                    checkbox1 = value;
                                    controller.update();
                                  }),
                              Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                      padding: getPadding(top: 2),
                                      child: Divider(
                                          height: getVerticalSize(1),
                                          thickness:
                                              getVerticalSize(1),
                                          color: dividerColor2))),
                            ],
                          ),
                        ),
                        /*Padding(
                          padding: getPadding(top: 42),
                          child: GetBuilder(
                            builder: (K2Controller _c) => TextButton(
                              onPressed: () {
                                controller.changeRegistrationMethod();
                              }, child: Text(_c.useEmail ? "Использовать для регистрации номер телефона" : "Использовать почту для регистрации",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle
                                    .txtSFProDisplayLight16DeepPurple),
                            ),
                          ),
                        ),*/
                        Padding(
                          padding: getPadding(top: 42),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.signIn),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                Text("У меня уже есть аккаунт ",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle
                                        .txtSFProDisplayLight16DeepPurple),
                                CustomImageView(
                                  svgPath: ImageConstant.imgVector46,
                                  height: getVerticalSize(8),
                                  width: getHorizontalSize(4),
                                ),
                              ],
                            ),
                          ),
                        ),

                        CustomButton(
                            height: getVerticalSize(32),
                            width: getHorizontalSize(178),
                            text: "Далее".toUpperCase(),
                            margin: getMargin(top: 42, bottom: 177),
                            variant:
                                ButtonVariant.OutlineBluegray60014,
                            onTap: () => onTaptf(context, key),
                            alignment: Alignment.center)
                      ]),
                )),
          ),
        ));
  }

  onTaptf(BuildContext context, GlobalKey<FormState> key) async {
    controller.update();
    if (checkbox1 != true)
      dividerColor2 = Colors.red;
    else
      dividerColor2 = ColorConstant.cyan70078;
    if (checkbox != true)
      dividerColor1 = Colors.red;
    else
      dividerColor1 = ColorConstant.cyan70078;
    if (key.currentState!.validate() && checkbox == true && checkbox1 == true) {
      final String? number =
          controller.useEmail ? null : group889Controller.text;
      final String? email = controller.useEmail ? emailController.text : null;
      await controller.createNewUser(
          context, group887Controller.text, passwordController.text,
          email: email, number: number);
    }
  }
}
