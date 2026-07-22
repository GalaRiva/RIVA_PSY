import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../core/utils/color_constant.dart';

Widget CustomCheckboxNotification (bool isTrue) {
  return Stack(
    children: [
      Visibility(
        visible: isTrue,
        child: Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: Colors.white),
          ),
          child: Container(
              margin: getMargin(all: 2),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                color: ColorConstant.teal200,

              ),

          ),
        ),
      ),
      Visibility(
        visible: !isTrue,
        child: Container(
          height: 15,
          width: 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: ColorConstant.gray50054.withOpacity(0.33),
            border: Border.all(color: ColorConstant.fromHex('#BCBFD1')),
          ),
        ),
      ),
    ],
  );
}