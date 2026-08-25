import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../../widgets/body_widget.dart';
import '../../../../widgets/second_variant_event_card.dart';
import '../controller.dart';
import 'day_event_body_widget.dart';

class DayEventWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final List<DayEventModel> dayEventModels;

  const DayEventWidget({Key? key, required this.dayEventModels, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: getMargin(left: 10, right: 10),
      decoration: BoxDecoration(
          color: ColorConstant.fromHex('#F9F9F9'),
          borderRadius: BorderRadius.circular(3)),
      child: Column(
        children: [
          Container(
            height: getVerticalSize(30),
            alignment: Alignment.topCenter,

            decoration: BoxDecoration(
              color: ColorConstant.cyan700,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(3), topRight:  Radius.circular(3),)
            ),
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: getPadding(left: 6),
                    child: Text(
                      (dayEventModels.first.date ?? DateTime.now())!.weekday.dayInText() +
                          ' ' +
                          (dayEventModels.first.date ?? DateTime.now())!.day.toString() +
                          ' ' +
                          (dayEventModels.first.date ?? DateTime.now())!.month.monthInText() +
                          ' ' +
                          (dayEventModels.first.date ?? DateTime.now())!.year.toString(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtSFProDisplayLight11.copyWith(
                        letterSpacing: getHorizontalSize(
                          0.44,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: getPadding(right: 11),
                    child: InkWell(
                      onTap: onTap,
                      child: Row(
                        children: [
                          Text(
                            'redo'.tr(),
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
          GetBuilder(
            builder: (K49Controller _c) => Column(
              children: [
                for (int index = 0; index < dayEventModels.length; index++)
                  dayEventBodyWidget(dayEventModels[index], index == 0 ? false : true),
              ],
            ),
          )
        ],
      ),
    );
  }
}
