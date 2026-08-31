import '../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../../../../core/models/portrait/portrait_test_result_model.dart';
import '../cta_action.dart';

class PortraitResultView {
  final String title;
  final String light;
  final String shadow;
  final String ctaLabel;
  final CtaAction cta;
  final bool isHybrid;

  const PortraitResultView({
    required this.title,
    required this.light,
    required this.shadow,
    required this.ctaLabel,
    required this.cta,
    required this.isHybrid,
  });
}

String _lowerFirst(String s) => s.isEmpty ? s : s[0].toLowerCase() + s.substring(1);

// Assembles the on-screen result from the test's dominant matrix — a single
// dominant's text as-is, or (on a tie) a dynamic splice of two, per the
// master-plan's own "не 72 текста вручную" assembly rule (PROJECT_CONTEXT.md
// §62). CTA on a hybrid comes from whichever dominant the anchor question
// (the 7th, index 6) picked — the "freshest" signal of current state.
PortraitResultView buildPortraitResultView(
  PortraitTestDefinition def,
  PortraitTestResultModel result,
) {
  final keys = result.dominantKeys;

  if (keys.length == 1) {
    final d = def.dominants[keys.first]!;
    return PortraitResultView(
      title: d.label,
      light: d.light,
      shadow: d.shadow,
      ctaLabel: d.ctaLabel,
      cta: d.cta,
      isHybrid: false,
    );
  }

  final anchorKey = 'ABCD'[result.answers.last];
  final ctaSource = def.dominants[anchorKey] ?? def.dominants[keys.first]!;
  final a = def.dominants[keys[0]]!;
  final b = def.dominants[keys[1]]!;

  return PortraitResultView(
    title: 'Уникальный синтез: ${a.label} и ${b.label}',
    light: 'В вас удивительным образом сочетаются две мощные опоры. С одной '
        'стороны, ${_lowerFirst(a.light)} С другой стороны, ${_lowerFirst(b.light)} '
        'Это делает вашу психику невероятно гибкой.',
    shadow: 'Однако этот синтез создает уникальное внутреннее напряжение. Вам '
        'приходится балансировать: ${_lowerFirst(a.shadow)} Но при этом '
        '${_lowerFirst(b.shadow)} Вы тратите много сил на то, чтобы примирить '
        'эти две части себя.',
    ctaLabel: ctaSource.ctaLabel,
    cta: ctaSource.cta,
    isHybrid: true,
  );
}
