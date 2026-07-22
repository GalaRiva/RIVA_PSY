import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import 'custom_checkbox_notification.dart';

class CustomRadioButton extends StatelessWidget {
  CustomRadioButton(
      {this.fontStyle,
      this.alignment,
      this.onChange,
      this.isRightCheck = false,
      this.iconSize,
      this.value,
      this.groupValue,
      this.text,
      this.width,
      this.margin,
      this.isTrue});

  RadioFontStyle? fontStyle;

  Alignment? alignment;

  Function(String)? onChange;

  bool? isRightCheck;

  bool? isTrue;

  double? iconSize;

  String? value;

  String? groupValue;

  String? text;

  double? width;

  EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildRadioButtonWidget(),
          )
        : _buildRadioButtonWidget();
  }

  _buildRadioButtonWidget() {
    return InkWell(
      onTap: () {
        onChange!(value!);
      },
      child: Container(
        width: width,
        margin: margin ?? EdgeInsets.zero,
        child: isRightCheck! ? getRightSideRadio() : getLeftSideRadio(),
      ),
    );
  }

  Widget getRightSideRadio() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: 8,
          ),
          child: getTextWidget(),
        ),
        CustomCheckboxNotification(isTrue!),
      ],
    );
  }

  Widget getLeftSideRadio() {
    return Row(
      children: [
        CustomCheckboxNotification(isTrue!),
        Padding(
          padding: EdgeInsets.only(
            left: 8,
          ),
          child: getTextWidget(),
        ),
      ],
    );
  }

  Widget getTextWidget() {
    return Text(
      text ?? "",
      textAlign: TextAlign.center,
      style: _setFontStyle(),
    );
  }

  Widget getRadioWidget() {
    return SizedBox(
      height: iconSize,
      width: iconSize,
      child: Radio<String>(
        value: value ?? "",
        groupValue: groupValue,
        activeColor: ColorConstant.fromHex("#54a4a4ae"),
        onChanged: (value) {
          onChange!(value!);
        },
        visualDensity: VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
      ),
    );
  }

  _setFontStyle() {
    switch (fontStyle) {
      case(RadioFontStyle.SFProDisplayBlack12):
        return TextStyle(
          color: Colors.black,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.25,
          ),
        );
      default:
        return TextStyle(
          color: ColorConstant.gray500,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.25,
          ),
        );
    }
  }
}

enum RadioFontStyle {
  SFProDisplayLight12,
  SFProDisplayBlack12,
}
