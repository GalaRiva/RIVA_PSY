import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

Widget ServicesButton(
    {required String svgIcon,
    required String serviceName,
    required VoidCallback onTap}) {
  return SizedBox(
    height: getVerticalSize(48),
    child: OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(width: 1, color: ColorConstant.cyan700)
      ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Продолжить с $serviceName',
              style: AppStyle.txtSFProDisplayLight12,
            ),
            SizedBox(width: 6,),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: CustomImageView(
                svgPath: svgIcon,
                height: getSize(25),
                width: getSize(25),
              ),
            )
          ],
        )),
  );
}
