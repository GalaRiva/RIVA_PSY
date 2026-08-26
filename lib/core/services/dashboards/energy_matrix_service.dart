import '../../models/day_event_model.dart';
import 'energy_weights.dart';

/// One bubble on the "Матрица Энергии" quadrant — a context tag (person,
/// place or activity, pooled from `whoDidItHappen`/`whatHappened`/
/// `whereHappened`, same pooling as InsightEngine's context-unlock category)
/// positioned by average valence (x) and average arousal (y), both on a
/// -5..+5 scale so the quadrant is symmetric.
class EnergyMatrixPoint {
  final String tagLabel;
  final double x;
  final double y;
  final int frequency;
  // Non-null only for a synthetic "Other" bubble that folds together every
  // tag past the top-N-per-quadrant cap — holds the individual tag names it
  // stands in for, since tagLabel itself is just "Другое" at that point.
  final List<String>? groupedTags;

  EnergyMatrixPoint({
    required this.tagLabel,
    required this.x,
    required this.y,
    required this.frequency,
    this.groupedTags,
  });

  bool get isGroup => groupedTags != null;
}

class EnergyMatrixInsight {
  final EnergyMatrixPoint vampire;
  final EnergyMatrixPoint donor;

  EnergyMatrixInsight({required this.vampire, required this.donor});
}

class EnergyMatrixService {
  /// Below this many entries a tag's average is too noisy to plot honestly
  /// — it's dropped rather than shown with false confidence.
  static const int minEntriesPerTag = 3;

  static List<EnergyMatrixPoint> compute(List<DayEventModel> events) {
    final Map<String, List<DayEventModel>> byTag = {};
    for (final e in events) {
      final emotions = e.whatEmotion;
      final polarity = e.emotionInDayEvent;
      if (emotions == null || emotions.isEmpty || polarity == null) continue;

      void addTag(dynamic tag) {
        if (tag == null) return;
        final label = tag.localizedName as String;
        if (label.isEmpty) return;
        (byTag[label] ??= []).add(e);
      }

      addTag(e.whoDidItHappen);
      addTag(e.whatHappened);
      addTag(e.whereHappened);
    }

    final points = <EnergyMatrixPoint>[];
    byTag.forEach((label, list) {
      if (list.length < minEntriesPerTag) return;

      double xSum = 0;
      double ySum = 0;
      for (final e in list) {
        // emotionIntensity is 0..10 — halved so both axes share the same
        // -5..+5 scale as the energy-weight table.
        final signedIntensity = e.emotionInDayEvent == EmotionInDayEvent.NEGATIVE
            ? -e.emotionIntensity
            : e.emotionInDayEvent == EmotionInDayEvent.POSITIVE
                ? e.emotionIntensity
                : 0;
        xSum += signedIntensity / 2;
        // Only the primary (K27) emotion drives arousal — emotions added
        // later on the K31 screen aren't counted here, per product decision.
        ySum += EnergyWeights.weightFor(e.whatEmotion!.first.identity);
      }

      points.add(EnergyMatrixPoint(
        tagLabel: label,
        x: (xSum / list.length).clamp(-5.0, 5.0),
        y: (ySum / list.length).clamp(-5.0, 5.0),
        frequency: list.length,
      ));
    });

    points.sort((a, b) => b.frequency.compareTo(a.frequency));
    return points;
  }

  /// Biggest bubble in the "Стресс" quadrant (x<0, y>=0) and biggest in the
  /// "Ресурс" quadrant (x>=0, y<0) — null when either zone has no bubbles,
  /// i.e. there isn't enough contrast yet to say anything.
  static EnergyMatrixInsight? pickTopVampireAndDonor(List<EnergyMatrixPoint> points) {
    final vampires = points.where((p) => p.x < 0 && p.y >= 0).toList()
      ..sort((a, b) => b.frequency.compareTo(a.frequency));
    final donors = points.where((p) => p.x >= 0 && p.y < 0).toList()
      ..sort((a, b) => b.frequency.compareTo(a.frequency));
    if (vampires.isEmpty || donors.isEmpty) return null;
    return EnergyMatrixInsight(vampire: vampires.first, donor: donors.first);
  }
}
