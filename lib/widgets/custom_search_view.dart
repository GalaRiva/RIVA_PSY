import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

class CustomSearchView extends StatelessWidget {
  CustomSearchView(
      {this.variant,
      this.fontStyle,
      this.alignment,
      this.width,
      this.margin,
      this.controller,
      this.focusNode,
      this.hintText,
      this.prefix,
      this.prefixConstraints,
      this.suffix,
      this.suffixConstraints,
      this.onChange,
        this.onSubmit});

  SearchViewVariant? variant;

  Function(String)? onChange;

  Function(String)? onSubmit;

  SearchViewFontStyle? fontStyle;

  Alignment? alignment;

  double? width;

  EdgeInsetsGeometry? margin;

  TextEditingController? controller;

  FocusNode? focusNode;

  String? hintText;

  Widget? prefix;

  BoxConstraints? prefixConstraints;

  Widget? suffix;

  BoxConstraints? suffixConstraints;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildSearchViewWidget(),
          )
        : _buildSearchViewWidget();
  }

  _buildSearchViewWidget() {
    return Container(
      width: width ?? double.maxFinite,
      margin: margin,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        style: _setFontStyle(),
        decoration: _buildDecoration(),
        onChanged: (val) {
          onChange == null ? null : onChange!(val);
        },
        onFieldSubmitted: (val) {
          onSubmit == null ? null : onSubmit!(val!);
        },
      ),
    );
  }

  _buildDecoration() {
    return InputDecoration(
      hintText: hintText ?? "",
      hintStyle: _setFontStyle(),
      border: _setBorderStyle(),
      enabledBorder: _setBorderStyle(),
      focusedBorder: _setBorderStyle(),
      disabledBorder: _setBorderStyle(),
      prefixIcon: prefix,
      prefixIconConstraints: prefixConstraints,
      suffixIcon: suffix,
      suffixIconConstraints: suffixConstraints,
      filled: _setFilled(),
      isDense: true,
    );
  }

  _setFontStyle() {
    switch (fontStyle) {
      case SearchViewFontStyle.SFProDisplayLight14Gray800:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.21,
          ),
        );
      default:
        return TextStyle(
          color: ColorConstant.gray800A0,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.21,
          ),
        );
    }
  }

  _setBorderStyle() {
    switch (variant) {
      case SearchViewVariant.UnderLineWhiteA700:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstant.whiteA700,
          ),
        );
      case SearchViewVariant.None:
        return InputBorder.none;
      default:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: ColorConstant.gray8008c,
          ),
        );
    }
  }

  _setFilled() {
    switch (variant) {
      case SearchViewVariant.UnderLineGray8008c:
        return false;
      case SearchViewVariant.None:
        return false;
      default:
        return false;
    }
  }
}

enum SearchViewVariant {
  None,
  UnderLineGray8008c,
  UnderLineWhiteA700,
}
enum SearchViewFontStyle {
  SFProDisplayLight14,
  SFProDisplayLight14Gray800,
}
