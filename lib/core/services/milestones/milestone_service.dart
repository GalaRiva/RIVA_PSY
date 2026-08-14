import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/day_event_model.dart';
import '../../../presentation/main/path/path_final_screen/repository.dart';
import '../../../widgets/custom_message_box.dart';

/// Tracks the "Moment Collector" gamification milestone — total positive
/// diary entries crossing a round threshold. Deliberately a single overall
/// counter rather than one per specific emotion: simpler to reason about,
/// and the gallery already shows the per-emotion breakdown visually.
class MilestoneService {
  static const List<int> thresholds = [10, 25, 50, 100, 250, 500, 1000];
  static const String _prefsKey = 'milestone_last_announced';

  static Future<int> positiveMomentsCount() async {
    final events = await K39Repo().getEvent();
    return events.where((e) => e.emotionInDayEvent == EmotionInDayEvent.POSITIVE).length;
  }

  /// Returns the newly-crossed threshold (to show a celebration for), or
  /// null if the current count hasn't passed a new one since last checked.
  static Future<int?> checkAndRecordMilestone() async {
    final count = await positiveMomentsCount();
    final prefs = await SharedPreferences.getInstance();
    final lastAnnounced = prefs.getInt(_prefsKey) ?? 0;
    int? crossed;
    for (final t in thresholds) {
      if (count >= t && t > lastAnnounced) crossed = t;
    }
    if (crossed != null) {
      await prefs.setInt(_prefsKey, crossed);
    }
    return crossed;
  }

  /// Call after saving a diary entry — shows a small celebration dialog if
  /// the entry was positive and it just pushed the total past a new
  /// milestone. No-op (and no Hive/prefs writes) for negative/neutral saves.
  static Future<void> maybeCelebrate(BuildContext context, DayEventModel savedEvent) async {
    if (savedEvent.emotionInDayEvent != EmotionInDayEvent.POSITIVE) return;
    final crossed = await checkAndRecordMilestone();
    if (crossed == null || !context.mounted) return;
    showDialog(
      context: context,
      builder: (context) => CustomMessageBox(
        title: 'milestone_celebration_title'.tr(),
        content: 'milestone_celebration_body'.tr(namedArgs: {'count': '$crossed'}),
      ),
    );
  }
}
