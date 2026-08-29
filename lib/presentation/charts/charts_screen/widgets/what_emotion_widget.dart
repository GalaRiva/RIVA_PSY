import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';
import '../controller.dart';
import '../models/emotion_model.dart';
import 'text_for_select_period_widget.dart';
import '../../../../widgets/emotion_pie_chart.dart';
import '../../../../widgets/emotion_bubble_chart.dart';

class WhatEmotionWidget extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final VoidCallback? onPeriodTap;
  final List<EmotionModel> emotions;
  final List<EmotionModel> emotionsTypes;
  final K61Controller controller;
  const WhatEmotionWidget(
      {Key? key, required this.start, required this.end, this.onPeriodTap, required this.emotions, required this.emotionsTypes, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _sum (List<EmotionModel> list) {
      double _s = 0;
      for(var item in list) _s += item.quantity;
      return _s;
    }
    return Container(
      width: size.width,
      decoration: AppDecoration.glassCard,
      child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2026-08-10: "Позитивные и негативные эмоции" moved to the
              // top — it's the quick-read summary, the emotion cloud below
              // is the detailed breakdown.
              Padding(padding: getPadding(top: 21, left: 20, right: 20),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'positive_and_negative_emotions'.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800,
                    ),
                  ),
                  Padding(
                    padding: getPadding(
                      top: 2,
                      bottom: 2,
                    ),
                    child: TextForSelectPeriodWidget(start: controller.dateStart, end: controller.dateEnd, controller: controller,)
                  ),
                ],
              ),),
              Center(
                child: Padding(
                  padding: getPadding(top: 20),
                  child: Container(
                    width: getSize(300),
                    height: getSize(300),
                    child: Visibility(
                      visible: emotionsTypes.isNotEmpty,
                      child: EmotionPieChart(data: emotionsTypes, radius: getSize(145)),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: getPadding(all: 16),
                child: Wrap(children: emotionsTypes.map((e) => Padding(
                  padding: getPadding(right: 16,bottom: 18),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        color: e.color,
                        width: getSize(14),
                        height: getSize(14),
                      ),
                      Padding(padding: getPadding(left: 6),
                        child: Text('${e.name.tr()} ${((e.quantity  / _sum(emotionsTypes)) * 100).toInt()}%',
                          overflow:
                          TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle
                              .txtSFProDisplayLight10Gray800.copyWith(fontSize: getFontSize(16)),),
                      ),
                    ],
                  ),
                )).toList(),),
              ),
          Padding(
          padding: getPadding(
          left: 20,
            top: 30,
            right: 20
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'what_emotions_am_I_feeling'.tr(),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle
                    .txtSFProDisplayLight14Gray800,
              ),
              Text(
                "${start.day.timeFormatted()}.${start.month.timeFormatted()}.${start.year}-${end.day.timeFormatted()}.${end.month.timeFormatted()}.${end.year}",
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight10
                    .copyWith(color: ColorConstant.cyan700),
              ),
            ],
          ),
          ),
              // "Эмоциональное облако" (2026-08-10): a physics-driven bubble
              // cloud replaces the flat pie — positive emotions drift up,
              // negative drift down, bubble area tracks frequency. Includes
              // its own regrouped/sorted legend, so no separate Wrap here.
              Visibility(
                visible: emotions.isNotEmpty,
                child: Padding(
                  padding: getPadding(top: 10),
                  child: EmotionBubbleChart(data: emotions),
                ),
              ),
              SizedBox(height: 60,)

            ],
          ),
      ),
    );
  }
}
