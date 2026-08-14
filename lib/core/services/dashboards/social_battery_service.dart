import '../../models/day_event_model.dart';

class MoodPoint {
  final DateTime date;
  final int mood; // raw howDoYouFeel, 0..10
  final bool isAlone;
  final bool isBreakPoint;

  MoodPoint({required this.date, required this.mood, required this.isAlone, required this.isBreakPoint});
}

class SocialBatteryResult {
  final double currentLevel; // 0..100
  final List<MoodPoint> moodTimeline;
  final double? breakPointHours; // T_limit — null when there isn't enough data to estimate it
  final double? recoveryHours; // average duration of an "alone" run that follows a battery dip below 40%

  SocialBatteryResult({
    required this.currentLevel,
    required this.moodTimeline,
    required this.breakPointHours,
    required this.recoveryHours,
  });

  bool get isEmpty => moodTimeline.isEmpty;
}

/// Battery charge/discharge model and break-point (social-limit) estimator,
/// per the product spec: entries tagged "myself" (solitude — reuses the
/// existing "Я"/"myself" who-tag rather than a separate "Alone" tag)
/// recharge the battery, entries with company drain it, both scaled by how
/// pleasant/unpleasant the entry felt. Since diary entries are discrete
/// point-in-time check-ins (no start/end duration data exists), Δt is
/// approximated as the wall-clock gap between consecutive qualifying
/// entries, capped at 8h to keep sleep gaps from being read as one giant
/// drain/charge event.
class SocialBatteryService {
  static const double _cBase = 15; // %/hour, charge rate while alone
  static const double _dBase = 10; // %/hour, discharge rate while social
  static const double _maxGapHours = 8;
  static const String _aloneKey = 'myself';

  static SocialBatteryResult compute(List<DayEventModel> events) {
    final entries = events
        .where((e) => e.whoDidItHappen != null && e.howDoYouFeel != null && e.date != null)
        .toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));

    if (entries.isEmpty) {
      return SocialBatteryResult(currentLevel: 50, moodTimeline: [], breakPointHours: null, recoveryHours: null);
    }

    bool isAlone(DayEventModel e) => e.whoDidItHappen!.identity == _aloneKey;

    double battery = 50;
    final moodTimeline = <MoodPoint>[];
    DateTime? prevDate;

    // Session bookkeeping for the break-point estimate: a "social session"
    // is a run of consecutive non-alone entries; it ends on an alone entry
    // or the end of the list. Within a session we track cumulative social
    // hours vs. a smoothed signed-mood series and look for the first place
    // it dips negative — that's one sample of the user's social limit.
    final List<double> sessionHours = [];
    final List<double> sessionMood = [];
    final List<double> crossingSamples = [];

    void closeSession() {
      if (sessionHours.length < 2) {
        sessionHours.clear();
        sessionMood.clear();
        return;
      }
      for (var i = 1; i < sessionMood.length; i++) {
        final smoothed = (sessionMood[i] + sessionMood[i - 1]) / 2;
        final prevSmoothed = i >= 2 ? (sessionMood[i - 1] + sessionMood[i - 2]) / 2 : sessionMood[0];
        if (prevSmoothed >= 0 && smoothed < 0) {
          crossingSamples.add(sessionHours[i]);
          break;
        }
      }
      sessionHours.clear();
      sessionMood.clear();
    }

    final breakPointDates = <DateTime>{};

    // Recovery-time bookkeeping: an "alone" run that starts while the
    // battery is already low (<40%) is a real recovery attempt — its total
    // duration is one sample of how long the user actually needs to
    // recharge from a depleted state.
    const lowBatteryThreshold = 40.0;
    final recoverySamples = <double>[];
    bool inLowAloneRun = false;
    double currentAloneRunHours = 0;

    for (final e in entries) {
      final date = e.date!;
      final alone = isAlone(e);
      final mood = e.howDoYouFeel!.clamp(0, 10).toInt();
      final signedMood = ((mood - 5) * 2).toDouble(); // 0..10 -> -10..+10

      final rawGapHours = prevDate == null ? 0.0 : date.difference(prevDate).inMinutes / 60.0;
      final gapHours = rawGapHours.clamp(0.0, _maxGapHours);

      double mEmo;
      if (alone) {
        if (!inLowAloneRun) {
          // Start of a new alone run — decide once, from the battery level
          // right before this run's charge is applied, whether it counts
          // as a "recovery from low" run.
          inLowAloneRun = battery < lowBatteryThreshold;
          currentAloneRunHours = 0;
        }
        if (inLowAloneRun) currentAloneRunHours += gapHours;

        mEmo = signedMood > 2
            ? 1.5
            : signedMood < -2
                ? 0.2
                : 1.0;
        battery = (battery + _cBase * gapHours * mEmo).clamp(0.0, 100.0);
        closeSession();
      } else {
        if (inLowAloneRun && currentAloneRunHours > 0) {
          recoverySamples.add(currentAloneRunHours);
        }
        inLowAloneRun = false;
        currentAloneRunHours = 0;

        mEmo = signedMood > 2
            ? 0.5
            : signedMood < -2
                ? 2.0
                : 1.0;
        battery = (battery - _dBase * gapHours * mEmo).clamp(0.0, 100.0);
        if (sessionHours.isEmpty) {
          sessionHours.add(0);
        } else {
          sessionHours.add(sessionHours.last + gapHours);
        }
        sessionMood.add(signedMood);
      }

      moodTimeline.add(MoodPoint(date: date, mood: mood, isAlone: alone, isBreakPoint: false));
      prevDate = date;
    }
    closeSession();
    if (inLowAloneRun && currentAloneRunHours > 0) {
      recoverySamples.add(currentAloneRunHours);
    }

    double? breakPointHours;
    if (crossingSamples.isNotEmpty) {
      crossingSamples.sort();
      final mid = crossingSamples.length ~/ 2;
      breakPointHours = crossingSamples.length.isOdd
          ? crossingSamples[mid]
          : (crossingSamples[mid - 1] + crossingSamples[mid]) / 2;
    }

    // Second pass to flag the entry where each social session first
    // exceeded the estimated limit, now that the limit is known.
    final flaggedTimeline = <MoodPoint>[];
    double cumHours = 0;
    DateTime? sessionPrev;
    for (final p in moodTimeline) {
      bool flagged = false;
      if (p.isAlone) {
        cumHours = 0;
        sessionPrev = null;
      } else {
        final gap = sessionPrev == null ? 0.0 : p.date.difference(sessionPrev).inMinutes / 60.0;
        cumHours += gap.clamp(0.0, _maxGapHours);
        sessionPrev = p.date;
        if (breakPointHours != null && cumHours >= breakPointHours && !breakPointDates.contains(p.date)) {
          flagged = true;
          breakPointDates.add(p.date);
        }
      }
      flaggedTimeline.add(MoodPoint(date: p.date, mood: p.mood, isAlone: p.isAlone, isBreakPoint: flagged));
    }

    final recoveryHours =
        recoverySamples.isEmpty ? null : recoverySamples.reduce((a, b) => a + b) / recoverySamples.length;

    return SocialBatteryResult(
      currentLevel: battery,
      moodTimeline: flaggedTimeline,
      breakPointHours: breakPointHours,
      recoveryHours: recoveryHours,
    );
  }
}
