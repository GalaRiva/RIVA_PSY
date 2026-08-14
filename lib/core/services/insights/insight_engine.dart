import 'dart:math';

import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/models/insight_model.dart';
import 'package:riva_psy/presentation/main/path/path_final_screen/repository.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/pill_model.dart';
import 'package:riva_psy/presentation/settings/settings_pills/repository.dart';

import 'insights_repo.dart';
import 'offline_translations.dart';

typedef _Emit = Future<void> Function(String category, String templateBaseKey, Map<String, String> namedArgs,
    {int cooldownDays});
typedef _EmitFixed = Future<void> Function(String category, String exactTemplateKey, Map<String, String> namedArgs);

/// How many phrasing variants exist per category (insight_<category>_template_1..N
/// in the translation files) — picking a random one each time keeps repeat
/// insights from reading identically month after month. Categories not
/// listed here (or the fixed-template ones like body_awareness) don't use
/// variant pools.
const Map<String, int> _templateVariantCounts = {
  'insight_regularity_template': 20,
  'insight_anxiety_reduction_template': 20,
  'insight_missed_dose_template': 10,
  'insight_emotion_template': 10,
  'insight_monthly_template': 10,
  'insight_invitation_template': 24,
  'insight_unlock_template': 10,
};
final _random = Random();

String _pickTemplateKey(String baseKey) {
  final count = _templateVariantCounts[baseKey] ?? 10;
  return '${baseKey}_${_random.nextInt(count) + 1}';
}

/// Specific emotions worth watching for a frequency shift once a course has
/// been running a couple of weeks — true means "look for this becoming more
/// frequent", false means "look for this becoming rarer". Keys are the
/// stable EventModel identities actually seeded in the emotions taxonomy
/// (verified against what_emotion_screen/repository.dart) — not guesses.
const Map<String, bool> _trackedEmotions = {
  'joy': true,
  'tranquility': true,
  'inspiration': true,
  'trust': true,
  'enthusiasm': true,
  'interest': true,
  'apathy': false,
  'melancholy': false,
  'guilt': false,
  'irritation': false,
};

/// Body sensations worth watching for a decline once a course has been
/// running — each maps to its own dedicated (non-pooled) template, since
/// unlike the other categories these describe a specific physical symptom,
/// not interchangeable phrasings of the same idea. Keys verified against
/// what_body_parts_screen/repository.dart's whatHurtsKeys seed data.
const Map<String, String> _trackedBodySymptoms = {
  'heavy_shoulders': 'insight_body_heavy_shoulders_template',
  'lump_in_throat': 'insight_body_lump_in_throat_template',
  'shallow_breathing': 'insight_body_shallow_breathing_template',
  'weakness_in_legs': 'insight_body_weakness_in_legs_template',
  'rapid_heartbeat': 'insight_body_rapid_heartbeat_template',
  'tense_shoulders': 'insight_body_tense_shoulders_template',
};

/// Generic "body is tense" signals (not specific enough to name in a single
/// template) folded into the anxiety/distress check alongside the 'anxiety'
/// emotion tag.
const Set<String> _tensionSymptomKeys = {
  'tense_shoulders', 'tense_hands', 'tense2', 'tense3', 'tense4', 'tense', 'clenched', 'rigid', 'clenched_fists',
};

/// Correlates medication adherence with diary mood data and stores any
/// newly-found insights. Deliberately plain async on the main isolate rather
/// than `compute()`/`Isolate.spawn` — at this app's realistic data volumes
/// (a personal diary, not a multi-user dataset) the work here is a handful
/// of milliseconds, and correctly re-initializing Hive + path_provider inside
/// a background isolate is real added risk for no measurable benefit yet.
/// Revisit if this ever visibly janks on device.
class InsightEngine {
  final _pillsRepo = PillsRepo();
  final _eventsRepo = K39Repo();
  final _insightsRepo = InsightsRepo();

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  double? _moodScore(DayEventModel e) {
    if (e.emotionInDayEvent == null) return null;
    final intensity = e.emotionIntensity.toDouble();
    if (e.emotionInDayEvent == EmotionInDayEvent.POSITIVE) return intensity;
    if (e.emotionInDayEvent == EmotionInDayEvent.NEGATIVE) return -intensity;
    return 0;
  }

  bool _hasAnxiety(DayEventModel e) => (e.whatEmotion ?? []).any((em) => em.identity == 'anxiety');

  bool _hasBodyTension(DayEventModel e) {
    for (final part in (e.whatBodyParts ?? [])) {
      final keys = part.bodyPartsModel.whatHurtsKeys;
      if (keys != null && keys.any(_tensionSymptomKeys.contains)) return true;
    }
    return false;
  }

