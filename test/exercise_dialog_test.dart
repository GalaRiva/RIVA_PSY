import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riva_psy/widgets/exercise_instruction_dialog.dart';

// The popup is shown with showDialog (no Material ancestor of its own): it must
// open without the "No Material widget found" error, fit a long text at the
// largest font size, and close from its button.

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('opens and closes, x$scale', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final long = List.generate(14, (i) => 'Frase número $i para vivir la emoción con calma y sin prisa.').join('.\n');
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(size: const Size(360, 800), textScaler: TextScaler.linear(scale)),
          child: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog(
                    context: context,
                    builder: (_) => ExerciseInstructionDialog(title: 'Desconcierto (perplejidad)', content: long)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Desconcierto (perplejidad)'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Desconcierto (perplejidad)'), findsNothing);
    });
  }
}
