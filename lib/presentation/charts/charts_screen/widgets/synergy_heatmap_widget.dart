import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/models/day_event_model.dart';
import '../../../../core/services/dashboards/synergy_heatmap_service.dart';
import '../../../../widgets/dashboard_insight_card.dart';

/// "Тепловая карта синергии" — cross-tab of two context dimensions
/// (activity/place/person), cell color = average mood in that combination.
/// Toggling the pair or the tension mode recomputes and recolors instantly
/// — the whole dataset already lives in memory (local-first), so this is
/// just re-running `SynergyHeatmapService.compute` on setState, no new I/O.
class SynergyHeatmapWidget extends StatefulWidget {
  final List<DayEventModel> events;

  const SynergyHeatmapWidget({Key? key, required this.events}) : super(key: key);

  @override
  State<SynergyHeatmapWidget> createState() => _SynergyHeatmapWidgetState();
}

enum _Pair { activityPerson, activityPlace, placePerson }

class _SynergyHeatmapWidgetState extends State<SynergyHeatmapWidget> {
  _Pair _pair = _Pair.activityPerson;
  bool _showTension = false;

  // Plain fields instead of a record — the project's SDK constraint
  // (pubspec.yaml: '>=2.12.0 <3.0.0') predates Dart 3's record syntax.
  ContextDimension get _rowDim {
    switch (_pair) {
      case _Pair.activityPerson:
      case _Pair.activityPlace:
        return ContextDimension.what;
      case _Pair.placePerson:
        return ContextDimension.where;
    }
  }

  ContextDimension get _colDim {
    switch (_pair) {
      case _Pair.activityPerson:
        return ContextDimension.who;
      case _Pair.activityPlace:
        return ContextDimension.where;
      case _Pair.placePerson:
        return ContextDimension.who;
    }
  }

  Color _cellColor(HeatmapCell cell) {
    const stressColor = Color(0xFFF2A65A); // мягкий оранжевый/персиковый
    const comfortColor = Color(0xFF3FBF8F); // изумрудный/пастельно-зелёный
    final t = _showTension ? cell.bodyTensionRate : (cell.avgMood / 10).clamp(0.0, 1.0);
    // Tension is "more = worse" (stress-colored), mood is "more = better"
    // (comfort-colored) — same two colors, opposite direction of t.
    return Color.lerp(
      _showTension ? comfortColor : stressColor,
      _showTension ? stressColor : comfortColor,
      t,
    )!;
  }

  void _onCellTap(HeatmapCell cell) {
    final text = _showTension
        ? 'heatmap_cell_summary_tension'.tr(namedArgs: {
            'row': cell.rowLabel,
            'col': cell.colLabel,
            'percent': (cell.bodyTensionRate * 100).round().toString(),
          })
        : 'heatmap_cell_summary'.tr(namedArgs: {
            'row': cell.rowLabel,
            'col': cell.colLabel,
            'count': '${cell.count}',
            'score': cell.avgMood.toStringAsFixed(1),
          });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), duration: const Duration(seconds: 3)));
  }

  @override
  Widget build(BuildContext context) {
    final rowDim = _rowDim;
    final colDim = _colDim;
    final pinnedColLabel = colDim == ContextDimension.who ? 'myself'.tr() : null;
    final result = SynergyHeatmapService.compute(
      widget.events,
      rowDim: rowDim,
      colDim: colDim,
      pinnedColLabel: pinnedColLabel,
    );

    return Container(
      width: size.width,
      decoration: AppDecoration.glassCard,
      padding: getPadding(left: 20, top: 21, right: 20, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('synergy_heatmap'.tr(), overflow: TextOverflow.ellipsis, style: AppStyle.txtSFProDisplayLight14Gray800),
          SizedBox(height: getVerticalSize(6)),
          Text(
            'synergy_heatmap_intro'.tr(),
            style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
          ),
          SizedBox(height: getVerticalSize(12)),
          _buildPairChips(),
          SizedBox(height: getVerticalSize(8)),
          _buildTensionToggle(),
          SizedBox(height: getVerticalSize(16)),
          if (result.isEmpty)
            Padding(
              padding: getPadding(top: 24, bottom: 24),
              child: Text('heatmap_empty'.tr(), textAlign: TextAlign.center, style: AppStyle.txtSFProDisplayLight14),
            )
          else ...[
            _buildGrid(result),
            SizedBox(height: getVerticalSize(20)),
            _buildInsight(result),
          ],
        ],
      ),
    );
  }

  Widget _buildInsight(HeatmapResult result) {
    final insight = SynergyHeatmapService.pickMaxContrastRow(result);
    if (insight == null) {
      return Text('insight_heatmap_no_contrast'.tr(), style: AppStyle.txtSFProDisplayLight14);
    }
    final activity = insight.activity;
    final condBad = insight.worstCol;
    final condGood = insight.bestCol;
    final variant = (activity + condBad + condGood).hashCode.abs() % 2 + 1;
    return DashboardInsightCard(
      signature: 'heatmap_${activity}_${condBad}_$condGood',
      summaryText: 'insight_heatmap_summary_$variant'
          .tr(namedArgs: {'activity': activity, 'cond_bad': condBad, 'cond_good': condGood}),
      highlights: [activity, condBad, condGood],
      nudgeText: 'insight_heatmap_nudge_$variant'
          .tr(namedArgs: {'activity': activity, 'cond_bad': condBad, 'cond_good': condGood}),
      theoryTitle: 'insight_heatmap_theory_title'.tr(),
      theoryBody: 'insight_heatmap_theory_body'.tr(),
    );
  }

  Widget _buildPairChips() {
    final options = <_Pair, String>{
      _Pair.activityPerson: 'heatmap_pair_activity_person'.tr(),
      _Pair.activityPlace: 'heatmap_pair_activity_place'.tr(),
      _Pair.placePerson: 'heatmap_pair_place_person'.tr(),
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.entries
            .map((entry) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(entry.value, style: const TextStyle(fontSize: 12)),
                    selected: _pair == entry.key,
                    selectedColor: ColorConstant.cyan700.withOpacity(0.2),
                    onSelected: (_) => setState(() => _pair = entry.key),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTensionToggle() {
    return Row(
      children: [
        Text('heatmap_show_tension'.tr(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
        Switch(
          value: _showTension,
          activeColor: ColorConstant.cyan700,
          onChanged: (v) => setState(() => _showTension = v),
        ),
      ],
    );
  }

  Widget _buildGrid(HeatmapResult result) {
    const cellSize = 62.0;
    const headerColWidth = 84.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: headerColWidth),
              for (final col in result.colLabels)
                SizedBox(
                  width: cellSize,
                  child: Text(
                    col,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                ),
            ],
          ),
          for (final row in result.rowLabels)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: headerColWidth,
                    child: Text(
                      row,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ),
                  for (final col in result.colLabels) _buildCell(result.cell(row, col), cellSize),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(HeatmapCell? cell, double cellSize) {
    if (cell == null) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          width: cellSize - 4,
          height: cellSize - 4,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.03), borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: () => _onCellTap(cell),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: cellSize - 4,
          height: cellSize - 4,
          decoration: BoxDecoration(color: _cellColor(cell), borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
