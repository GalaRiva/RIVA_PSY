import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import 'custom_text.dart';

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
      this.bgColor,
      this.textStyle,
      this.centralWidget,
      this.textIsFitted = false,
      this.standardPadding,
      this.showBorder = true,
      this.minHeight,
      this.borderRadius,
      this.borderColor});

  ButtonShape? shape;

  // Per-instance corner radius override — most call sites share the
  // `shape`-driven default (~3px), but a few screens want a softer,
  // more rounded look without changing every CustomButton in the app.
  final double? borderRadius;

  // Per-instance border color/opacity override — the `showBorder` default
  // is a hard solid white 1px edge, too stark for a "translucent glass"
  // fill on a flat (non-varied) background, where alpha blending alone
  // can't read as translucent (it's pixel-identical to a solid color over
  // a uniform backdrop) — a soft edge is the substitute visual cue.
  final Color? borderColor;

  final Widget? centralWidget;
  final bool textIsFitted;
  final Color? bgColor;
  ButtonPadding? padding;

  EdgeInsetsGeometry? standardPadding;

  ButtonVariant? variant;

  final bool showBorder;

  ButtonFontStyle? fontStyle;
  TextStyle? textStyle;

  Alignment? alignment;

  EdgeInsetsGeometry? margin;

  VoidCallback? onTap;

  double? width;

  double? height;

  // Opt-in: when set, the button grows to fit wrapped multi-line text
  // (e.g. a translation longer than the Russian original) instead of
  // clipping it at a fixed `height`. Other call sites are unaffected —
  // they keep passing `height` and get the old fixed-height behavior.
  final double? minHeight;

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        width: width ?? double.maxFinite,
        height: minHeight != null ? null : (height ?? 50),
        // No maxHeight here left prefix/suffix icons that don't specify
        // their own size (many call sites just pass an SvgPicture with no
        // width/height) free to claim unbounded height once the fixed
        // `height` constraint was gone — the button ballooned to fill the
        // whole screen instead of just growing enough for 2 lines of text.
        constraints: minHeight != null
            ? BoxConstraints(minHeight: minHeight!, maxHeight: minHeight! * 2.2)
            : null,
        padding: minHeight != null
            ? getPadding(top: 6, bottom: 6, left: 6, right: 6)
            : null,
        decoration: _buildTextButtonStyle(),
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
          // Flexible bounds the text to whatever width the icon(s) leave
          // — without it, a plain Row child gets its own unconstrained
          // natural width, so a translation longer than the original
          // (e.g. English "CHOOSING AN EMOTION" vs Russian) doesn't wrap;
          // it just overflows past the button and behind whatever's
          // drawn next to it.
          Flexible(child: _getCentralWidget()),
          suffixWidget ?? SizedBox(),
        ],
      );
    } else {
      return _getCentralWidget();
    }
  }

  _getCentralWidget() {
    return Center(
      child: centralWidget ??
          (textIsFitted
              ? FittedBox(
                  fit: BoxFit.scaleDown,
                  child: CustomText(
                    text ?? "",
                    textAlign: TextAlign.center,
                    style: textStyle ?? _setFontStyle(),
                  ),
                )
              : CustomText(
                  text ?? "",
                  textAlign: TextAlign.center,
                  style: textStyle ?? _setFontStyle(),
                )),
    );
  }

  _buildTextButtonStyle() {
    return BoxDecoration(
      borderRadius: _setBorderRadius(),
      // Was `bgColor ?? Colors.white.withOpacity(0.7) ?? _setColor()` —
      // Colors.white.withOpacity(0.7) is never null, so `?? _setColor()`
      // was permanently unreachable. Every CustomButton that relies on
      // `variant` instead of an explicit `bgColor` (e.g. ButtonVariant.Cyan)
      // has been silently rendering as translucent white instead of its
      // intended color for as long as this line existed.
      color: bgColor ?? _setColor(),
      border: !showBorder
          ? null
          : Border.all(color: borderColor ?? Colors.white, width: 1),
      boxShadow: [
        BoxShadow(
            color: ColorConstant.fromHex('#5F6B80').withOpacity(0.2),
            offset: Offset(0, 6),
            blurRadius: 5)
      ],
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
    if (bgColor != null) return bgColor!;
    switch (variant) {
      case ButtonVariant.OutlineBluegray60014:
        return ColorConstant.whiteA70070;
      case ButtonVariant.OutlineBluegray70038:
        return ColorConstant.gray100C4;
      case ButtonVariant.Almost:
        return ColorConstant.gray50;
      case ButtonVariant.Base:
        return ColorConstant.fromHex('#e0e8e8');
      case ButtonVariant.OutlineGray:
        return Colors.transparent;
      case ButtonVariant.Cyan:
        return ColorConstant.cyan700;
      case ButtonVariant.White:
        return Colors.white;
      case ButtonVariant.White24:
        return Colors.white.withOpacity(0.44);
      default:
        return Colors.white.withOpacity(0.7);
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
      case ButtonVariant.OutlineGray:
        return BorderSide(
          color: ColorConstant.blueGray400,
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
        Border.all(color: Colors.white, width: 1);
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
    if (borderRadius != null)
      return BorderRadius.circular(getHorizontalSize(borderRadius!));
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
            16,
          ),
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.25,
          ),
        );
      case ButtonFontStyle.White16:
        return TextStyle(
          color: Colors.white,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.25,
          ),
        );
      case ButtonFontStyle.Gray16:
        return TextStyle(
          color: ColorConstant.blueGray400,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Manrope',
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
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w300,
          height: getVerticalSize(
            1.21,
          ),
        );
      case ButtonFontStyle.SFProDisplayRegular10:
        return TextStyle(
          color: ColorConstant.deepPurple600,
          fontSize: getFontSize(
            17,
          ),
          fontFamily: 'Manrope',
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
          fontFamily: 'Manrope',
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
          fontFamily: 'Manrope',
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
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.25,
          ),
        );
      case ButtonFontStyle.DeepPurple16:
        return TextStyle(
          color: ColorConstant.deepPurple600,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Manrope',
          fontWeight: FontWeight.w400,
          height: getVerticalSize(
            1.25,
          ),
        );
      default:
        return TextStyle(
          color: ColorConstant.deepPurple600,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Manrope',
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
  OutlineGray,
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
  White16,
  Gray16,
  DeepPurple16,
  SFProDisplayLight14,
  SFProDisplayRegular10,
  SFProDisplayLight10,
  SFProDisplayRegular9,
}
