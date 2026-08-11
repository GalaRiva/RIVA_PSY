import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_pop_button.dart';
import '../../../../settings/settings_profile_screen/text_field_formatter.dart';
import '../widgets/services_button.dart';
import 'k2_controller.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';
import '../../../../../theme/app_colors.dart';

class K2AuthScreen extends GetWidget<K2AuthController> {
  final number = TextEditingController();
  final password = TextEditingController();
  final mail = TextEditingController();

  final controller = Get.put(K2AuthController());

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<FormState>();
    return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
          Expanded(
          child: SingleChildScrollView(
          child: Container(
              padding: getPadding(left: 16, right: 16),
          child: Form(
              key: key,
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisAlignment:
                MainAxisAlignment.start,
                children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CustomAppBar(
                  margin: getMargin(top: 64),
                widget: CustomPopButton(text: 'sing_up'.tr(),
                  style: AppStyle.txtSFProDisplayLight10Gray800,)),
              ),
    Padding(
          padding: getPadding(top: 26),
          child: Text('sign_in'.tr(),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtH1)),
                  Padding(padding: getPadding(top: 26, bottom: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(child: ServicesButton(svgIcon: ImageConstant.appleSVG, serviceName: 'Apple', onTap: () async => await controller.authWithApple(context))),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Row(
                          children: [
                            Expanded(child: ServicesButton(svgIcon: ImageConstant.googleSVG, serviceName: 'Google', onTap: () async => await controller.authWithGoogle(context))),
                          ],
                        ),
                      ],
                    ),
                  ),
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
          Padding(
              padding: getPadding(top: 46),
              child: Text(controller.useEmail ? 'email'.tr() : 'phone_number'.tr(),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppStyle
                      .txtSFProDisplayLight16)),
          Visibility(
            visible: !controller.useEmail,
            child: CustomTextFormField(
              focusNode: FocusNode(),
              controller: number,
              hintText: "+7-911-111-22-33",
              margin: getMargin(top: 16),
              maxLength: 16,
              variant: TextFormFieldVariant
                  .UnderLineWhiteA700,
              counterText: '',
              fontStyle: TextFormFieldFontStyle
                  .SFProDisplayRegular14,
              formatter: [NumberFieldFormatter()],
              validator: (text) {
                if (text!.trim() == "") return 'fill_the_field'.tr();
              },),
          ),
          Visibility(
            visible: controller.useEmail,
            child: CustomTextFormField(
                focusNode: FocusNode(),
                controller: mail,
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
                    return 'fill_the_field'.tr();
                  else if (!RegExp(
                      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      .hasMatch(text)) {
                    return 'invalid_email_format'.tr();
                  }
                },
                textInputAction:
                TextInputAction.done),
          ),
      ],
    ),

    Padding(
          padding: getPadding(top: 38),
          child: Text('passwprd'.tr(),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle
                  .txtSFProDisplayLight16)),
    CustomTextFormField(
          focusNode: FocusNode(),
          controller: password,
          hintText: 'your_password'.tr(),
          margin: getMargin(top: 14),
          variant: TextFormFieldVariant
              .UnderLineWhiteA700,
          fontStyle: TextFormFieldFontStyle
              .SFProDisplayRegular14,
          maxLength: 26,
          counterText: '',
          validator: (text) {
            if (text!.trim() == "") return 'fill_the_field'.tr();
          },
          textInputAction:
          TextInputAction.done),

                  /*Padding(
                    padding: getPadding(top: 42),
                    child: GetBuilder(
                      builder: (K2AuthController _c) => TextButton(
                        onPressed: () {
                          controller.changeAuthMethod();
                        }, child: Text(_c.useEmail ? "Использовать для авторизации номер телефона" : "Использовать почту для авторизации",
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
          onTap: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('restore_password'.tr() + " ",
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppStyle
                      .txtSFProDisplayLight16DeepPurple),
              CustomImageView(
                  svgPath: ImageConstant
                      .imgVector46,
                  height:
                  getVerticalSize(
                      8),
                  width:
                  getHorizontalSize(
                      4),),
            ],
          ),
      ),
    ),                        SizedBox(height: 26,),


                  CustomButton(
          height: getVerticalSize(32),
          width: getHorizontalSize(178),
          text: 'continue'.tr().toUpperCase(),
          variant: ButtonVariant
              .OutlineBluegray60014,
          onTap: () => onTaptf(context, key),
          alignment: Alignment.center)
    ]),
    ))))
    ]),
        ));
    }

  onTaptf(BuildContext context, GlobalKey<FormState> key) async {
    controller.update();
    if (key.currentState!.validate()) {
      final String? _number =
      controller.useEmail ? null : number.text;
      final String? email = controller.useEmail ? mail.text : null;

      await controller.auth(context, password.text, number: _number, email: email);
    }
  }
}
