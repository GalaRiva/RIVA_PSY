import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../presentation/charts/charts_screen/models/emotion_model.dart';

/// Shared fl_chart PieChart for the emotion breakdown charts (spec block 3)
/// — replaces syncfusion's SfCircularChart/PieSeries. No section titles:
/// both call sites already render their own colored-square + percentage
/// legend right below the chart, so labels on the slices themselves would
/// just duplicate that.
class EmotionPieChart extends StatelessWidget {
  final List<EmotionModel> data;
  final double? radius;

  const EmotionPieChart({Key? key, required this.data, this.radius}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sections: [
          for (final e in data)
            PieChartSectionData(
              value: e.quantity.toDouble(),
              // A radial gradient (lighter near the center, full color at
              // the outer edge) reads as a lit, dimensional slice instead
              // of a flat color fill — gradient overrides color in fl_chart.
              gradient: RadialGradient(
                colors: [
                  Color.lerp(e.color, Colors.white, 0.4)!,
                  e.color,
                ],
              ),
              showTitle: false,
              // fl_chart defaults radius to a fixed 40px regardless of the
              // surrounding box, so the pie never grows unless set here.
              radius: radius,
            ),
        ],
        sectionsSpace: 1,
        centerSpaceRadius: 0,
      ),
    );
  }
}
