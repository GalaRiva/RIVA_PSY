import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_switch.dart';
import '../../../../widgets/custom_text.dart';
import '../controller.dart';

Widget CardSettingsButtonWidget(BuildContext context,
    {required K6Controller controller,
    VoidCallback? onTap,
    required String svgIcon, double? svgSize,
    required String title,
    Function(bool)? onSwitch,
    bool? valueForSwitch, double height = 44,
    Color? bgColor,
    Color? textColor,
    Color? iconColor}) {
  return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: getVerticalSize(height)),
          padding: getPadding(left: 7, top: 10, right: 7, bottom: 10),
          decoration: AppDecoration.outlineBluegray80014
              .copyWith(borderRadius: BorderRadiusStyle.roundedBorder3,
          color: bgColor ?? ColorConstant.grayLight
          ),
          child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center, children: [
              CustomImageView(
                  svgPath: svgIcon,
                  color: iconColor,
                  height: getVerticalSize(svgSize ?? 20),
                  width: getHorizontalSize(svgSize ?? 20)),
              Expanded(
                  child: Padding(
                    padding: getPadding(left: 21),
                    child: CustomText(title,
                        overflow: TextOverflow.visible,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(fontSize: getFontSize(17), color: textColor)),
                  )),
              onSwitch == null || valueForSwitch == null
                  ? CustomImageView(
                      svgPath: ImageConstant.imgArrowrightGray700,
                      color: iconColor,
                      height: getVerticalSize(8),
                      width: getHorizontalSize(4),
                      margin: getMargin(top: 8, right: 9, bottom: 8))
                  : GetBuilder(
                      builder: (K6Controller _c) => CustomSwitch(
                          value: valueForSwitch,
                          onChanged: onSwitch),
                    )
            ]),
          ));
}
