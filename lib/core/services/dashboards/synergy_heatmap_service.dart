import '../../models/day_event_model.dart';
import '../../models/event_model.dart';

/// Which of the three single-value context fields on `DayEventModel` a
/// heatmap axis reads from.
enum ContextDimension { who, what, where }

extension ContextDimensionField on ContextDimension {
  EventModel? fieldOf(DayEventModel e) {
    switch (this) {
      case ContextDimension.who:
        return e.whoDidItHappen;
      case ContextDimension.what:
        return e.whatHappened;
      case ContextDimension.where:
        return e.whereHappened;
    }
  }
}

class HeatmapCell {
  final String rowLabel;
  final String colLabel;
  final double avgMood; // 0..10, DayEventModel.howDoYouFeel average
  final double bodyTensionRate; // 0..1, share of entries with any whatBodyParts tag
  final int count;

  HeatmapCell({
    required this.rowLabel,
    required this.colLabel,
    required this.avgMood,
    required this.bodyTensionRate,
    required this.count,
  });
}

class HeatmapResult {
  final List<String> rowLabels;
  final List<String> colLabels;
  final Map<String, HeatmapCell> _cellsByKey;

  HeatmapResult({required this.rowLabels, required this.colLabels, required Map<String, HeatmapCell> cellsByKey})
      : _cellsByKey = cellsByKey;

  HeatmapCell? cell(String row, String col) => _cellsByKey['$row||$col'];

  bool get isEmpty => _cellsByKey.isEmpty;
}

class HeatmapInsight {
  final String activity;
  final String worstCol;
  final String bestCol;

  HeatmapInsight({required this.activity, required this.worstCol, required this.bestCol});
}

class SynergyHeatmapService {
  /// Below this many entries a cell's average is too noisy to color
  /// confidently — left blank instead.
  static const int minEntriesPerCell = 3;
  static const int maxRows = 5;
  static const int maxCols = 5;

  static HeatmapResult compute(
    List<DayEventModel> events, {
    required ContextDimension rowDim,
    required ContextDimension colDim,
    String? pinnedColLabel,
  }) {
    final Map<String, Map<String, List<DayEventModel>>> grouped = {};
    final Map<String, int> rowFreq = {};
    final Map<String, int> colFreq = {};

    for (final e in events) {
      final rowTag = rowDim.fieldOf(e);
      final colTag = colDim.fieldOf(e);
      if (rowTag == null || colTag == null || e.howDoYouFeel == null) continue;
      final row = rowTag.localizedName;
      final col = colTag.localizedName;
      if (row.isEmpty || col.isEmpty) continue;

      final byCol = grouped[row] ??= {};
      (byCol[col] ??= []).add(e);
      rowFreq[row] = (rowFreq[row] ?? 0) + 1;
      colFreq[col] = (colFreq[col] ?? 0) + 1;
    }

    final topRows = (rowFreq.keys.toList()..sort((a, b) => rowFreq[b]!.compareTo(rowFreq[a]!)))
        .take(maxRows)
        .toList();

    final rankedCols = colFreq.keys.toList()..sort((a, b) => colFreq[b]!.compareTo(colFreq[a]!));
    final finalCols = <String>[];
    if (pinnedColLabel != null && colFreq.containsKey(pinnedColLabel)) {
      finalCols.add(pinnedColLabel);
      rankedCols.remove(pinnedColLabel);
    }
    finalCols.addAll(rankedCols.take(maxCols - finalCols.length));

    final cellsByKey = <String, HeatmapCell>{};
    for (final row in topRows) {
      for (final col in finalCols) {
        final list = grouped[row]?[col];
        if (list == null || list.length < minEntriesPerCell) continue;
        final avgMood = list.map((e) => e.howDoYouFeel!).reduce((a, b) => a + b) / list.length;
        final tensionCount = list.where((e) => (e.whatBodyParts ?? []).isNotEmpty).length;
        cellsByKey['$row||$col'] = HeatmapCell(
          rowLabel: row,
          colLabel: col,
          avgMood: avgMood.toDouble(),
          bodyTensionRate: tensionCount / list.length,
          count: list.length,
        );
      }
    }

    return HeatmapResult(rowLabels: topRows, colLabels: finalCols, cellsByKey: cellsByKey);
  }

  /// Row with the widest gap between its best and worst populated cell —
  /// null if no row clears a minimum, meaningful spread (avoids reading a
  /// 7.0-vs-7.2 wobble as a real "context matters" finding).
  static const double minMeaningfulSpread = 1.5;

  static HeatmapInsight? pickMaxContrastRow(HeatmapResult result) {
    HeatmapInsight? best;
    var bestSpread = -1.0;
    for (final row in result.rowLabels) {
      HeatmapCell? worst;
      HeatmapCell? top;
      for (final col in result.colLabels) {
        final c = result.cell(row, col);
        if (c == null) continue;
        if (worst == null || c.avgMood < worst.avgMood) worst = c;
        if (top == null || c.avgMood > top.avgMood) top = c;
      }
      if (worst == null || top == null || worst.colLabel == top.colLabel) continue;
      final spread = top.avgMood - worst.avgMood;
      if (spread > bestSpread) {
        bestSpread = spread;
        best = HeatmapInsight(activity: row, worstCol: worst.colLabel, bestCol: top.colLabel);
      }
    }
    if (best == null || bestSpread < minMeaningfulSpread) return null;
    return best;
  }
}
