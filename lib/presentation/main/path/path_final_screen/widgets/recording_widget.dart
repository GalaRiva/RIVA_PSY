import 'package:flutter/material.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/image_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_icon_button.dart';
import '../../../../../widgets/custom_image_view.dart';

Widget recording (BuildContext context, String timer) => Container(
  height: getVerticalSize(63),
  width: MediaQuery.of(context).size.width - 20,
  decoration: AppDecoration.glassCard,
  child: Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          SizedBox(width: getHorizontalSize(10),),
          Container(
            padding: getPadding(left: 10),
            height: getSize(19),
            width: getSize(19),
            decoration: BoxDecoration(
                color: ColorConstant.cyan700,
                borderRadius: BorderRadius.circular(100)
            ),
          ),
        ],
      ),
      Container(
        padding: getPadding(all: 4),
        width: getHorizontalSize(101),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(timer, style: AppStyle.txtSFProDisplayLight14Black,),
            Container(
              height: getSize(54),
              width: getSize(54),
              decoration: BoxDecoration(
                color: ColorConstant.teal200,
                borderRadius: BorderRadius.circular(100)
              ),
              child: Container(
                alignment: Alignment.center,
                margin: getMargin(all: 4),
                decoration: BoxDecoration(
                    color: ColorConstant.fromHex('#1499A2'),
                    borderRadius: BorderRadius.circular(100)
                ),
                child: CustomIconButton(
                  height: getSize(39),
                  width: getSize(39),
                  shape: IconButtonShape.RoundedBorder21,
                  child: CustomImageView(
                    svgPath: ImageConstant.imgMicrophone,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            )
          ],
        ),
      )

    ],
  ),
);

//Overlay.of(context).