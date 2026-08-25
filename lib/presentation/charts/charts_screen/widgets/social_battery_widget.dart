import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/models/day_event_model.dart';
import '../../../../core/services/dashboards/social_battery_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/dashboard_insight_card.dart';

/// "Трекер социальной батарейки" — a capsule gauge for the current charge
/// level, plus a mood line chart with an alone/social split background and
/// a break-point marker where a social session historically tends to start
/// pulling mood down.
class SocialBatteryWidget extends StatelessWidget {
  final List<DayEventModel> events;

  const SocialBatteryWidget({Key? key, required this.events}) : super(key: key);

  static const _aloneColor = AppColors.chartTeal;
  static const _socialColor = AppColors.chartGold;

  @override
  Widget build(BuildContext context) {
    final result = SocialBatteryService.compute(events);

    return Container(
      width: size.width,
      decoration: AppDecoration.glassCard,
      padding: getPadding(left: 20, top: 21, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('social_battery'.tr(), overflow: TextOverflow.ellipsis, style: AppStyle.txtSFProDisplayLight14Gray800),
          SizedBox(height: getVerticalSize(6)),
          Text(
            'social_battery_intro'.tr(),
            style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
          ),
          SizedBox(height: getVerticalSize(16)),
          if (result.isEmpty)
            Padding(
              padding: getPadding(top: 24, bottom: 24),
              child: Text('social_battery_empty'.tr(), textAlign: TextAlign.center, style: AppStyle.txtSFProDisplayLight14),
            )
          else ...[
            _buildGauge(result.currentLevel),
            SizedBox(height: getVerticalSize(20)),
            _buildLegend(),
            SizedBox(height: getVerticalSize(8)),
            SizedBox(height: getVerticalSize(140), child: _buildChart(result)),
            SizedBox(height: getVerticalSize(20)),
            _buildInsight(result),
          ],
        ],
      ),
    );
  }

  Widget _buildGauge(double level) {
    final t = (level / 100).clamp(0.0, 1.0);
    final color = Color.lerp(_socialColor, _aloneColor, t)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.22), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [color.withOpacity(0.95), color.withOpacity(0.7)]),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.45), blurRadius: 14, spreadRadius: 1),
              ],
            ),
            child: Center(
              child: Text(
                '${level.round()}%',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: getHorizontalSize(14)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                children: [
                  Container(height: 14, color: AppColors.primary.withOpacity(0.08)),
                  FractionallySizedBox(
                    widthFactor: t,
                    child: Container(
                      height: 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [color.withOpacity(0.85), color]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    Widget chip(Color c, String label) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: c.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: c.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: c)),
            ],
          ),
        );
    return Row(
      children: [
        chip(_aloneColor, 'myself'.tr()),
        const SizedBox(width: 8),
        chip(_socialColor, 'social_battery_legend_social'.tr()),
      ],
    );
  }

  Widget _buildChart(SocialBatteryResult result) {
    final points = result.moodTimeline;

    // Contiguous alone/social runs, drawn as translucent vertical bands
    // behind the line (the "split background" from the spec).
    final bands = <VerticalRangeAnnotation>[];
    var runStart = 0;
    for (var i = 1; i <= points.length; i++) {
      final runEnded = i == points.length || points[i].isAlone != points[runStart].isAlone;
      if (runEnded) {
        bands.add(VerticalRangeAnnotation(
          x1: runStart - 0.5,
          x2: (i - 1) + 0.5,
          color: (points[runStart].isAlone ? _aloneColor : _socialColor).withOpacity(0.08),
        ));
        runStart = i;
      }
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        minY: 0,
        maxY: 10,
        rangeAnnotations: RangeAnnotations(verticalRangeAnnotations: bands),
        lineBarsData: [
          LineChartBarData(
            spots: [for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].mood.toDouble())],
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                if (index < points.length && points[index].isBreakPoint) {
                  return FlDotCirclePainter(radius: 5, color: AppColors.chartRose, strokeWidth: 1.5, strokeColor: Colors.white);
                }
                return FlDotCirclePainter(radius: 0, color: Colors.transparent);
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.0)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsight(SocialBatteryResult result) {
    final x = result.breakPointHours;
    final y = result.recoveryHours;
    if (x == null || y == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🌙', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'social_battery_no_limit_yet'.tr(),
                style: AppStyle.txtSFProDisplayLight14.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
      );
    }
    final xStr = x.toStringAsFixed(1);
    final yStr = y.toStringAsFixed(1);
    return DashboardInsightCard(
      signature: 'battery_limit',
      summaryText: 'insight_battery_summary'.tr(namedArgs: {'x': xStr, 'y': yStr}),
      highlights: const [],
      nudgeText: 'social_battery_nudge'.tr(namedArgs: {'hours': xStr}),
      theoryTitle: 'insight_battery_theory_title'.tr(),
      theoryBody: 'insight_battery_theory_body'.tr(),
    );
  }
}
