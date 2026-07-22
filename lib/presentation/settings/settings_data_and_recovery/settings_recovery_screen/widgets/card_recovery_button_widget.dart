import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../../../../../theme/app_style.dart';

import '../controller.dart';

Widget CardRecoveryButtonWidget(BuildContext context,
    {required RecoveryController controller,
    VoidCallback? onTap,
    required String title,
      required String subTitle,
      Widget? suffixWidget
    }) {
  return InkWell(
      onTap: onTap,
      child: Container(
          width: size.width - 32,
          margin: getMargin(top: 1),
          padding: getPadding(left: 7, top: 5, right: 7, bottom: 5),
          decoration: AppDecoration.outlineBluegray80014
              .copyWith(borderRadius: BorderRadiusStyle.roundedBorder3,
            color: ColorConstant.grayLight,

          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
                padding: getPadding(left: 5, top: 5, bottom: 2),
                child: Column(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtSFProDisplayLight16),
                    Text(subTitle,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtSFProDisplayLight11Gray800),
                  ],
                )),
            Spacer(),
            GetBuilder(
                    builder: (RecoveryController _c) => suffixWidget!,
                  )
          ])));
}
