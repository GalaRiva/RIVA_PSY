import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_message_box.dart';
import '../../../../../widgets/custom_text_form_field.dart';

CustomMessageBox smsCodeMessage<T>(BuildContext context,
    {required Function(String) onConfirm,
    required bool error}) {
  final smsController = TextEditingController();
  return CustomMessageBox(
      title: '',
      canPop: false,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Введите код, который пришел Вам в письме',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14),
          Padding(
            padding: getPadding(top: 15),
            child: Center(
              child: SizedBox(
                width: getVerticalSize(102),
                child:  CustomTextFormField(
                      isObscureText: false,
                      focusNode: FocusNode(),
                      controller: smsController,
                      hintText: "",
                      variant: !error
                          ? TextFormFieldVariant.UnderLineGray8008c
                          : TextFormFieldVariant.UnderLineRed,
                      fontStyle: TextFormFieldFontStyle.SFProDisplayRegular14,
                      alignment: Alignment.center,
                      maxLength: 6,
                      counterText: '',
                      validator: (text) {
                        if (text!.trim() == "") return "Заполните поле";
                      },
                      textInputAction: TextInputAction.done),
                ),

            ),
          ),
          Padding(
            padding: getPadding(top: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
                  onTap: () async {
                     onConfirm(smsController.text);
                  },
                  text: "ОК".toUpperCase(),
                  margin: getMargin(left: 13),
                  alignment: Alignment.topCenter,
                ),
              ],
            ),
          )
        ],
      ));
}
