import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/widgets/glass_panel.dart';
import 'package:riva_psy/theme/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final dir = '${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts';
    ByteData f(String n) => ByteData.view(File('$dir/$n').readAsBytesSync().buffer);
    for (final fam in ['Manrope', 'Roboto']) {
      await (FontLoader(fam)..addFont(Future.value(f('Roboto-Regular.ttf')))..addFont(Future.value(f('Roboto-Medium.ttf'))))
          .load();
    }
  });
  for (final scale in [1.0, 1.3]) {
    testWidgets('panel x$scale', (tester) async {
      tester.view.physicalSize = const Size(1080, 1500);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final names = ['Indignación', 'Indignación (enojo)', 'Irritación', 'Desprecio', 'Enfado', 'Odio', 'Cólera (furia)', 'Sentirse herido/a'];
      await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          home: MediaQuery(
            data: MediaQueryData(size: const Size(360, 500), textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              backgroundColor: AppColors.screenWarm,
              body: SingleChildScrollView(
                child: EmotionGlassPanel(
                  title: 'Cómo vivir las emociones',
                  illustration: 'assets/images/recomendations/Group 1panic.svg',
                  children: [for (final n in names) GlassChip(text: n, onTap: () {})],
                ),
              ),
            ),
          ),
      ));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });
  }
}
