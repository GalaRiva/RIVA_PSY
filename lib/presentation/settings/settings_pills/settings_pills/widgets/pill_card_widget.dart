import 'dart:math';

import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/models/pill_model.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/settings_pills_edit_bottom_sheet/settings_pills_edit_bottom_sheet.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/image_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_image_view.dart';

Widget PillCardWidget(BuildContext context, {required PillModel pillModel, required bool isSelected, required Function update}) {

  _onTap () {
    showModalBottomSheet (
        backgroundColor: ColorConstant.gray300,
        context: context, builder: (context) => PillsEditBottomSheet(pill: pillModel)).then((value) {
          update();});
  }

  final _bodyHeight = getVerticalSize(pillModel.hoursOfTakingPills.length > 2 ? 47  + ((pillModel.hoursOfTakingPills.length % 2) * 21) : 47);
  String getDurationText () {
    if(pillModel.startDate == null || pillModel.endDate == null) return 'установить длительность приема'.toUpperCase();
    return '${(pillModel.startDate!).dateInText()} - ${pillModel.endDate!.dateInText()}'.toUpperCase();
  }
  return Container(
    height: getVerticalSize(30) + _bodyHeight,
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3)),
    child: Column(
      children: [
        Container(
          height: getVerticalSize(30),
          alignment: Alignment.topCenter,
          decoration: BoxDecoration(
              color: !isSelected
                  ? ColorConstant.fromHex('#7F7F90')
                  : ColorConstant.cyan700,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3),
                topRight: Radius.circular(3),
              )),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: getPadding(left: 6),
                  child: Text(
                    pillModel.name,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white),
                  ),
                ),
                Padding(
                  padding: getPadding(right: 11),
                  child: InkWell(
                    onTap: _onTap,
                    child: Row(
                      children: [
                        Text(
                          'редактировать',
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtSFProDisplayLight9Gray50,
                        ),
                        SizedBox(
                          width: getVerticalSize(7),
                        ),
                        CustomImageView(
                          color: Colors.white,
                          svgPath: ImageConstant.imgVector46,
                          height: getVerticalSize(
                            8,
                          ),
                          width: getHorizontalSize(
                            4,
                          ),
                          radius: BorderRadius.circular(
                            getHorizontalSize(
                              1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
         Container(
            height: _bodyHeight,
            alignment: Alignment.topCenter,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.centerLeft,
                  width: getHorizontalSize(91),
                  decoration: BoxDecoration(
                      color: ColorConstant.grayLight,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(3),
                      )),
                  child: Padding(
                    padding: getPadding(top: 17, bottom: 17, right: 10, left: 10),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Wrap(
                        spacing: getHorizontalSize(18),
                        direction: Axis.horizontal,
                        children: pillModel.hoursOfTakingPills.map((e) => Padding(
                          padding: getPadding(bottom: 10),
                          child: Text(e, style: AppStyle.txtSFProDisplayLight11.copyWith(color: ColorConstant.gray800)),
                        )).toList(),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: getPadding(
                      all: 17
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(getDurationText() ,style: AppStyle.txtSFProDisplayLight11.copyWith(
                        color: ColorConstant.gray800
                      )),
                    ),
                  ),
                )
              ],
            )
          ),

      ],
    ),
  );
}
