import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:riva_psy/core/db/hive_db.dart';
import 'package:riva_psy/core/models/body_parts_model.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/models/emotional_state_model.dart';
import 'package:riva_psy/core/models/event_model.dart';
import 'package:riva_psy/presentation/main/main_screen/repository.dart';
import 'package:riva_psy/presentation/charts/charts_screen/controller.dart';
import 'package:riva_psy/presentation/main/path/what_body_parts_screen/k32_model.dart';

// Audit of the numbers behind the "Графики" tabs. Each test builds a tiny diary
// whose right answer is obvious by hand, runs the real K61Controller on it and
// compares.

K32Model part(String key) =>
    K32Model(BodyPartsModel(bodyPart: key, whatHurts: const ['x'], key: key), 'x');

EventModel emo(String key) => EventModel(key, 'x.svg', key);

DayEventModel event({
  required DateTime at,
  required List<String> emotions,
  List<String> parts = const [],
  String place = 'home',
}) =>
    DayEventModel(
      date: at,
      showInCharts: true,
      whereHappened: EventModel(place, 'x.svg', place),
      whatHappened: EventModel('w', 'x.svg'),
      whoDidItHappen: EventModel('who', 'x.svg'),
      whatEmotion: emotions.map(emo).toList(),
      whatBodyParts: parts.map(part).toList(),
    );

Future<void> save(List<DayEventModel> events) async {
  await HiveDB.openBox(HiveDBTags.dayEvents);
  await HiveDB.deleteBox(HiveDBTags.dayEvents);
  for (final e in events) {
    await HiveDB.setBox(e.toJson(), HiveDBTags.dayEvents);
  }
}

