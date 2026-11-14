import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/soft_audio_card.dart';

// The soft track card must not overflow with long titles in any language, at
// the normal font and at the largest size the app allows (x1.3), and must
// show the playing state (tint + progress line).

const _titles = [
  'Introducción',
  'Mitos y falsas creencias sobre la depresión y cómo hablar de ellas con cercanía',
  'Мифы и ложные убеждения о депрессии и как о них говорить бережно',
  'Myths and false beliefs about depression and how to talk about them kindly',
];

AppAudioTrack _track(int i, {String? cover}) =>
    AppAudioTrack.forUrl('https://example.test/$i.mp3', title: _titles[i], coverAsset: cover);

Widget _list(double scale, {int? playingIndex}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MediaQuery(
      data: MediaQueryData(size: const Size(360, 800), textScaler: TextScaler.linear(scale)),
      child: Scaffold(
        backgroundColor: AppColors.screenWarm,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _titles.length; i++)
                SoftAudioCard(
                  text: _titles[i],
                  track: _track(i, cover: i == 1 ? 'assets/images/audio_covers/sadness2.jpg' : null),
                  maxDuration: Duration(seconds: 95 + i * 83),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = '${Platform.environment['FLUTTER_ROOT'] ?? ''}/bin/cache/artifacts/material_fonts';
    ByteData f(String n) => ByteData.view(File('$dir/$n').readAsBytesSync().buffer);
    await (FontLoader('MaterialIcons')..addFont(Future.value(f('MaterialIcons-Regular.otf')))).load();
    for (final fam in ['Manrope', 'Roboto']) {
      await (FontLoader(fam)
            ..addFont(Future.value(f('Roboto-Regular.ttf')))
            ..addFont(Future.value(f('Roboto-Medium.ttf')))
            ..addFont(Future.value(f('Roboto-Light.ttf'))))
          .load();
    }
  });

  tearDown(() => AppAudioService.instance.state.value = const AppAudioState());

  for (final scale in [1.0, 1.3]) {
    testWidgets('no overflow, idle, x$scale', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_list(scale));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);
    });

    testWidgets('no overflow, playing, x$scale', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      AppAudioService.instance.state.value = AppAudioState(
        track: _track(1),
        playing: true,
        position: const Duration(seconds: 42),
        duration: const Duration(seconds: 178),
      );
      await tester.pumpWidget(_list(scale));
      await tester.pump(const Duration(milliseconds: 400));
      expect(tester.takeException(), isNull);
      expect(find.byType(Slider), findsOneWidget);
      expect(find.text('0:42 / 2:58'), findsOneWidget);
    });
  }

  test('formatTime', () {
    expect(SoftAudioCard.formatTime(const Duration(seconds: 95)), '1:35');
    expect(SoftAudioCard.formatTime(const Duration(seconds: 178)), '2:58');
    expect(SoftAudioCard.formatTime(Duration.zero), '0:00');
  });
}
