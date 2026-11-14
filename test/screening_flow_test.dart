import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/models/course.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/programs/pages/screening_screen.dart';
import 'package:riva_psy/presentation/settings/help_now_screen/help_now_screen.dart';

// The safety questions before a course. Answering "yes" to the self-harm
// question must lead to the help page, and coming back must end the screening
// with "do not continue" (false) — never leave a blank screen with a spinner.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Course course(String id, String lang) => Course.fromJson(
      jsonDecode(File('assets/courses/$id.json').readAsStringSync()) as Map<String, dynamic>, lang);

  for (final spec in const [
    ['return_to_self', 'es'],
    ['return_to_self', 'ru'],
    ['eating_no_autopilot', 'es'],
  ]) {
    final id = spec[0];
    final lang = spec[1];

    Future<bool?> run(WidgetTester tester, bool answerYes) async {
      tester.view.physicalSize = const Size(1080, 4800);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      bool? result;
      var finished = false;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              result = await Navigator.push<bool>(
                  context, MaterialPageRoute(builder: (_) => ScreeningScreen(course: course(id, lang))));
              finished = true;
            },
            child: const Text('open'),
          ),
        )),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      final target = find.text(answerYes ? 'course_yes' : 'course_no');
      // The list builds cards lazily: answer what is on screen, scroll, repeat.
      for (var round = 0; round < 6; round++) {
        for (var i = 0; i < target.evaluate().length; i++) {
          await tester.tap(target.at(i));
          await tester.pump();
        }
        await tester.drag(find.byType(ListView), const Offset(0, -500));
        await tester.pump();
      }
      await tester.tap(find.text('CONTINUE'));
      await tester.pumpAndSettle();
      if (answerYes) {
        // Stopped on the help page, nothing has been reported back yet.
        expect(find.byType(HelpNowScreen), findsOneWidget);
        expect(finished, false);
        Navigator.of(tester.element(find.byType(HelpNowScreen))).pop();
        await tester.pumpAndSettle();
      }
      expect(finished, true);
      expect(find.byType(ScreeningScreen), findsNothing);
      expect(find.byType(HelpNowScreen), findsNothing);
      return result;
    }

    testWidgets('$id/$lang: "yes" to everything shows the help page, then ends with "do not continue"', (tester) async {
      expect(await run(tester, true), false);
    });
  }
}
