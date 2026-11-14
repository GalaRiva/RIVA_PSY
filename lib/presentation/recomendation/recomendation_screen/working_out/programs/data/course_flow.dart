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

/// True when [step] is a NEW step that today's pace does not allow yet.
bool stepBlockedByPace(Course c, CourseProgress p, CourseStep step) =>
    !p.canOpen(step.id, alwaysAvailable: step.alwaysAvailable, maxPerDay: c.maxNewPerDay);

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
