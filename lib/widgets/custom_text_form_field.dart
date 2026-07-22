import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

class CustomTextFormField extends StatelessWidget {
  CustomTextFormField(
      {this.padding,
      this.shape,
      this.variant,
      this.fontStyle,
      this.alignment,
      this.width,
      this.margin,
      this.controller,
      this.focusNode,
      this.isObscureText = false,
      this.textInputAction = TextInputAction.next,
      this.textInputType = TextInputType.text,
      this.maxLines,
      this.hintText,
      this.prefix,
      this.prefixConstraints,
      this.suffix,
      this.suffixConstraints,
      this.validator,
      this.formatter,
      this.maxLength,
      this.counterText,
      this.minLength,
      this.hintStyle, this.color, this.height});

  List<TextInputFormatter>? formatter;

  int? maxLength;

  int? minLength;

  String? counterText;

  TextFormFieldPadding? padding;

  TextFormFieldShape? shape;

  TextFormFieldVariant? variant;

  TextFormFieldFontStyle? fontStyle;

  TextFormFieldFontStyle? hintStyle;

  Alignment? alignment;

  double? width;

  final double? height;

  final Color? color;

  EdgeInsetsGeometry? margin;

  TextEditingController? controller;

  FocusNode? focusNode;

  bool? isObscureText;

  TextInputAction? textInputAction;

  TextInputType? textInputType;

  int? maxLines;

  String? hintText;

  Widget? prefix;

  BoxConstraints? prefixConstraints;

  Widget? suffix;

  BoxConstraints? suffixConstraints;

  FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildTextFormFieldWidget(context),
          )
        : _buildTextFormFieldWidget(context);
  }

  _buildTextFormFieldWidget(context) {
    return Container(
      width: width ?? double.maxFinite,
      height: height,
      margin: margin,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: _setFontStyle(),
        obscureText: isObscureText!,
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();

        },
        textInputAction: textInputAction,
        keyboardType: textInputType,
        maxLines: maxLines ?? 1,
        decoration: _buildDecoration(),
        validator: validator,
        inputFormatters: formatter,
        maxLength: maxLength,
        minLines: minLength,
      ),
    );
  }

  _buildDecoration() {
    return InputDecoration(
      hintText: hintText ?? "",
      hintStyle: _setHintStyle(),
      border: _setBorderStyle(),
      enabledBorder: _setBorderStyle(),
      focusedBorder: _setBorderStyle(),
      disabledBorder: _setBorderStyle(),
      prefixIcon: prefix,
      prefixIconConstraints: prefixConstraints,
      suffixIcon: suffix,
      suffixIconConstraints: suffixConstraints,
      fillColor: color ?? _setFillColor(),
      filled: _setFilled(),
      counterText: counterText,
      isDense: true,
      contentPadding: _setPadding(),
    );
  }

  _setHintStyle() {
    switch (fontStyle) {
      case TextFormFieldFontStyle.SFProDisplayRegular14:
        return TextStyle(
          color: ColorConstant.blueGray400,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.21,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight12:
        return TextStyle(
          color: ColorConstant.blueGray400,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.25,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight14:
        return TextStyle(
          color: ColorConstant.blueGray400,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.21,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight11:
        return TextStyle(
          color: ColorConstant.gray200,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight11Gray800:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight14Cyan700:
        return TextStyle(
          color: ColorConstant.cyan700,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.21,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight12Gray800:
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
      case TextFormFieldFontStyle.SFProDisplayLight11Cyan700:
        return TextStyle(
          color: ColorConstant.cyan700,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayRegular11:
        return TextStyle(
          color: ColorConstant.gray200,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight14Gray800:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.14,
          ),
        );
      default:
        return TextStyle(
          color: ColorConstant.gray900,
          fontSize: getFontSize(
            13,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.20,
          ),
        );
    }
  }

  _setFontStyle() {
    switch (fontStyle) {
      case TextFormFieldFontStyle.SFProDisplayRegular14:
        return TextStyle(
          color: ColorConstant.blueGray400,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.21,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight12:
        return TextStyle(
          color: ColorConstant.blueGray400,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.25,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight12Black:
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
      case TextFormFieldFontStyle.SFProDisplayLight14:
        return TextStyle(
          color: ColorConstant.blueGray400,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.21,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight11:
        return TextStyle(
          color: ColorConstant.gray200,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight11Gray800:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight14Cyan700:
        return TextStyle(
          color: ColorConstant.cyan700,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.21,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight12Gray800:
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
      case TextFormFieldFontStyle.SFProDisplayLight11Cyan700:
        return TextStyle(
          color: ColorConstant.cyan700,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayRegular11:
        return TextStyle(
          color: ColorConstant.gray200,
          fontSize: getFontSize(
            11,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.27,
          ),
        );
      case TextFormFieldFontStyle.SFProDisplayLight14Gray800:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.14,
          ),
        );
      default:
        return TextStyle(
          color: ColorConstant.gray900,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.20,
          ),
        );
    }
  }

  _setOutlineBorderRadius() {
    switch (shape) {
      case TextFormFieldShape.RoundedBorder3:
        return BorderRadius.circular(
          getHorizontalSize(
            3.00,
          ),
        );
      case TextFormFieldShape.CustomBorderBL3:
        return BorderRadius.only(
          topLeft: Radius.circular(
            getHorizontalSize(
              0.00,
            ),
          ),
          topRight: Radius.circular(
            getHorizontalSize(
              0.00,
            ),
          ),
          bottomLeft: Radius.circular(
            getHorizontalSize(
              3.00,
            ),
          ),
          bottomRight: Radius.circular(
            getHorizontalSize(
              3.00,
            ),
          ),
        );
      default:
        return BorderRadius.only(
          topLeft: Radius.circular(
            getHorizontalSize(
              3.00,
            ),
          ),
          topRight: Radius.circular(
            getHorizontalSize(
              3.00,
            ),
          ),
          bottomLeft: Radius.circular(
            getHorizontalSize(
              0.00,
            ),
          ),
          bottomRight: Radius.circular(
            getHorizontalSize(
              0.00,
            ),
          ),
        );
    }
  }

  _setBorderStyle() {
    switch (variant) {
      case TextFormFieldVariant.UnderLineGray50:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstant.gray50,
          ),
        );
      case TextFormFieldVariant.UnderLineWhiteA700:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstant.whiteA700,
          ),
        );
      case TextFormFieldVariant.UnderLineGray8008c:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstant.gray8008c,
          ),
        );
      case TextFormFieldVariant.UnderLineRed:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        );
      case TextFormFieldVariant.Almost:
        return OutlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: BorderSide.none,
        );
      case TextFormFieldVariant.FillGray200:
        return OutlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: BorderSide.none,
        );
      case TextFormFieldVariant.UnderLineCyan7008c:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstant.cyan7008c,
          ),
        );
      case TextFormFieldVariant.UnderLineCyan700:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstant.cyan700,
          ),
        );
      case TextFormFieldVariant.OutlineBluegray60014:
        return OutlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: BorderSide.none,
        );
      case TextFormFieldVariant.None:
        return InputBorder.none;
      default:
        return OutlineInputBorder(
          borderRadius: _setOutlineBorderRadius(),
          borderSide: BorderSide.none,
        );
    }
  }

  _setFillColor() {
    switch (variant) {
      case TextFormFieldVariant.Almost:
        return ColorConstant.gray50;
      case TextFormFieldVariant.FillGray200:
        return ColorConstant.grayLight;
      case TextFormFieldVariant.OutlineBluegray60014:
        return ColorConstant.gray50;
      default:
        return ColorConstant.cyan700;
    }
  }

  _setFilled() {
    switch (variant) {
      case TextFormFieldVariant.UnderLineGray50:
        return false;
      case TextFormFieldVariant.UnderLineWhiteA700:
        return false;
      case TextFormFieldVariant.UnderLineGray8008c:
        return false;
      case TextFormFieldVariant.UnderLineRed:
        return false;
      case TextFormFieldVariant.Almost:
        return true;
      case TextFormFieldVariant.FillGray200:
        return true;
      case TextFormFieldVariant.UnderLineCyan7008c:
        return false;
      case TextFormFieldVariant.UnderLineCyan700:
        return false;
      case TextFormFieldVariant.OutlineBluegray60014:
        return true;
      case TextFormFieldVariant.None:
        return false;
      default:
        return true;
    }
  }

  _setPadding() {
    switch (padding) {
      case TextFormFieldPadding.PaddingAll6:
        return getPadding(
          all: 6,
        );
      case TextFormFieldPadding.PaddingT21:
        return getPadding(
          left: 7,
          top: 21,
          right: 7,
          bottom: 21,
        );
      case TextFormFieldPadding.PaddingT9:
        return getPadding(
          left: 6,
          top: 9,
          right: 6,
          bottom: 9,
        );
      default:
        return getPadding(
          left: 6,
          top: 8,
          bottom: 8,
        );
    }
  }
}

enum TextFormFieldPadding {
  PaddingAll6,
  PaddingT8,
  PaddingT21,
  PaddingT9,
}
enum TextFormFieldShape {
  RoundedBorder3,
  CustomBorderTL3,
  CustomBorderBL3,
}
enum TextFormFieldVariant {
  None,
  UnderLineGray50,
  UnderLineWhiteA700,
  UnderLineGray8008c,
  UnderLineRed,
  Almost,
  Accent,
  FillGray200,

  UnderLineCyan7008c,
  UnderLineCyan700,
  OutlineBluegray60014,
}
enum TextFormFieldFontStyle {
  SFProDisplayLight10,
  SFProDisplayRegular14,
  SFProDisplayLight12,
  SFProDisplayLight12Black,
  SFProDisplayLight14,
  SFProDisplayLight11,
  SFProDisplayLight11Gray800,
  SFProDisplayLight14Cyan700,
  SFProDisplayLight12Gray800,
  SFProDisplayLight11Cyan700,
  SFProDisplayRegular11,
  SFProDisplayLight14Gray800,
}
