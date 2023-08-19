import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_switch.dart';
import '../controller.dart';

Widget CardSettingsButtonWidget(BuildContext context,
    {required K6Controller controller,
    VoidCallback? onTap,
    required String svgIcon, double? svgSize,
    required String title,
    Function(bool)? onSwitch,
    bool? valueForSwitch, double height = 38}) {
  return InkWell(
      onTap: onTap,
      child: Container(
        height: getVerticalSize(height),
          padding: getPadding(left: 7, top: 5, right: 7, bottom: 5),
          decoration: AppDecoration.outlineBluegray80014
              .copyWith(borderRadius: BorderRadiusStyle.roundedBorder3),
          child: Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start, children: [
              CustomImageView(
                  svgPath: svgIcon,
                  height: getVerticalSize(svgSize ?? 20),
                  width: getHorizontalSize(svgSize ?? 20),
                  margin: getMargin(top: 3, bottom: 5)),
              Padding(
                  padding: getPadding(left: 21, top: 5, bottom: 2),
                  child: Text(title,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtSFProDisplayLight16)),
              Spacer(),
              onSwitch == null || valueForSwitch == null
                  ? CustomImageView(
                      svgPath: ImageConstant.imgArrowrightGray700,
                      height: getVerticalSize(8),
                      width: getHorizontalSize(4),
                      margin: getMargin(top: 8, right: 9, bottom: 8))
                  : GetBuilder(
                      builder: (K6Controller _c) => CustomSwitch(
                          value: valueForSwitch,
                          onChanged: onSwitch),
                    )
            ]),
          )));
}