  bool _hasDistress(DayEventModel e) => _hasAnxiety(e) || _hasBodyTension(e);

  bool _hasBodySymptom(DayEventModel e, String symptomKey) {
    for (final part in (e.whatBodyParts ?? [])) {
      final keys = part.bodyPartsModel.whatHurtsKeys;
      if (keys != null && keys.contains(symptomKey)) return true;
    }
    return false;
  }

  bool _isScheduledOn(PillModel pill, DateTime date) {
    final d = _dateOnly(date);
    return !d.isBefore(_dateOnly(pill.startDate)) && !d.isAfter(_dateOnly(pill.endDate));
  }

  /// Runs the correlation checks and stores any newly generated insights.
  /// Returns exactly the insights created by this call (its "batch") — every
  /// one of them shares the same `generatedAt` instant, which is how the
  /// UI/notification code later groups them back together as one report.
  Future<List<InsightModel>> run() async {
    final pills = await _pillsRepo.getEvent();
    final events = await _eventsRepo.getEvent();
    // Only the pill-correlation checks below need medication data — the
    // invitation/context-unlock checks are diary-only and should still run
    // for someone with no pills configured at all.
    if (events.isEmpty) return [];

    final existing = await _insightsRepo.getAll();
    final runTimestamp = DateTime.now();
    final batch = <InsightModel>[];

    Future<void> emitFixed(String category, String exactTemplateKey, Map<String, String> namedArgs) async {
      final insight = InsightModel(
        id: '${runTimestamp.microsecondsSinceEpoch}_${batch.length}',
        generatedAt: runTimestamp,
        category: category,
        templateKey: exactTemplateKey,
        namedArgs: namedArgs,
      );
      await _insightsRepo.add(insight);
      batch.add(insight);
    }

    Future<void> emit(String category, String templateBaseKey, Map<String, String> namedArgs,
        {int cooldownDays = 0}) async {
      final onCooldown = existing.any((i) =>
          i.category == category && runTimestamp.difference(i.generatedAt).inDays <= cooldownDays);
      if (onCooldown) return;
      final excludedRecently = existing.any((i) =>
          i.category == category &&
          i.feedback == 'inaccurate' &&
          runTimestamp.difference(i.generatedAt).inDays < 30);
      if (excludedRecently) return;
      await emitFixed(category, _pickTemplateKey(templateBaseKey), namedArgs);
    }

    final translations = await OfflineTranslations.load();

    for (final pill in pills) {
      await _checkRegularity(pill, events, emit);
      await _checkAnxietyReduction(pill, events, emit);
      await _checkEmotionCorrelation(pill, events, translations, emit);
      await _checkMonthlyRetrospective(pill, events, emit);
      await _checkBodySymptoms(pill, events, emitFixed);
    }
    if (pills.isNotEmpty) {
      await _checkMissedDoseYesterday(pills, events, emit);
    }
    await _checkPositiveInvitation(events, emit);
    await _checkContextUnlock(events, translations, emit);
    return batch;
  }

