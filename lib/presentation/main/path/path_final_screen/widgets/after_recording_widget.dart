import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/image_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_icon_button.dart';
import '../../../../../widgets/custom_image_view.dart';

Widget afterRecording (BuildContext context) {
  return Container(
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
            svgPath: ImageConstant.imgMicrophoneGray800,
          ),
        ),
        Padding(
          padding: getPadding(
            left: 38,
            top: 10,
            bottom: 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'record_save'.tr(),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight14Gray800,
              ),
              Padding(
                padding: getPadding(
                  top: 1,
                ),
                child: Text(
                  'record_keep'.tr(),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppStyle.txtSFProDisplayLight9Gray800,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}