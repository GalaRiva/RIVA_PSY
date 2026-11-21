import 'package:riva_psy/core/utils/audio_cover_map.dart';

import '../models/course.dart';
import 'course_progress_store.dart';

// Where the person goes after a step. Only the numbered path has an order; the
// support blocks ("Первая опора", "На трудные часы") are toolboxes with no
// "next". Pure functions, so they can be tested without any screen.

/// Index of the step to offer after [index]: the next unfinished step of the
/// same numbered block, wrapping to an earlier unfinished one; null when the
/// block is finished or the step is not part of the numbered path.
int? nextStepIndexAfter(Course c, CourseProgress p, int index) {
  if (index < 0 || index >= c.steps.length) return null;
  final here = c.steps[index];
  if (here.number == null) return null;
  bool open(int i) => c.steps[i].groupId == here.groupId && !p.step(c.steps[i].id).complete;
  for (var i = index + 1; i < c.steps.length; i++) {
    if (open(i)) return i;
  }
  for (var i = 0; i < index; i++) {
    if (open(i)) return i;
  }
  return null;
}

/// Why a NEW step cannot be opened right now.
enum StepBlock { none, pace, previousNotDone, tomorrow }

/// For courses with [Course.dailyGate] a numbered step opens on the day AFTER
/// the previous numbered step of its block was completed (audio + task).
/// Other courses keep the plain "N new steps a day" pace.
StepBlock stepBlock(Course c, CourseProgress p, CourseStep step) {
  if (step.alwaysAvailable || p.step(step.id).started) return StepBlock.none;
  if (c.dailyGate) {
    if (step.number == null) return StepBlock.none;
    if (step.number! <= 1) return StepBlock.none;
    CourseStep? prev;
    for (final s in c.steps) {
      if (s.groupId == step.groupId && s.number == step.number! - 1) prev = s;
    }
    if (prev == null) return StepBlock.none;
    final ps = p.step(prev.id);
    if (!ps.complete) return StepBlock.previousNotDone;
    // Steps finished before the date was recorded count as "an earlier day".
    final done = DateTime.tryParse(ps.completedOn ?? '');
    if (done == null) return StepBlock.none;
    final n = DateTime.now();
    final days = DateTime(n.year, n.month, n.day).difference(DateTime(done.year, done.month, done.day)).inDays;
    return days >= c.gateDays ? StepBlock.none : StepBlock.tomorrow;
  }
  return p.canOpen(step.id, alwaysAvailable: step.alwaysAvailable, maxPerDay: c.maxNewPerDay)
      ? StepBlock.none
      : StepBlock.pace;
}

/// True when [step] is a NEW step that is not allowed yet.
bool stepBlockedByPace(Course c, CourseProgress p, CourseStep step) => stepBlock(c, p, step) != StepBlock.none;

/// The picture of a step: its own `cover`, else the audio cover.
String? stepCoverAsset(CourseStep step) =>
    step.cover ?? wideStepCover(audioCoverAsset(step.coverKey));

/// The urge/contact tool: the one a person may need in the worst moment.
CourseTool? urgeTool(Course c) {
  for (final t in c.tools) {
    if (t.id == 'urge' || t.id == 'contact') return t;
  }
  return c.tools.isEmpty ? null : c.tools.first;
}

/// Tomorrow morning at 9:00, local time (the one-off "next step" reminder).
DateTime tomorrowMorning([DateTime? now]) {
  final n = now ?? DateTime.now();
  return DateTime(n.year, n.month, n.day + 1, 9);
}
