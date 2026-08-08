import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_decoration.dart';
import '../../charts_screen/widgets/text_for_select_period_widget.dart';
import '../controller.dart';

class DiagnosticOfTheConditionWidget extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final VoidCallback? onPeriodTap;
  final List<int> dataForChart;
  final K61Controller controller;
  const DiagnosticOfTheConditionWidget(
      {Key? key, required this.start, required this.end, this.onPeriodTap, required this.dataForChart, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      decoration: AppDecoration.fillGray200,
      child: Column(
        children: [
          Padding(
            padding: getPadding(top: 18, left: 16),
            child: TextForSelectPeriodWidget(start: controller.dateStart, end: controller.dateEnd, controller: controller)
          ),
          Center(
            child: Container(
              margin: getMargin(top: 22),
              height: getVerticalSize(120),
              width: size.width - 32,
              // Premium redesign (spec block 3): was a hard background grid
              // image plus manually-drawn black axis/divider lines behind a
              // sparkline with a marker dot on every single point — the
              // "слишком технический" look the spec calls out. fl_chart's
              // LineChart gives curved (isCurved) lines, no visible axes,
              // and a translucent gradient fill under the line natively.
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < dataForChart.length; i++)
                          FlSpot(i.toDouble(), dataForChart[i].toDouble()),
                      ],
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.primary.withOpacity(0.3),
                            AppColors.primary.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
