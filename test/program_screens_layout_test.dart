import 'dart:convert';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/data/course_progress_store.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/models/course.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/pages/course_screen.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/pages/form_task_screen.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/widgets/course_about.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/widgets/daily_thought_card.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/pages/course_step_screen.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/pages/screening_screen.dart';

// The Programs screens must lay out without overflowing, in every language
// they are offered in, at the normal font and at the largest size the app allows
// (the text scale is capped at 1.3). A RenderFlex overflow is reported by the
// framework as an exception, so "no exception" means "nothing is cut off".

class _FileLoader extends AssetLoader {
  const _FileLoader();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async => json
      .decode(File('assets/translations/${locale.languageCode}-${locale.countryCode}.json').readAsStringSync())
      as Map<String, dynamic>;
}

const _countries = {'ru': 'RU', 'en': 'US', 'es': 'ES'};

// Details of the errors the framework reported while a test ran, to say WHERE.
final List<FlutterErrorDetails> _seen = [];
bool _hooked = false;

void _hook() {
  if (_hooked) return;
  _hooked = true;
  final prev = FlutterError.onError;
  FlutterError.onError = (d) {
    _seen.add(d);
    prev?.call(d);
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'course_welcome_seen_return_to_self': true,
      'course_welcome_seen_depression_support': true,
      'course_welcome_seen_eating_no_autopilot': true,
      'shortcut_hint_dismissed_v1': true,
    });
    await EasyLocalization.ensureInitialized();
    Hive.init(Directory.systemTemp.createTempSync('hive_layout').path);
    final dir = '${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts';
    ByteData f(String n) => ByteData.view(File('$dir/$n').readAsBytesSync().buffer);
    final icons = FontLoader('MaterialIcons')..addFont(Future.value(f('MaterialIcons-Regular.otf')));
    await icons.load();
    for (final fam in ['Manrope', 'Roboto']) {
      final l = FontLoader(fam)
        ..addFont(Future.value(f('Roboto-Regular.ttf')))
        ..addFont(Future.value(f('Roboto-Medium.ttf')))
        ..addFont(Future.value(f('Roboto-Light.ttf')));
      await l.load();
    }
  });

  Future<void> show(WidgetTester tester, Widget Function(Course c) home, Course c, String lang, double scale) async {
    _hook();
    _seen.clear();
    tester.view.physicalSize = const Size(1080, 2400); // 360 x 800
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final loc = Locale(lang, _countries[lang]);
    await tester.runAsync(() async {
      await tester.pumpWidget(EasyLocalization(
        supportedLocales: [loc],
        fallbackLocale: loc,
        startLocale: loc,
        path: 'x',
        assetLoader: const _FileLoader(),
        child: Builder(
          builder: (context) => MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            builder: (c2, child) => MediaQuery(
                data: MediaQuery.of(c2).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
            home: home(c),
          ),
        ),
      ));
      await Future.delayed(const Duration(milliseconds: 1600));
    });
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 250)));
    }
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<Course> prepared(WidgetTester tester, String id, String lang, {bool screened = true}) async {
    final c = Course.fromJson(jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>, lang);
    await tester.runAsync(() async {
      final p = await CourseProgressStore.load(c.id);
      p.screened = screened;
      await CourseProgressStore.save(c.id, p);
    });
    return c;
  }

  // Fails with the framework's own description of what overflowed and where.
  void noOverflow(WidgetTester tester, [String where = '']) {
    final e = tester.takeException();
    var hint = '';
    if (e != null && _seen.isNotEmpty) {
      final d = _seen.last;
      final info = d.informationCollector?.call().map((n) => n.toStringDeep()).join(' ') ?? '';
      hint = '${d.exceptionAsString()} ${info.replaceAll('\n', ' ')}';
    }
    _seen.clear();
    expect(e, isNull, reason: '$where $hint');
  }

  const combos = [
    ['eating_no_autopilot', 'ru'],
    ['eating_no_autopilot', 'en'],
    ['eating_no_autopilot', 'es'],
    ['return_to_self', 'ru'],
    ['return_to_self', 'es'],
    ['depression_support', 'ru'],
    ['depression_support', 'es'],
  ];

  for (final scale in [1.0, 1.3]) {
    for (final spec in combos) {
      final id = spec[0];
      final lang = spec[1];

      testWidgets('course page: $id/$lang at x$scale does not overflow', (tester) async {
        final c = await prepared(tester, id, lang);
        await show(tester, (c) => CourseScreen(course: c), c, lang, scale);
        noOverflow(tester);
        // scroll through the whole page
        for (var k = 0; k < 6; k++) {
          await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -700));
          await tester.pump(const Duration(milliseconds: 200));
        }
        noOverflow(tester);
      });

      testWidgets('step page: $id/$lang at x$scale does not overflow', (tester) async {
        final c = await prepared(tester, id, lang);
        // the longest titles are the risky ones: check every step
        for (var i = 0; i < c.steps.length; i += (c.steps.length > 8 ? 3 : 2)) {
          await show(tester, (c) => CourseStepScreen(course: c, step: c.steps[i], index: i), c, lang, scale);
          noOverflow(tester, 'step $i');
          await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -900));
          await tester.pump(const Duration(milliseconds: 200));
          noOverflow(tester, 'step $i scrolled');
        }
      });
    }

    for (final spec in const [['eating_no_autopilot', 'es'], ['return_to_self', 'es'], ['return_to_self', 'ru']]) {
      testWidgets('safety questions: ${spec[0]}/${spec[1]} at x$scale do not overflow', (tester) async {
        final c = await prepared(tester, spec[0], spec[1], screened: false);
        await show(tester, (c) => ScreeningScreen(course: c), c, spec[1], scale);
        noOverflow(tester);
      });
    }

    testWidgets('about panel blocks and folds at x$scale do not overflow', (tester) async {
      final c = await prepared(tester, 'depression_support', 'ru');
      await show(tester, (c) => Scaffold(body: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [CourseAboutBody(course: c), const DailyThoughtCard()])))), c, 'ru', scale);
      noOverflow(tester, 'closed');
      for (final label in ['Научная основа', 'Источники']) {
        final f = find.textContaining(label);
        if (f.evaluate().isNotEmpty) {
          await tester.ensureVisible(f.first);
          await tester.tap(f.first);
          await tester.pump(const Duration(milliseconds: 400));
        }
      }
      noOverflow(tester, 'opened');
    });

    testWidgets('task form asks one question at a time at x$scale', (tester) async {
      final c = await prepared(tester, 'depression_support', 'ru');
      final step = c.steps.firstWhere((s) => s.task.fields.length >= 3);
      await show(tester, (c) => FormTaskScreen(courseId: c.id, task: step.task, round: 1, course: c, stepTitle: step.title), c, 'ru', scale);
      noOverflow(tester, 'first question');
      expect(find.text('Дальше'), findsOneWidget);
      for (var k = 0; k < step.task.fields.length - 1; k++) {
        await tester.tap(find.text('Дальше'));
        await tester.pump(const Duration(milliseconds: 400));
        noOverflow(tester, 'question ${k + 2}');
      }
      expect(find.text('Сохранить в библиотеку'), findsOneWidget);
    });

    testWidgets('course page modules open and close at x$scale', (tester) async {
      final c = await prepared(tester, 'depression_support', 'ru');
      await show(tester, (c) => CourseScreen(course: c), c, 'ru', scale);
      noOverflow(tester);
      expect(c.modules.length, 3);
      for (final m in c.modules) {
        final f = find.text(m.title);
        if (f.evaluate().isEmpty) {
          await tester.dragUntilVisible(f, find.byType(SingleChildScrollView).first, const Offset(0, -300));
        }
        await tester.ensureVisible(f.first);
        await tester.tap(f.first);
        await tester.pump(const Duration(milliseconds: 400));
        noOverflow(tester, 'module ${m.id}');
      }
    });
  }
}
