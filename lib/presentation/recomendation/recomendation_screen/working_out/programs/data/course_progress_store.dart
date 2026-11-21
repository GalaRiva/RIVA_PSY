import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riva_psy/core/db/hive_db.dart';

// Everything here stays on the device (Hive), same privacy principle as the
// diary: what a person writes in a course never goes to a server. It is part
// of the user's own Drive backup like the diary.

const int kMaxNewStepsPerDay = 2;

class CourseStepState {
  bool started;
  bool audioDone;
  bool taskDone;
  Set<String> microDone;
  // 'yyyy-mm-dd' of the day the step became complete (audio + task); null
  // for steps finished before this was recorded.
  String? completedOn;
  // Reading cards that must be marked before the step is complete. Not stored:
  // it comes from the course file (CourseProgressStore.load applies it).
  Set<String> required = {};

  CourseStepState(
      {this.started = false, this.audioDone = false, this.taskDone = false, Set<String>? microDone, this.completedOn})
      : microDone = microDone ?? {};

  bool get requiredRead => required.every(microDone.contains);

  bool get complete => audioDone && taskDone && requiredRead;

  Map<String, dynamic> toJson() => {
        'started': started,
        'audio': audioDone,
        'task': taskDone,
        'micro': microDone.toList(),
        if (completedOn != null) 'done_on': completedOn,
      };

  factory CourseStepState.fromJson(Map<String, dynamic> j) => CourseStepState(
        started: j['started'] == true,
        audioDone: j['audio'] == true,
        taskDone: j['task'] == true,
        microDone: ((j['micro'] as List?) ?? []).map((e) => e.toString()).toSet(),
        completedOn: j['done_on'] as String?,
      );
}

class CourseProgress {
  int round;
  bool screened;
  final Map<String, CourseStepState> steps;
  // 'yyyy-mm-dd' -> ids of steps first opened that day (this is what the
  // "at most 2 new steps a day" pace counts).
  final Map<String, List<String>> opened;
  // "Как ты сейчас?" after an audio: consecutive "worse" answers. Two in a
  // row -> the course suggests talking to a specialist. Never shown as a score.
  int worseStreak;

  CourseProgress(
      {this.round = 1,
      this.screened = false,
      this.worseStreak = 0,
      Map<String, CourseStepState>? steps,
      Map<String, List<String>>? opened})
      : steps = steps ?? {},
        opened = opened ?? {};

  static String dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // step id -> ids of the reading cards that must be read (from the course file).
  Map<String, Set<String>> requiredMicro = {};

  CourseStepState step(String id) =>
      steps.putIfAbsent(id, () => CourseStepState()..required = requiredMicro[id] ?? {});

  void applyRequired(Map<String, Set<String>> r) {
    requiredMicro = r;
    for (final e in steps.entries) {
      e.value.required = r[e.key] ?? {};
    }
  }

  /// Stamps today on every step that has just become complete, and clears the
  /// stamp when it is no longer complete (the person un-marked the audio).
  void stampCompletions() {
    final today = dayKey(DateTime.now());
    for (final s in steps.values) {
      if (s.complete) {
        s.completedOn ??= today;
      } else {
        s.completedOn = null;
      }
    }
  }

  int get openedTodayCount => (opened[dayKey(DateTime.now())] ?? const []).length;

  /// A step already started in this round can always be reopened; only
  /// *new* steps count against the daily pace.
  bool canOpen(String stepId, {bool alwaysAvailable = false, int maxPerDay = kMaxNewStepsPerDay}) {
    if (alwaysAvailable) return true;
    if (step(stepId).started) return true;
    return openedTodayCount < maxPerDay;
  }

  void markOpened(String stepId, {bool alwaysAvailable = false}) {
    final s = step(stepId);
    if (s.started) return;
    s.started = true;
    if (alwaysAvailable) return;
    (opened[dayKey(DateTime.now())] ??= []).add(stepId);
  }

  Map<String, dynamic> toJson() => {
        'round': round,
        'screened': screened,
        'worse': worseStreak,
        'steps': steps.map((k, v) => MapEntry(k, v.toJson())),
        'opened': opened,
      };

  factory CourseProgress.fromJson(Map<String, dynamic> j) => CourseProgress(
        round: (j['round'] as num?)?.toInt() ?? 1,
        screened: j['screened'] == true,
        worseStreak: (j['worse'] as num?)?.toInt() ?? 0,
        steps: ((j['steps'] as Map?) ?? {})
            .map((k, v) => MapEntry(k.toString(), CourseStepState.fromJson(Map<String, dynamic>.from(v)))),
        opened: ((j['opened'] as Map?) ?? {})
            .map((k, v) => MapEntry(k.toString(), (v as List).map((e) => e.toString()).toList())),
      );
}

