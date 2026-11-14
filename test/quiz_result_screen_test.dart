import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:riva_psy/core/models/quiz/strength_trait.dart';
import 'package:riva_psy/presentation/initial_setup/strengths_quiz/result_screen.dart';
import 'package:riva_psy/widgets/custom_button.dart';

class _FileLoader extends AssetLoader {
  const _FileLoader();
  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    final f = File('assets/translations/${locale.languageCode}-${locale.countryCode}.json');
    return json.decode(f.readAsStringSync()) as Map<String, dynamic>;
  }
}

// The result screen of the strengths quiz on a phone with the 3-button
// navigation bar (48 px) and a larger system font: the "continue" button must
// be reachable and never end up under the bar.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  setUpAll(() async {
    await EasyLocalization.ensureInitialized();
    final dir = '${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts';
    ByteData f(String n) => ByteData.view(File('$dir/$n').readAsBytesSync().buffer);
    for (final fam in ['Manrope', 'Roboto']) {
      final l = FontLoader(fam)..addFont(Future.value(f('Roboto-Regular.ttf')))..addFont(Future.value(f('Roboto-Medium.ttf')));
      await l.load();
    }
  });

  for (final lang in const [Locale('es', 'ES'), Locale('en', 'US'), Locale('ru', 'RU')]) {
    for (final trait in StrengthTrait.values) {
      testWidgets('${lang.languageCode}: ${trait.name} - continue is reachable above the nav bar', (tester) async {
        tester.view.physicalSize = const Size(1080, 2400); // 360 x 800
        tester.view.devicePixelRatio = 3.0;
        tester.view.padding = const FakeViewPadding(top: 24 * 3, bottom: 48 * 3);
        tester.view.viewPadding = const FakeViewPadding(top: 24 * 3, bottom: 48 * 3);
        addTearDown(tester.view.reset);

        await tester.runAsync(() async {
          await tester.pumpWidget(EasyLocalization(
            supportedLocales: [lang],
            fallbackLocale: lang,
            startLocale: lang,
            path: 'unused',
            assetLoader: const _FileLoader(),
            useOnlyLangCode: false,
            child: Builder(builder: (context) => MaterialApp(
              locale: context.locale,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              builder: (c, child) => MediaQuery(
                  data: MediaQuery.of(c).copyWith(textScaler: const TextScaler.linear(1.2)), child: child!),
              home: QuizResultScreen(trait: trait, onContinue: (_) {}),
            )),
          ));
          await Future.delayed(const Duration(milliseconds: 300));
        });
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        final button = find.byType(CustomButton);
        expect(button, findsOneWidget);
        await tester.ensureVisible(button);
        await tester.pump();
        final bottom = tester.getRect(button).bottom;
        final limit = 800.0 - 48.0; // top of the navigation bar
        expect(bottom, lessThanOrEqualTo(limit + 0.5), reason: 'button bottom $bottom is under the bar (limit $limit)');
        // the button keeps its normal height (it once stretched to more than double)
        expect(tester.getSize(button).height, lessThan(60));
        // and a tap really reaches it
        await tester.tap(button, warnIfMissed: true);
      });
    }
  }
}
