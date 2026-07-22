import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

class CustomCheckbox extends StatelessWidget {
  CustomCheckbox(
      {this.fontStyle,
      this.alignment,
      this.isRightCheck = false,
      this.iconSize,
      this.value,
      this.onChange,
      this.text,
      this.width,
      this.margin, this.onTapOnText});

  CheckboxFontStyle? fontStyle;

  Alignment? alignment;

  bool? isRightCheck;

  double? iconSize;

  bool? value;

  Function(bool)? onChange;

  VoidCallback? onTapOnText;

  String? text;

  double? width;

  EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildCheckboxWidget(),
          )
        : _buildCheckboxWidget();
  }

  _buildCheckboxWidget() {
    return Container(
      width: width,
      margin: margin ?? EdgeInsets.zero,
      child: isRightCheck! ? getRightSideCheckbox() : getLeftSideCheckbox(),
    );
  }

  Widget getRightSideCheckbox() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: 8,
          ),
          child: getTextWidget(),
        ),
        getCheckboxWidget(),
      ],
    );
  }

  Widget getLeftSideCheckbox() {
    return Row(
      children: [
        getCheckboxWidget(),
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
    return InkWell(
      onTap: onTapOnText,
      child: Text(
        text ?? "",
        textAlign: TextAlign.center,
        style: _setFontStyle(),
      ),
    );
  }

  Widget getCheckboxWidget() {
    return SizedBox(
      height: iconSize,
      width: iconSize,
      child: Checkbox(
        value: value ?? false,
        onChanged: (value) {
          onChange!(value!);
        },
        checkColor: ColorConstant.fromHex("#1499A1"),
        activeColor: Colors.transparent,
        side: MaterialStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: Colors.white
          ),
        ),
        visualDensity: VisualDensity(
          vertical: -4,
          horizontal: -4,
        ),
      ),
    );
  }

  _setFontStyle() {
    switch (fontStyle) {
      default:
        return TextStyle(
          color: ColorConstant.gray800,
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

enum CheckboxFontStyle { SFProDisplayLight12 }
