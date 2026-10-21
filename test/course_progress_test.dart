import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/models/course.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/data/course_progress_store.dart';

void main() {
  courseContentTests();
  returnToSelfTests();
  test('at most 2 NEW steps a day; started steps and always-available steps are never blocked', () {
    final p = CourseProgress();
    expect(p.canOpen('s1'), isTrue);
    p.markOpened('s1');
    p.markOpened('s2');
    expect(p.openedTodayCount, 2);
    expect(p.canOpen('s3'), isFalse); // a third new step today is held back
    expect(p.canOpen('s1'), isTrue); // repeating a started step is always fine
    expect(p.canOpen('s6', alwaysAvailable: true), isTrue); // after-episode step never blocked
    p.markOpened('s6', alwaysAvailable: true);
    expect(p.openedTodayCount, 2); // not counted against the pace
  });

  test('a course can set its own pace (1 new step a day)', () {
    final p = CourseProgress();
    p.markOpened('a');
    expect(p.canOpen('b', maxPerDay: 1), isFalse);
    expect(p.canOpen('a', maxPerDay: 1), isTrue);
  });

  test('worse streak survives a round trip', () {
    final p = CourseProgress(worseStreak: 2);
    expect(CourseProgress.fromJson(p.toJson()).worseStreak, 2);
  });

  test('progress survives a JSON round trip', () {
    final p = CourseProgress(round: 2, screened: true);
    p.markOpened('s1');
    p.step('s1').audioDone = true;
    p.step('s1').microDone.add('m1');
    final q = CourseProgress.fromJson(p.toJson());
    expect(q.round, 2);
    expect(q.screened, isTrue);
    expect(q.step('s1').audioDone, isTrue);
    expect(q.step('s1').microDone, contains('m1'));
    expect(q.openedTodayCount, 1);
  });
}

// Course content sanity: every bundled course parses, has 8 steps with unique
// ids, steps 1-2 free, and every tool page that shows a saved card names a
// card type some step actually produces.
void courseContentTests() {
  for (final id in ['eating_no_autopilot']) {
    test('course $id parses and is consistent', () {
      final raw = jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>;
      final c = Course.fromJson(raw, 'ru');
      expect(c.steps.length, 8);
      expect(c.steps.map((s) => s.id).toSet().length, 8);
      expect(c.steps.where((s) => s.free).map((s) => s.id).toList(), ['s1', 's2']);
      final types = c.steps.map((s) => s.task.cardType).toSet();
      for (final t in c.tools) {
        for (final p in t.pages) {
          if (p.showCard != null) expect(types, contains(p.showCard!.split(':').first), reason: '${t.id}: ${p.showCard}');
        }
        for (final p in t.pages) {
          for (final b in p.buttons) {
            if (b.action.startsWith('tool:')) {
              expect(c.tools.map((x) => x.id), contains(b.action.substring(5)));
            }
          }
        }
      }
      for (final pt in c.planTypes) {
        expect(types, contains(pt));
      }
      expect(c.screening.where((q) => q.level == 'stop'), isNotEmpty);
      expect(c.weekly.length, 3);
    });
  }
}

// "Вернуться к себе": the blocks, numbering, free steps and every cross
// reference (tools, plan cards, log actions, audio ids) must be consistent.
void returnToSelfTests() {
  test('course return_to_self: blocks, numbering, free steps, references', () {
    final raw = jsonDecode(File('assets/courses/return_to_self.json').readAsStringSync()) as Map<String, dynamic>;
    final c = Course.fromJson(raw, 'ru');
    expect(c.steps.length, 16);
    expect(c.steps.map((s) => s.id).toSet().length, 16);
    expect(c.maxNewPerDay, 1);
    expect(c.groups.map((g) => g.id), ['support1', 'support2', 'main']);
    // Support blocks: unnumbered, never suggested; the two lesson blocks
    // are numbered from 1 each.
    for (final s in c.steps) {
      final g = c.groupOf(s);
      expect(s.groupId, g.id);
      if (!g.numbered) {
        expect(s.number, isNull);
        expect(s.alwaysAvailable, isTrue);
      }
    }
    List<int?> numbers(String g) => c.steps.where((s) => s.groupId == g).map((s) => s.number).toList();
    expect(numbers('main'), List.generate(11, (i) => i + 1));
    // Free: the whole first block and path step 1 only.
    expect(c.steps.where((s) => s.free).map((s) => s.id).toSet(), {'wave', 'loss', 'urge'});
    expect(c.steps.where((s) => s.groupId == 'support1').map((s) => s.id), ['wave', 'loss']);
    expect(c.steps.where((s) => s.groupId == 'support2').map((s) => s.id), ['night', 'slip', 'evening']);
    expect(c.calmStepId, isNotNull);
    expect(c.steps.map((s) => s.id), contains(c.calmStepId));
    expect(c.steps.firstWhere((s) => s.id == 'night').night, isTrue);
    expect(c.steps.firstWhere((s) => s.id == 'night').special, 'night_box');
    final types = c.steps.map((s) => s.task.cardType).toSet();
    for (final t in c.tools) {
      for (final p in t.pages) {
        if (p.showCard != null) expect(types, contains(p.showCard!.split(':').first));
        for (final b in p.buttons) {
          if (b.action.startsWith('tool:')) expect(c.tools.map((x) => x.id), contains(b.action.substring(5)));
        }
      }
    }
    for (final pt in c.planTypes) {
      expect(types, contains(pt));
    }
    // Every audio doc id is program_return__<step id>, matching the Firestore docs.
    for (final s in c.steps) {
      expect(s.audioDocId, 'program_return__${s.id}');
    }
    // Scales are recorded with a name; weekly questions too.
    expect(c.weekly.length, 4);
    expect(c.weekly.every((w) => w.record != null), isTrue);
    final scaleFields = c.steps.expand((s) => s.task.fields).where((f) => f.type == 'scale');
    expect(scaleFields.every((f) => f.record != null), isTrue);
    expect(c.screening.where((q) => q.level == 'stop'), isNotEmpty);
  });

  test('older courses record their scales too', () {
    for (final id in ['eating_no_autopilot']) {
      final c = Course.fromJson(
          jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>, 'ru');
      expect(c.weekly.every((w) => w.record != null), isTrue, reason: id);
      for (final t in c.tools) {
        for (final p in t.pages) {
          if (p.scaleId != null) expect(p.scaleRecord, isNotNull, reason: '$id ${t.id}');
        }
      }
    }
  });
}
