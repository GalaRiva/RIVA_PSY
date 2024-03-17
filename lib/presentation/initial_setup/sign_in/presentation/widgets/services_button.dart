import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

Widget ServicesButton(
    {required String svgIcon,
    required String serviceName,
    required VoidCallback onTap}) {
  return SizedBox(
    height: (75),
    child: OutlinedButton(
      
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        side: BorderSide(width: 1, color: ColorConstant.cyan700)
      ),
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Продолжить с $serviceName',
              style: AppStyle.txtSFProDisplayLight16.copyWith(fontSize: 20),
            ),
            SizedBox(width: 30,),
            CustomImageView(
              svgPath: svgIcon,
              height: getSize(50),

              fit: BoxFit.contain,
            )
          ],
        )),
  );
}
