import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../../../../core/utils/size_utils.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_text_form_field.dart';
import 'controller.dart';

class VerificationScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final verificationId =
    (ModalRoute.of(context)?.settings.arguments ?? '') as String;
    final controller = Get.put(VerificationController(verificationId));
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:[ CustomTextFormField(
          focusNode: FocusNode(),
          controller: controller.smsController,
          hintText: 'sms_code_hint'.tr(),
          margin: getMargin(top: 16),
          maxLength: 16,
          variant: TextFormFieldVariant
              .UnderLineWhiteA700,
          counterText: '',
          fontStyle: TextFormFieldFontStyle
              .SFProDisplayRegular14,
          validator: (text) {
            if(text!.trim() == "") return 'fill_the_field'.tr();
          },),
          CustomButton(
              height: getVerticalSize(32),
              width: getHorizontalSize(178),
              text: 'continue'.tr().toUpperCase(),
              margin:
              getMargin(top: 80),
              variant: ButtonVariant
                  .OutlineBluegray60014,
              onTap: () => controller.verify(context),
              alignment: Alignment.center),

        ]
      ),
    );
  }
}
