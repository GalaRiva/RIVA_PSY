import 'package:flutter/material.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/image_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_icon_button.dart';
import '../../../../../widgets/custom_image_view.dart';

Widget beforeRecording (BuildContext context) => Container(
  margin: getMargin(
    top: 35,
  ),
  padding: getPadding(
    all: 10,
  ),
  decoration: AppDecoration.outlineBluegray600143.copyWith(
    color: ColorConstant.grayLight,

    borderRadius: BorderRadiusStyle.roundedBorder3,
  ),
  child: Row(
    children: [
      CustomIconButton(
        height: 43,
        width: 43,
        shape: IconButtonShape.RoundedBorder21,
        padding: IconButtonPadding.PaddingAll9,
        child: CustomImageView(
          svgPath: ImageConstant.imgMicrophone,
        ),
      ),
      Padding(
        padding: getPadding(
          left: 38,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Выговориться",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Cyan700,
            ),
            Padding(
              padding: getPadding(
                top: 1,
              ),
              child: Text(
                "Создать голосовую запись",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight9,
              ),
            ),
            Text(
              "Запись хранится на вашем устройстве",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight9,
            ),
          ],
        ),
      ),
      Spacer(),
      CustomImageView(
        svgPath: ImageConstant.imgVector46,
        height: getVerticalSize(
          8,
        ),
        width: getHorizontalSize(
          4,
        ),
        radius: BorderRadius.circular(
          getHorizontalSize(
            1,
          ),
        ),
        margin: getMargin(
          top: 18,
          right: 8,
          bottom: 17,
        ),
      ),
    ],
  ),
);