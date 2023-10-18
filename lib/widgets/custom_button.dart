import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {this.shape,
      this.padding,
      this.variant,
      this.fontStyle,
      this.alignment,
      this.margin,
      this.onTap,
      this.width,
      this.height,
      this.text,
      this.prefixWidget,
      this.suffixWidget,
        this.centralWidget,
      this.standardPadding});

  ButtonShape? shape;

  final Widget? centralWidget;

  ButtonPadding? padding;

  EdgeInsetsGeometry? standardPadding;

  ButtonVariant? variant;

  ButtonFontStyle? fontStyle;

  Alignment? alignment;

  EdgeInsetsGeometry? margin;

  VoidCallback? onTap;

  double? width;

  double? height;

  String? text;

  Widget? prefixWidget;

  Widget? suffixWidget;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment!,
            child: _buildButtonWidget(),
          )
        : _buildButtonWidget();
  }

  _buildButtonWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: TextButton(
        onPressed: onTap,
        style: _buildTextButtonStyle(),
        child: _buildButtonWithOrWithoutIcon(),
      ),
    );
  }

  _buildButtonWithOrWithoutIcon() {
    if (prefixWidget != null || suffixWidget != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          prefixWidget ?? SizedBox(),
          _getCentralWidget (),
          suffixWidget ?? SizedBox(),
        ],
      );
    } else {
      return _getCentralWidget ();
    }
  }

  _getCentralWidget () {
    return Center(
      child: centralWidget ?? Text(
        text ?? "",
        textAlign: TextAlign.center,
        style: _setFontStyle(),
      ),
    );
  }

  _buildTextButtonStyle() {
    return ElevatedButton.styleFrom(
      fixedSize: Size(
        width ?? double.maxFinite,
        height ?? getVerticalSize(40),
      ),
      elevation: 10,
      padding: standardPadding == null ? _setPadding() : standardPadding,
      backgroundColor: _setColor(),
      side: _setTextButtonBorder(),
      shadowColor: _setTextButtonShadowColor(),
      shape: RoundedRectangleBorder(
        borderRadius: _setBorderRadius(),
      ),
    );
  }

  _setPadding() {
    switch (padding) {
      case ButtonPadding.PaddingT8:
        return getPadding(
          top: 8,
          right: 8,
          bottom: 8,
        );
      case ButtonPadding.PaddingAll19:
        return getPadding(
          all: 19,
        );
      case ButtonPadding.PaddingT3:
        return getPadding(
          top: 3,
          right: 3,
          bottom: 3,
        );
      default:
        return getPadding(
          all: 8,
        );
    }
  }

  _setColor() {
    switch (variant) {
      case ButtonVariant.OutlineBluegray60014:
        return ColorConstant.whiteA70070;
      case ButtonVariant.OutlineBluegray70038:
        return ColorConstant.gray100C4;
      case ButtonVariant.Almost:
        return ColorConstant.gray50;
      case ButtonVariant.Base:
        return ColorConstant.fromHex('#e0e8e8');
      case ButtonVariant.Cyan:
        return ColorConstant.cyan700;
      case ButtonVariant.White:
        return Colors.white;
      case ButtonVariant.White24:
        return Colors.white.withOpacity(0.44);
      default:
        return ColorConstant.whiteA70038;
    }
  }

  _setTextButtonBorder() {
    switch (variant) {
      case ButtonVariant.OutlineBluegray70038:
        return BorderSide(
          color: ColorConstant.blueGray70038,
          width: getHorizontalSize(
            1.00,
          ),
        );
      case ButtonVariant.Almost:
        return BorderSide(
          color: ColorConstant.blueGray70001,
          width: getHorizontalSize(
            1.00,
          ),
        );
      default:
        return null;
    }
  }

  _setTextButtonShadowColor() {
    switch (variant) {
      case ButtonVariant.OutlineBluegray60014:
        return ColorConstant.blueGray60014;
      case ButtonVariant.OutlineBluegray70038:
      case ButtonVariant.Almost:
        return null;
      default:
        return ColorConstant.blueGray60014;
    }
  }

  _setBorderRadius() {
    switch (shape) {
      case ButtonShape.Square:
        return BorderRadius.circular(0);
      default:
        return BorderRadius.circular(
          getHorizontalSize(
            3.00,
          ),
        );
    }
  }

  _setFontStyle() {
    switch (fontStyle) {
      case ButtonFontStyle.SFProDisplayRegular12Cyan700:
        return TextStyle(
          color: ColorConstant.cyan700,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.25,
          ),
        );
      case ButtonFontStyle.SFProDisplayLight14:
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
      case ButtonFontStyle.SFProDisplayRegular10:
        return TextStyle(
          color: ColorConstant.deepPurple600,
          fontSize: getFontSize(
            10,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.20,
          ),
        );
      case ButtonFontStyle.SFProDisplayLight10:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            10,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.20,
          ),
        );
      case ButtonFontStyle.SFProDisplayRegular9:
        return TextStyle(
          color: ColorConstant.deepPurple600,
          fontSize: getFontSize(
            9,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.22,
          ),
        );
      case ButtonFontStyle.SFProDisplayRegular12Gray:
        return TextStyle(
          color: ColorConstant.gray900,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.25,
          ),
        );
      default:
        return TextStyle(
          color: ColorConstant.deepPurple600,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.25,
          ),
        );
    }
  }
}

enum ButtonShape {
  Square,
  RoundedBorder3,
}
enum ButtonPadding {
  PaddingT8,
  PaddingAll8,
  PaddingAll19,
  PaddingT3,
  PaddingBottom20
}
enum ButtonVariant {
  OutlineBluegray60014_1,
  OutlineBluegray60014,
  OutlineBluegray70038,
  Almost,
  Cyan,
  Base,
  White,
  White24

}
enum ButtonFontStyle {
  SFProDisplayRegular12,
  SFProDisplayRegular12Gray,
  SFProDisplayRegular12Cyan700,
  SFProDisplayLight14,
  SFProDisplayRegular10,
  SFProDisplayLight10,
  SFProDisplayRegular9,
}
