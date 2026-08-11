import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';

import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_image_view.dart';
import '../controller.dart';

class TextForSelectPeriodWidget extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final String? text;
  final K61Controller controller;

  const TextForSelectPeriodWidget(
      {Key? key,
      required this.start,
      required this.end,
      this.text,
      required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final result = (await Navigator.pushNamed(context, AppRoutes.charts_calendar))
            as Map<String, dynamic>;
        if (result != null) {
          DateTime start = result['start'];
          DateTime end = result['end'];
          controller.dateStart = start;
          controller.dateEnd = end;
          controller.emotions = await controller.getEmotions();
          controller.dataForChart = await controller.getIntensity();
          controller.update();
        }
      },
      child: Row(
        children: [
          Text(
            text ??
                "${start.day.timeFormatted()}.${start.month.timeFormatted()}.${start.year}-${end.day.timeFormatted()}.${end.month.timeFormatted()}.${end.year}",
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            // Was fontSize 20 — twice the size of the other card headers
            // (txtSFProDisplayLight14Gray800, size 14) it sits next to,
            // making it look out of place rather than just "readable".
            style: AppStyle.txtSFProDisplayLight10.copyWith(fontSize: getFontSize(14)),
          ),
          CustomImageView(
            svgPath: ImageConstant.rightArrow,
            height: getVerticalSize(
              6,
            ),
            width: getHorizontalSize(
              3,
            ),
            radius: BorderRadius.circular(
              getHorizontalSize(
                1,
              ),
            ),
            margin: getMargin(
              left: 5,
              top: 6,
              bottom: 4,
            ),
          ),
        ],
      ),
    );
  }
}
