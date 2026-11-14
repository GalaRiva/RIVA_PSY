import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/models/course.dart';

// Every language a course declares must be fully written in that language:
// no Russian letters left in any text the person can see.
void main() {
  final cyr = RegExp(r'[А-Яа-яЁё]');
  for (final id in ['eating_no_autopilot', 'return_to_self']) {
    final raw = jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>;
    final langs = (raw['languages'] as List).cast<String>();

    for (final lang in langs) {
      test('$id loads in $lang without leftovers', () {
        final c = Course.fromJson(raw, lang);
        expect(c.languages, contains(lang));
        expect(c.steps, isNotEmpty);
        final texts = <String>[c.title, c.subtitle];
        for (final s in c.steps) {
          texts.addAll([s.title, s.card, s.task.title, s.task.intro]);
          for (final f in s.task.fields) {
            texts.addAll([f.label, f.hint, ...f.chips]);
          }
          for (final m in s.micro) {
            texts.addAll([m.title, m.body]);
          }
        }
        for (final t in c.tools) {
          texts.addAll([t.title, t.subtitle]);
        }
        if (lang != 'ru') {
          final bad = texts.where((t) => cyr.hasMatch(t)).toList();
          expect(bad, isEmpty, reason: 'Russian left in $id/$lang: $bad');
        }
      });
    }

    // Any plain (not per-language) text with Russian letters is a text that was
    // missed: it would show in Russian in every language.
    test('$id has no untranslated Russian text outside the {ru,..} maps', () {
      final stray = <String>[];
      void walk(dynamic x, String path) {
        if (x is Map) {
          if (x.containsKey('ru') && x.keys.every((k) => ['ru', 'en', 'es'].contains(k))) return;
          x.forEach((k, v) => walk(v, '$path.$k'));
        } else if (x is List) {
          for (var i = 0; i < x.length; i++) {
            walk(x[i], '$path.$i');
          }
        } else if (x is String && cyr.hasMatch(x)) {
          stray.add('$path: $x');
        }
      }

      walk(raw, id);
      expect(stray, isEmpty);
    });
  }

  test('program card shows the short title where one is given, else the full title', () {
    Course load(String id, String lang) => Course.fromJson(
        jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>, lang);
    expect(load('return_to_self', 'ru').cardTitle, 'После расставания');
    expect(load('return_to_self', 'es').cardTitle, 'Después de la ruptura');
    expect(load('return_to_self', 'ru').title, 'После расставания. Вернуться к себе');
    final eating = load('eating_no_autopilot', 'es');
    expect(eating.cardTitle, eating.title);
  });

  test('every step keeps its artwork in every language (found by the Russian title)', () {
    for (final id in ['eating_no_autopilot', 'return_to_self']) {
      final raw = jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>;
      final ru = Course.fromJson(raw, 'ru');
      for (final lang in (raw['languages'] as List).cast<String>()) {
        final c = Course.fromJson(raw, lang);
        for (var i = 0; i < c.steps.length; i++) {
          final expected = audioCoverAsset(ru.steps[i].title);
          expect(expected, isNotNull, reason: 'no artwork for Russian step "${ru.steps[i].title}" in $id');
          expect(audioCoverAsset(c.steps[i].coverKey), expected, reason: '$id/$lang step "${c.steps[i].title}"');
        }
      }
    }
  });
}
