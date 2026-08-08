import 'dart:io';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

class AppStyle {
  static TextStyle txtSFProDisplayLight12Deeppurple600 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Gray8008c = TextStyle(
    color: ColorConstant.gray8008c,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight8Gray500 = TextStyle(
    color: ColorConstant.gray500,
    fontSize: getFontSize(
      8,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight8blueGray = TextStyle(
    color: ColorConstant.bluegray400,
    fontSize: getFontSize(
      8,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight11Cyan7001 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtAkrobatBold20 = TextStyle(
    color: ColorConstant.whiteA700,
    fontSize: getFontSize(
      20,
    ),
    fontFamily: 'Akrobat',
    fontWeight: FontWeight.w700,
  );

  static TextStyle txtSFProDisplayLight16 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight16Gray = TextStyle(
    color: ColorConstant.grayTextColor,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );


  static TextStyle txtSFProDisplayLight16DeepPurple = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Cyan700 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight20 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      20,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight16Cyan700 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtRobotoRegular20 = TextStyle(
    color: ColorConstant.black900,
    fontSize: getFontSize(
      20,
    ),
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight11Cyan700 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular11Gray80038 = TextStyle(
    color: ColorConstant.gray80038,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight10 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      10,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight10w400 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      10,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight10Gray800 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      Platform.isIOS ? 12 : 10,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );


  static TextStyle txtSFProDisplayLight12 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight11 = TextStyle(
    color: ColorConstant.gray200,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight9Gray50 = TextStyle(
    color: ColorConstant.gray50,
    fontSize: getFontSize(
      9,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight11Gray8001 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Gray800a0 = TextStyle(
    color: ColorConstant.gray800A0,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Gray8006e = TextStyle(
    color: ColorConstant.gray8006e,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Gray800 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular14Deeppurple600 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight9 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      9,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight12Gray800 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Cyan700a0 = TextStyle(
    color: ColorConstant.cyan700A0,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtH2 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w300,
  );

  static TextStyle txtSFProDisplayLight11Deeppurple600 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtH1 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      24,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w300,
  );

  static TextStyle txtSFProDisplayLight14Gray80038 = TextStyle(
    color: ColorConstant.gray80038,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular14 = TextStyle(
    color: ColorConstant.blueGray400,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular11 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular12 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular12Gray800 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Gray80078 = TextStyle(
    color: ColorConstant.gray80078,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Black = TextStyle(
    color: Colors.black,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular11Gray800 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight12Gray80096 = TextStyle(
    color: ColorConstant.gray80096,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Gray80070 = TextStyle(
    color: ColorConstant.gray80070,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayMedium9 = TextStyle(
    color: ColorConstant.whiteA700,
    fontSize: getFontSize(
      9,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight10Gray8001 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      10,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtAkrobatBold20Cyan700 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      20,
    ),
    fontFamily: 'Akrobat',
    fontWeight: FontWeight.w700,
  );

  static TextStyle txtSFProDisplayLight12Gray800a0 = TextStyle(
    color: ColorConstant.gray800A0,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular11Cyan700 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight9Gray800 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      9,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular11Gray80054 = TextStyle(
    color: ColorConstant.gray80054,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight10Cyan700 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      10,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight12Cyan700 = TextStyle(
    color: ColorConstant.cyan700,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular9 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      9,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayRegular9Deeppurple600 = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      9,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight14Gray800a01 = TextStyle(
    color: ColorConstant.gray800A0,
    fontSize: getFontSize(
      14,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtH1WhiteA700 = TextStyle(
    color: ColorConstant.whiteA700,
    fontSize: getFontSize(
      24,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w300,
  );

  static TextStyle txtSFProDisplayThin12 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w300,
  );

  static TextStyle txtRobotoRegular16 = TextStyle(
    color: ColorConstant.bluegray400,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Roboto',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayThin16 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      16,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w300,
  );

  static TextStyle txtSFProDisplayLight12Gray500 = TextStyle(
    color: ColorConstant.gray500,
    fontSize: getFontSize(
      12,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight11Bluegray400 = TextStyle(
    color: ColorConstant.blueGray400,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );

  static TextStyle txtSFProDisplayLight11Gray800 = TextStyle(
    color: ColorConstant.gray800,
    fontSize: getFontSize(
      11,
    ),
    fontFamily: 'Manrope',
    fontWeight: FontWeight.w400,
  );
}
