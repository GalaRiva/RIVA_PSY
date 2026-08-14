import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_style.dart';

class MonthlyStatsView extends StatelessWidget {
  final double? adherence;

  const MonthlyStatsView({Key? key, required this.adherence}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasData = adherence != null;
    final value = adherence ?? 0;
    final percent = (value * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: getVerticalSize(180),
          width: getVerticalSize(180),
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: getHorizontalSize(60),
                  sections: [
                    PieChartSectionData(
                      value: hasData ? value * 100 : 0.001,
                      color: ColorConstant.cyan700,
                      showTitle: false,
                      radius: getHorizontalSize(24),
                    ),
                    PieChartSectionData(
                      value: hasData ? (100 - value * 100) : 100,
                      color: ColorConstant.grayLight,
                      showTitle: false,
                      radius: getHorizontalSize(24),
                    ),
                  ],
                ),
              ),
              Text(
                hasData ? '$percent%' : '—',
                style: AppStyle.txtH1,
              ),
            ],
          ),
        ),
        SizedBox(height: getVerticalSize(10)),
        Text(
          hasData ? 'adherence_percent_caption'.tr() : 'no_doses_today'.tr(),
          textAlign: TextAlign.center,
          style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800),
        ),
        SizedBox(height: getVerticalSize(20)),
      ],
    );
  }
}
