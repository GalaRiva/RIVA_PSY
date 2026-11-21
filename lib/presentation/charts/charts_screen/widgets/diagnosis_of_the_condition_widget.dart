import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../charts_screen/widgets/text_for_select_period_widget.dart';
import '../controller.dart';
import 'admission_schedule/widgets/insight_card.dart';

// The mood line changes colour with the value itself: violet where the state is
// harder (low), through a soft teal, to green where it is better (high). A
// glance tells good from bad without reading any axis.
const Color _moodLow = Color(0xFF6B58B5);
const Color _moodMid = Color(0xFF5F8F9A);
const Color _moodHigh = Color(0xFF3F9B6F);

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
      decoration: AppDecoration.glassCard,
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
                  // The state slider on the main screen runs 0..10. Without a
                  // fixed range the line was stretched to the entries' own
                  // min/max, so a move from 5 to 6 looked like a crash.
                  minY: 0,
                  maxY: 10,
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
                      // Gradient runs over the fixed 0..10 range of the chart, so the
                      // same height is always the same colour.
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [_moodLow, _moodMid, _moodHigh],
                        stops: [0.0, 0.5, 1.0],
                      ),
                      barWidth: 3.5,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _moodHigh.withOpacity(0.22),
                            _moodMid.withOpacity(0.10),
                            _moodLow.withOpacity(0.14),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // The key: what the colours mean, in two quiet words.
          Padding(
            padding: getPadding(top: 12, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(_moodLow),
                SizedBox(width: getHorizontalSize(6)),
                Text('chart_mood_low'.tr(), style: _legendStyle),
                SizedBox(width: getHorizontalSize(22)),
                _dot(_moodHigh),
                SizedBox(width: getHorizontalSize(6)),
                Text('chart_mood_high'.tr(), style: _legendStyle),
              ],
            ),
          ),
          Padding(
            padding: getPadding(top: 40, left: 16, right: 16, bottom: 20),
            child: const InsightSection(),
          ),
        ],
      ),
    );
  }

  static TextStyle get _legendStyle => TextStyle(
      fontFamily: 'Manrope', fontSize: getFontSize(13), color: const Color(0xFF4A545A), fontWeight: FontWeight.w400);

  static Widget _dot(Color c) =>
      Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}
