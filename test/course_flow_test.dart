import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/data/course_flow.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/data/course_progress_store.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/models/course.dart';

Course load(String id) => Course.fromJson(
    jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>, 'es');

void main() {
  test('next step follows the numbered path, skips finished ones, ends at the last', () {
    final c = load('eating_no_autopilot');
    final p = CourseProgress();
    expect(nextStepIndexAfter(c, p, 0), 1);
    p.step(c.steps[1].id)..audioDone = true..taskDone = true;
    expect(nextStepIndexAfter(c, p, 0), 2); // step 2 is finished, so it is skipped
    for (final s in c.steps) {
      p.step(s.id)..audioDone = true..taskDone = true;
    }
    expect(nextStepIndexAfter(c, p, 3), isNull); // everything is done
  });

  test('wraps to an earlier unfinished step, and support blocks have no next', () {
    final c = load('eating_no_autopilot');
    final p = CourseProgress();
    for (var i = 1; i < c.steps.length; i++) {
      p.step(c.steps[i].id)..audioDone = true..taskDone = true;
    }
    expect(nextStepIndexAfter(c, p, c.steps.length - 1), 0);

    final r = load('return_to_self');
    final support = r.steps.indexWhere((s) => s.number == null);
    expect(support, isNonNegative);
    expect(nextStepIndexAfter(r, CourseProgress(), support), isNull);
  });

  test('the daily pace blocks a NEW step but never one already started', () {
    final r = load('return_to_self'); // one new step a day
    final p = CourseProgress();
    final first = r.steps.firstWhere((s) => s.number == 1);
    final second = r.steps.firstWhere((s) => s.number == 2);
    expect(stepBlockedByPace(r, p, first), false);
    p.markOpened(first.id);
    expect(stepBlockedByPace(r, p, second), true); // pace used up for today
    expect(stepBlockedByPace(r, p, first), false); // already started: always open
  });

  test('urge tool is found by id, and the reminder is tomorrow 9:00', () {
    expect(urgeTool(load('eating_no_autopilot'))?.id, 'urge');
    expect(urgeTool(load('return_to_self'))?.id, 'contact');
    final t = tomorrowMorning(DateTime(2026, 11, 30, 22, 15));
    expect([t.year, t.month, t.day, t.hour, t.minute], [2026, 12, 1, 9, 0]);
  });

  test('depression course: a week opens the day AFTER the previous one is completed', () {
    final c = load('depression_support');
    expect(c.dailyGate, true);
    final w1 = c.steps.firstWhere((s) => s.id == 'w1');
    final w2 = c.steps.firstWhere((s) => s.id == 'w2');
    final w3 = c.steps.firstWhere((s) => s.id == 'w3');
    final p = CourseProgress();
    expect(stepBlock(c, p, w1), StepBlock.none);
    // Week 1 opened but not finished: week 2 stays closed, however many days pass.
    p.markOpened(w1.id);
    expect(stepBlock(c, p, w2), StepBlock.previousNotDone);
    // Finished today: week 2 opens tomorrow.
    p.step(w1.id)..audioDone = true..taskDone = true;
    p.stampCompletions();
    expect(stepBlock(c, p, w2), StepBlock.tomorrow);
    // Finished yesterday: week 2 is open.
    final y = DateTime.now().subtract(const Duration(days: 1));
    p.step(w1.id).completedOn = CourseProgress.dayKey(y);
    expect(stepBlock(c, p, w2), StepBlock.none);
    // Week 3 still needs week 2 first, and a started step is never blocked again.
    expect(stepBlock(c, p, w3), StepBlock.previousNotDone);
    p.markOpened(w2.id);
    expect(stepBlock(c, p, w2), StepBlock.none);
    // Support blocks are never gated.
    expect(stepBlock(c, p, c.steps.firstWhere((s) => s.id == 'plan')), StepBlock.none);
  });

  test('every step of the depression course has its own picture that exists', () {
    final c = load('depression_support');
    for (final s in c.steps) {
      expect(s.cover, isNotNull, reason: s.id);
      expect(File(s.cover!).existsSync(), true, reason: s.cover);
    }
  });

  test('week 1 is not complete until its required reading cards are marked', () {
    final c = load('depression_support');
    final w1 = c.steps.firstWhere((s) => s.id == 'w1');
    final need = w1.micro.where((m) => m.required).map((m) => m.id).toSet();
    expect(need, isNotEmpty);
    final p = CourseProgress()..applyRequired({w1.id: need});
    p.step(w1.id)..audioDone = true..taskDone = true;
    expect(p.step(w1.id).complete, false);
    p.step(w1.id).microDone.addAll(need);
    expect(p.step(w1.id).complete, true);
    // Steps without required cards are unchanged.
    expect(CourseProgress().step('x').requiredRead, true);
  });
}
