import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../../../../../theme/app_style.dart';

import '../controller.dart';

Widget CardDataAndRecoveryButtonWidget(BuildContext context,
    {required DataAndRecoveryController controller,
    VoidCallback? onTap,
    required String title,
    Widget? suffixWidget
    }) {
  return InkWell(
      onTap: onTap,
      child: Container(
          margin: getMargin(top: 1),
          padding: getPadding(left: 7, top: 5, right: 7, bottom: 5),
          decoration: AppDecoration.outlineBluegray80014
              .copyWith(
              color: ColorConstant.grayLight,
              borderRadius: BorderRadiusStyle.roundedBorder3),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
                padding: getPadding(left: 5, top: 5, bottom: 2),
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtSFProDisplayLight16)),
            Spacer(),
            GetBuilder(
                    builder: (DataAndRecoveryController _c) => suffixWidget!,
                  )
          ])));
}
