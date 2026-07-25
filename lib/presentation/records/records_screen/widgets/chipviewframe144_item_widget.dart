import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// ignore: must_be_immutable
class Chipviewframe144ItemWidget extends StatelessWidget {
  Chipviewframe144ItemWidget();

  @override
  Widget build(BuildContext context) {
    return RawChip(
      padding: getPadding(
        right: 3,
      ),
      showCheckmark: false,
      labelPadding: EdgeInsets.zero,
      label: Text(
        'rest'.tr(),
        textAlign: TextAlign.left,
        style: TextStyle(
          color: ColorConstant.deepPurple600,
          fontSize: getFontSize(
            9,
          ),
          fontFamily: 'SF Pro Display',
          fontWeight: FontWeight.w400,
        ),
      ),
      avatar: CustomImageView(
        svgPath: ImageConstant.imgAlarmBlueGray700,
        height: getVerticalSize(
          10,
        ),
        width: getHorizontalSize(
          18,
        ),
        margin: getMargin(
          right: 4,
        ),
      ),
      selected: false,
      backgroundColor: ColorConstant.gray100C4,
      selectedColor: ColorConstant.gray100C4,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: ColorConstant.blueGray70038,
          width: getHorizontalSize(
            1,
          ),
        ),
        borderRadius: BorderRadius.circular(
          getHorizontalSize(
            3,
          ),
        ),
      ),
      onSelected: (value) {},
    );
  }
}