Future<K61Controller> run(List<DayEventModel> events,
    {DateTime? start, DateTime? end}) async {
  await save(events);
  final c = K61Controller();
  c.dateStart = start ?? DateTime(2026, 11, 9); // Monday
  c.dateEnd = end ?? DateTime(2026, 11, 15); // Sunday
  await c.getEmotions();
  return c;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    Hive.init(Directory.systemTemp.createTempSync('hive_audit').path);
  });

  test('period: only the chosen days are counted', () async {
    final c = await run([
      event(at: DateTime(2026, 11, 8, 12), emotions: ['anxiety']), // Sunday BEFORE
      event(at: DateTime(2026, 11, 9, 12), emotions: ['anxiety']), // Monday: in
      event(at: DateTime(2026, 11, 15, 23), emotions: ['anxiety']), // Sunday: in
      event(at: DateTime(2026, 11, 16, 1), emotions: ['anxiety']), // Monday AFTER
    ]);
    final anxiety = c.emotions.firstWhere((e) => e.key == 'anxiety');
    print('period: anxiety counted ${anxiety.quantity} times, expected 2');
    expect(anxiety.quantity, 2);
  });

  test('body map: one event with two body parts counts each part once', () async {
    final c = await run([
      event(at: DateTime(2026, 11, 10, 12), emotions: ['anxiety'], parts: ['head', 'chest']),
    ]);
    final e = c.emotionsInBody.firstWhere((x) => x.identity == 'anxiety');
    final q = {for (final b in e.bodyParts) b.bodyPart.bodyPartsModel.identity: b.quantity};
    print('body map: $q, expected {head: 1, chest: 1}');
    expect(q, {'head': 1, 'chest': 1});
  });

  test('positive vs negative: neutral emotion is counted once', () async {
    final c = await run([
      event(at: DateTime(2026, 11, 10, 12), emotions: ['doubt_positive']),
    ]);
    final q = {for (final t in c.emotionsTypes) t.name: t.quantity};
    print('types for ONE neutral(+) emotion: $q');
    expect(q, {'neutral_positive_emotions': 1});
  });

  test('positive vs negative: all four categories are told apart', () async {
    final c = await run([
      event(at: DateTime(2026, 11, 10, 12), emotions: ['anxiety', 'joy', 'doubt_positive', 'doubt_negative']),
    ]);
    final q = {for (final t in c.emotionsTypes) t.name: t.quantity};
    expect(q, {
      'negative_emotions': 1,
      'positive_emotions': 1,
      'neutral_positive_emotions': 1,
      'neutral_negative_emotions': 1,
    });
  });

  test('where in body: merging the three maps adds the real counts and changes nothing', () async {
    final c = await run([
      event(at: DateTime(2026, 11, 10, 12), emotions: ['anxiety'], parts: ['head']),
      event(at: DateTime(2026, 11, 10, 13), emotions: ['anxiety'], parts: ['head']),
      event(at: DateTime(2026, 11, 10, 14), emotions: ['joy'], parts: ['head', 'chest']),
      event(at: DateTime(2026, 11, 10, 15), emotions: ['doubt_positive'], parts: ['chest']),
    ]);
    Map<String, int> q(List l) => {for (final b in l) b.bodyPart.bodyPartsModel.identity as String: b.quantity as int};
    final all1 = q(c.sortBodyPartsList(c.positiveType!.bodyParts + c.negativeType!.bodyParts + c.neutralType!.bodyParts));
    final all2 = q(c.sortBodyPartsList(c.positiveType!.bodyParts + c.negativeType!.bodyParts + c.neutralType!.bodyParts));
    print('merged: $all1 (expected head 3, chest 2)');
    expect(all1, {'head': 3, 'chest': 2});
    expect(all2, all1); // a rebuild must not change the numbers
    expect(q(c.positiveType!.bodyParts), {'head': 1, 'chest': 1});
    expect(q(c.negativeType!.bodyParts), {'head': 2});
    expect(q(c.neutralType!.bodyParts), {'chest': 1});
  });

  test('where in body: a positive emotion does not change the negative map', () async {
    final c = await run([
      event(at: DateTime(2026, 11, 10, 12), emotions: ['anxiety'], parts: ['head']),
      event(at: DateTime(2026, 11, 10, 13), emotions: ['joy'], parts: ['head']),
    ]);
    final neg = {for (final b in c.negativeType!.bodyParts) b.bodyPart.bodyPartsModel.identity: b.quantity};
    final pos = {for (final b in c.positiveType!.bodyParts) b.bodyPart.bodyPartsModel.identity: b.quantity};
    print('negative map $neg (expected head:1), positive map $pos (expected head:1)');
    expect(neg, {'head': 1});
    expect(pos, {'head': 1});
  });

  test('quick save from the main screen (no body parts, no place) does not break the charts', () async {
    // Exactly what the main screen's "save" with a quick emotion chip writes.
    final quick = DayEventModel(
      howDoYouFeel: 7,
      date: DateTime(2026, 11, 10, 9),
      showInCharts: true,
      whatEmotion: [EventModel('joy', '', 'joy')],
      emotionIntensity: 7,
    );
    final c = await run([quick, event(at: DateTime(2026, 11, 10, 12), emotions: ['anxiety'], parts: ['head'])]);
    final names = c.emotions.map((e) => e.key).toSet();
    print('emotions counted: $names (expected joy and anxiety)');
    expect(names, {'joy', 'anxiety'});
    expect(c.emotionsTypes.map((t) => t.name).toSet(), {'positive_emotions', 'negative_emotions'});
  });

  test('first chart (state line) is built even when the diary cannot be read', () async {
    await HiveDB.openBox(HiveDBTags.dayEvents);
    await HiveDB.deleteBox(HiveDBTags.dayEvents);
    await HiveDB.setBox('not an entry', HiveDBTags.dayEvents); // unreadable on purpose
    await HiveDB.openBox(HiveDBTags.emotionalState);
    await HiveDB.deleteBox(HiveDBTags.emotionalState);
    final repo = K20Repo();
    for (final v in [4, 6, 3]) {
      await repo.updateEvent(EmotionalStateModel(v, DateTime.now()));
    }
    await Future.delayed(const Duration(milliseconds: 100)); // the repo writes without awaiting
    final c = K61Controller();
    c.dateStart = DateTime.now().subtract(const Duration(days: 1));
    c.dateEnd = DateTime.now().add(const Duration(days: 1));
    await c.init();
    print('state line: ${c.dataForChart} (expected [4, 6, 3])');
    expect(c.dataForChart, [4, 6, 3]);
  });

  test('state line only shows the saved moments of the chosen days', () async {
    await HiveDB.openBox(HiveDBTags.emotionalState);
    await HiveDB.deleteBox(HiveDBTags.emotionalState);
    final repo = K20Repo();
    await repo.updateEvent(EmotionalStateModel(1, DateTime(2026, 11, 8, 23))); // before
    await repo.updateEvent(EmotionalStateModel(5, DateTime(2026, 11, 9, 0, 30))); // first day
    await repo.updateEvent(EmotionalStateModel(7, DateTime(2026, 11, 15, 22))); // last day
    await repo.updateEvent(EmotionalStateModel(9, DateTime(2026, 11, 16, 0, 10))); // after
    await Future.delayed(const Duration(milliseconds: 100));
    final c = K61Controller()
      ..dateStart = DateTime(2026, 11, 9)
      ..dateEnd = DateTime(2026, 11, 15);
    expect(await c.getIntensity(), [5, 7]);
  });

  test('places: recalculating does not double the counts', () async {
    final c = await run([
      event(at: DateTime(2026, 11, 10, 12), emotions: ['anxiety']),
      event(at: DateTime(2026, 11, 11, 12), emotions: ['anxiety']),
    ]);
    int count() => c.placesResult.first.emotions.firstWhere((e) => e.key == 'anxiety').quantity;
    final first = count();
    await c.getEmotions(); // what changing the period / reopening the tab does
    final second = count();
    print('places: first run $first, after recalculation $second (expected 2 and 2)');
    expect(first, 2);
    expect(second, 2);
  });
}
