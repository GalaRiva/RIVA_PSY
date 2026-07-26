import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/desire/desire.dart';
import 'package:riva_psy/core/utils/color_constant.dart';

import '../../../../../../core/utils/image_constant.dart';

class DesirePathItem extends StatelessWidget {
  final Desire desire;
  final Function()? onTap;

  const DesirePathItem({Key? key, required this.desire, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 72,
        width: 187,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: 187,
              height: 40,
              padding: EdgeInsets.only(left: 80),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: desire.completed
                      ? ColorConstant.lightGreen
                      : desire.dateOfExecution.isAfter(DateTime.now())
                          ? Colors.white
                          : ColorConstant.lightText),
              child: Row(
                children: [
                  Text(
                    desire.completed
                        ? 'executed_1'.tr()
                        : desire.dateOfExecution.isAfter(DateTime.now())
                            ? 'executing'.tr()
                            : 'lost'.tr(),
                    style: AppStyle.txtSFProDisplayLight14.copyWith(
                        color: desire.completed
                            ? Colors.white
                            : desire.dateOfExecution.isAfter(DateTime.now())
                                ? Colors.black
                                : Colors.white, fontSize: 15),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  desire.completed
                      ? SvgPicture.asset(ImageConstant.desireCheckSVG, height: 17,)
                      : desire.dateOfExecution.isAfter(DateTime.now())
                      ? SvgPicture.asset(ImageConstant.desireInProcess2SVG, height: 17,)
                      : Container()
                ],
              ),
            ),
            Container(
              height: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: desire.completed
                      ? ColorConstant.lightGreen
                      : desire.dateOfExecution.isAfter(DateTime.now())
                          ? Colors.white
                          : ColorConstant.lightText),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                desire.completed
                    ? ImageConstant.desireIconPNG
                    : desire.dateOfExecution.isAfter(DateTime.now())
                        ? ImageConstant.desireIconPNG
                        : ImageConstant.desireExpiredIconPNG,
                fit: BoxFit.fill,
              ),
            ),
            Align(alignment: Alignment.topCenter,
            child: Text(DateFormat('dd.MM.yyyy').format(desire.dateOfExecution), style: AppStyle.txtSFProDisplayLight12,),
            )
          ],
        ),
      ),
    );
  }
}