  Future<void> _checkRegularity(PillModel pill, List<DayEventModel> events, _Emit emit) async {
    if (!pill.actual() || pill.hoursOfTakingPills.isEmpty) return;

    int streak = 0;
    DateTime cursor = _dateOnly(DateTime.now()).subtract(const Duration(days: 1));
    final courseStart = _dateOnly(pill.startDate);
    while (!cursor.isBefore(courseStart) && streak < 400) {
      final allTaken = pill.hoursOfTakingPills.every((t) {
        for (final a in pill.adoptions) {
          if (_sameDay(a.adoptionDate, cursor) && a.adoptionTimes.contains(t)) return true;
        }
        return false;
      });
      if (!allTaken) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    if (streak < 4) return;

    final now = _dateOnly(DateTime.now());
    final windowStart = now.subtract(Duration(days: streak));
    final windowScores = events
        .where((e) => e.date != null && !e.date!.isBefore(windowStart) && e.date!.isBefore(now))
        .map(_moodScore)
        .whereType<double>()
        .toList();
    final baselineStart = windowStart.subtract(const Duration(days: 30));
    final baselineScores = events
        .where((e) =>
            e.date != null && !e.date!.isBefore(baselineStart) && e.date!.isBefore(windowStart))
        .map(_moodScore)
        .whereType<double>()
        .toList();
    if (windowScores.length < 2 || baselineScores.length < 2) return;

    final windowAvg = windowScores.reduce((a, b) => a + b) / windowScores.length;
    final baselineAvg = baselineScores.reduce((a, b) => a + b) / baselineScores.length;
    final delta = windowAvg - baselineAvg;
    if (delta <= 0.3) return;

    await emit('regularity', 'insight_regularity_template',
        {'pill': pill.name, 'days': '$streak', 'delta': delta.toStringAsFixed(1)});
  }

  Future<void> _checkAnxietyReduction(PillModel pill, List<DayEventModel> events, _Emit emit) async {
    if (!pill.actual()) return;
    final daysSinceStart = DateTime.now().difference(pill.startDate).inDays;
    if (daysSinceStart < 14) return;

    final before = events.where((e) => e.date != null && e.date!.isBefore(pill.startDate)).toList();
    final after = events.where((e) => e.date != null && !e.date!.isBefore(pill.startDate)).toList();
    if (before.length < 5 || after.length < 5) return;

    final beforeRate = before.where(_hasDistress).length / before.length;
    final afterRate = after.where(_hasDistress).length / after.length;
    if (beforeRate <= 0 || afterRate >= beforeRate * 0.7) return;

    final percent = ((1 - afterRate / beforeRate) * 100).round();
    await emit('anxiety_reduction', 'insight_anxiety_reduction_template',
        {'pill': pill.name, 'percent': '$percent', 'days': '$daysSinceStart'});
  }

  Future<void> _checkEmotionCorrelation(
      PillModel pill, List<DayEventModel> events, Map<String, dynamic> translations, _Emit emit) async {
    if (!pill.actual()) return;
    final daysSinceStart = DateTime.now().difference(pill.startDate).inDays;
    if (daysSinceStart < 14) return;

    final before = events.where((e) => e.date != null && e.date!.isBefore(pill.startDate)).toList();
    final after = events.where((e) => e.date != null && !e.date!.isBefore(pill.startDate)).toList();
    if (before.length < 5 || after.length < 5) return;

    for (final entry in _trackedEmotions.entries) {
      final key = entry.key;
      final wantsIncrease = entry.value;
      bool hasTag(DayEventModel e) => (e.whatEmotion ?? []).any((em) => em.identity == key);
      final beforeRate = before.where(hasTag).length / before.length;
      final afterRate = after.where(hasTag).length / after.length;

      if (wantsIncrease) {
        if (afterRate < beforeRate + 0.15) continue;
      } else {
        if (beforeRate <= 0 || afterRate >= beforeRate * 0.7) continue;
      }

      final emotionLabel = OfflineTranslations.tr(translations, key);
      await emit('specific_emotion', 'insight_emotion_template',
          {'pill': pill.name, 'emotion': emotionLabel}, cooldownDays: 6);
      return;
    }
  }

  Future<void> _checkMonthlyRetrospective(PillModel pill, List<DayEventModel> events, _Emit emit) async {
    if (!pill.actual()) return;
    final daysSinceStart = DateTime.now().difference(pill.startDate).inDays;
    if (daysSinceStart < 30) return;

    final now = _dateOnly(DateTime.now());
    final last30Start = now.subtract(const Duration(days: 30));
    final prev30Start = last30Start.subtract(const Duration(days: 30));

    final last30Scores = events
        .where((e) => e.date != null && !e.date!.isBefore(last30Start) && e.date!.isBefore(now))
        .map(_moodScore)
        .whereType<double>()
        .toList();
    final prev30Scores = events
        .where((e) =>
            e.date != null && !e.date!.isBefore(prev30Start) && e.date!.isBefore(last30Start))
        .map(_moodScore)
        .whereType<double>()
        .toList();
    if (last30Scores.length < 5 || prev30Scores.length < 5) return;

    final last30Avg = last30Scores.reduce((a, b) => a + b) / last30Scores.length;
    final prev30Avg = prev30Scores.reduce((a, b) => a + b) / prev30Scores.length;
    final delta = last30Avg - prev30Avg;
    if (delta <= 0.3) return;

    int takenCount = 0;
    for (final a in pill.adoptions) {
      if (!a.adoptionDate.isBefore(last30Start) && a.adoptionDate.isBefore(now)) {
        takenCount += a.adoptionTimes.length;
      }
    }
    final percent = prev30Avg.abs() > 0.01 ? (delta / prev30Avg.abs() * 100).abs().round().clamp(1, 200) : 10;

    await emit('monthly_retrospective', 'insight_monthly_template', {
      'pill': pill.name,
      'count': '$takenCount',
      'delta': delta.toStringAsFixed(1),
      'percent': '$percent',
    }, cooldownDays: 25);
  }

  Future<void> _checkBodySymptoms(PillModel pill, List<DayEventModel> events, _EmitFixed emitFixed) async {
    if (!pill.actual()) return;
    final daysSinceStart = DateTime.now().difference(pill.startDate).inDays;
    if (daysSinceStart < 14) return;

    final before = events.where((e) => e.date != null && e.date!.isBefore(pill.startDate)).toList();
    final after = events.where((e) => e.date != null && !e.date!.isBefore(pill.startDate)).toList();
    if (before.length < 5 || after.length < 5) return;

    for (final entry in _trackedBodySymptoms.entries) {
      final symptomKey = entry.key;
      bool hasSymptom(DayEventModel e) => _hasBodySymptom(e, symptomKey);
      final beforeRate = before.where(hasSymptom).length / before.length;
      final afterRate = after.where(hasSymptom).length / after.length;
      if (beforeRate <= 0 || afterRate >= beforeRate * 0.7) continue;

      await emitFixed('body_awareness', entry.value, {'pill': pill.name});
      return;
    }
  }

  Future<void> _checkMissedDoseYesterday(
      List<PillModel> pills, List<DayEventModel> events, _Emit emit) async {
    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    for (final pill in pills) {
      if (!_isScheduledOn(pill, yesterday) || pill.hoursOfTakingPills.isEmpty) continue;

      final missedYesterday = pill.hoursOfTakingPills.any((t) {
        for (final a in pill.adoptions) {
          if (_sameDay(a.adoptionDate, yesterday) && a.adoptionTimes.contains(t)) return false;
        }
        return true;
      });
      if (!missedYesterday) continue;

      final todayEvents = events.where((e) => e.date != null && _sameDay(e.date!, today)).toList();
      if (todayEvents.isEmpty) continue;
      final todayScore = _moodScore(todayEvents.first);
      if (todayScore == null) continue;

      final recentScores = events
          .where((e) =>
              e.date != null &&
              e.date!.isBefore(today) &&
              !e.date!.isBefore(today.subtract(const Duration(days: 14))))
          .map(_moodScore)
          .whereType<double>()
          .toList();
      if (recentScores.length < 3) continue;

      final baselineAvg = recentScores.reduce((a, b) => a + b) / recentScores.length;
      if (todayScore >= baselineAvg - 1.5) continue;

      await emit('missed_dose', 'insight_missed_dose_template', {'pill': pill.name});
    }
  }

  /// Gently invites the user to log a positive moment when their diary
  /// skews heavily negative — doesn't need any medication data, just a
  /// diary with enough history to judge the balance.
  Future<void> _checkPositiveInvitation(List<DayEventModel> events, _Emit emit) async {
    if (events.length < 7) return;
    final positiveCount = events.where((e) => e.emotionInDayEvent == EmotionInDayEvent.POSITIVE).length;
    final positiveRate = positiveCount / events.length;
    if (positiveRate > 0.15) return;
    await emit('positive_invitation', 'insight_invitation_template', {}, cooldownDays: 7);
  }

  /// Single-factor "unlock" insight: does a specific person/activity/place
  /// (whoDidItHappen/whatHappened/whereHappened — each a single value per
  /// day, not a list, so this correlates by grouping days that share the
  /// same value rather than needing multi-tag-per-day support) line up with
  /// a noticeably higher rate of a specific positive emotion than the
  /// user's overall baseline for that emotion.
  Future<void> _checkContextUnlock(
      List<DayEventModel> events, Map<String, dynamic> translations, _Emit emit) async {
    if (events.length < 12) return;

    final Map<String, List<DayEventModel>> byContext = {};
    for (final e in events) {
      final who = e.whoDidItHappen;
      if (who != null && who.localizedName.isNotEmpty) {
        (byContext[who.localizedName] ??= []).add(e);
      }
      final what = e.whatHappened;
      if (what != null && what.localizedName.isNotEmpty) {
        (byContext[what.localizedName] ??= []).add(e);
      }
      final where = e.whereHappened;
      if (where != null && where.localizedName.isNotEmpty) {
        (byContext[where.localizedName] ??= []).add(e);
      }
    }
    if (byContext.isEmpty) return;

    for (final entry in _trackedEmotions.entries) {
      if (!entry.value) continue; // only look for a positive-emotion "unlock", not a decline
      final emotionKey = entry.key;
      bool hasTag(DayEventModel e) => (e.whatEmotion ?? []).any((em) => em.identity == emotionKey);
      final overallRate = events.where(hasTag).length / events.length;
      if (overallRate <= 0) continue;

      for (final contextEntry in byContext.entries) {
        final contextEvents = contextEntry.value;
        if (contextEvents.length < 4) continue;
        final contextRate = contextEvents.where(hasTag).length / contextEvents.length;
        if (contextRate < overallRate + 0.25) continue;

        final emotionLabel = OfflineTranslations.tr(translations, emotionKey);
        await emit('context_unlock', 'insight_unlock_template',
            {'context': contextEntry.key, 'emotion': emotionLabel}, cooldownDays: 10);
        return;
      }
    }
  }
}