class CourseCard {
  final String id;
  final String cardType;
  final int round;
  final DateTime createdAt;
  final Map<String, String> values;

  CourseCard({required this.id, required this.cardType, required this.round, required this.createdAt, required this.values});

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': cardType,
        'round': round,
        'at': createdAt.toIso8601String(),
        'values': values,
      };

  factory CourseCard.fromJson(Map<String, dynamic> j) => CourseCard(
        id: j['id'] as String,
        cardType: j['type'] as String,
        round: (j['round'] as num?)?.toInt() ?? 1,
        createdAt: DateTime.tryParse(j['at'] as String? ?? '') ?? DateTime.now(),
        values: Map<String, String>.from((j['values'] as Map?) ?? {}),
      );
}

class CourseProgressStore {
  // Stored in Hive (not SharedPreferences) so it travels with the diary in
  // the Drive backup (HiveDBTags.allTagsForTransfer). One entry per course
  // in `courseProgress`; one entry per card in `courseCards`.
  static const _pTag = HiveDBTags.courseProgress;
  static const _cTag = HiveDBTags.courseCards;

  static Future<List<Map<String, dynamic>>> _entries(String tag) async {
    final raw = await HiveDB.getBox(tag);
    final out = <Map<String, dynamic>>[];
    for (final e in raw) {
      try {
        final d = e is String ? jsonDecode(e) : e;
        if (d is Map) out.add(Map<String, dynamic>.from(d));
      } catch (_) {}
    }
    return out;
  }

  static Future<void> _rewrite(String tag, List<Map<String, dynamic>> entries) async {
    await HiveDB.openBox(tag);
    await HiveDB.deleteBox(tag);
    for (final e in entries) {
      await HiveDB.setBox(e, tag);
    }
  }

  static final Map<String, Map<String, Set<String>>> _requiredCache = {};

  // The reading cards a course marks `required: true`, per step.
  static Future<Map<String, Set<String>>> _requiredFor(String courseId) async {
    final cached = _requiredCache[courseId];
    if (cached != null) return cached;
    final out = <String, Set<String>>{};
    try {
      final raw = jsonDecode(await rootBundle.loadString('assets/courses/$courseId.json')) as Map<String, dynamic>;
      for (final st in (raw['steps'] as List? ?? [])) {
        final ids = <String>{
          for (final m in (st['micro'] as List? ?? []))
            if (m['required'] == true) m['id'] as String
        };
        if (ids.isNotEmpty) out[st['id'] as String] = ids;
      }
    } catch (_) {}
    return _requiredCache[courseId] = out;
  }

  static Future<CourseProgress> load(String courseId) async {
    final all = await _entries(_pTag);
    CourseProgress? found;
    for (final e in all.reversed) {
      if (e['courseId'] == courseId) {
        try {
          found = CourseProgress.fromJson(Map<String, dynamic>.from(e['data'] as Map));
          break;
        } catch (_) {}
      }
    }
    final p = found ?? CourseProgress();
    p.applyRequired(await _requiredFor(courseId));
    return p;
  }

  static Future<void> save(String courseId, CourseProgress p) async {
    p.stampCompletions();
    final all = await _entries(_pTag);
    all.removeWhere((e) => e['courseId'] == courseId);
    all.add({'courseId': courseId, 'data': p.toJson()});
    await _rewrite(_pTag, all);
  }

  /// Starts the course over: step marks reset, personal cards are kept.
  static Future<CourseProgress> newRound(String courseId, CourseProgress p) async {
    final fresh = CourseProgress(round: p.round + 1, screened: p.screened, worseStreak: p.worseStreak, opened: p.opened)
      ..applyRequired(p.requiredMicro);
    await save(courseId, fresh);
    return fresh;
  }

  static Future<List<CourseCard>> cards(String courseId) async {
    final all = await _entries(_cTag);
    final list = <CourseCard>[];
    for (final e in all) {
      if (e['courseId'] != courseId) continue;
      try {
        list.add(CourseCard.fromJson(e));
      } catch (_) {}
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  static Future<void> addCard(String courseId, CourseCard card) async {
    await HiveDB.setBox({'courseId': courseId, ...card.toJson()}, _cTag);
  }

  static Future<void> deleteCard(String courseId, String cardId) async {
    final all = await _entries(_cTag);
    all.removeWhere((e) => e['courseId'] == courseId && e['id'] == cardId);
    await _rewrite(_cTag, all);
  }

  static Future<CourseCard?> latest(String courseId, String cardType) async {
    final cards = await CourseProgressStore.cards(courseId);
    for (final c in cards) {
      if (c.cardType == cardType) return c;
    }
    return null;
  }
}
