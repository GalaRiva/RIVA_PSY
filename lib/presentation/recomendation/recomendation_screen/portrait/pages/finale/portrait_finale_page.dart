import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../../../../../core/models/portrait/portrait_test_result_model.dart';
import '../../cta_action.dart';
import '../../cta_action_router.dart';
import '../../data/portrait_repo.dart';
import '../../widgets/projection_orb.dart';

class _FinaleInsight {
  final String title;
  final String body;
  const _FinaleInsight(this.title, this.body);
}

// The master-plan's own "Полярность/Конфликт" algorithm needs a full
// cross-test dominant-mapping table (12x12) that was never actually
// authored in the source — only these 2 illustrative pairs were. Rather
// than invent the rest of that mapping, this uses exactly the given
// examples (elaborated in the writing, not in the underlying claim) and
// grounds everything else in the user's own already-written result texts
// (see _tallyDominants below) instead of a fabricated full matrix.
_FinaleInsight? _polarityInsight(Map<PortraitTestId, PortraitTestResultModel> byId) {
  final t4 = byId[PortraitTestId.emotionalRadar];
  final t9 = byId[PortraitTestId.trueCompass];
  if (t4 != null && t9 != null && t4.dominantKeys.contains('C') && t9.dominantKeys.contains('C')) {
    return const _FinaleInsight(
      'Генеральная опора',
      'Люди — это ваш главный ресурс. Ваш радар Эмпатии (тест 4) помогает вам '
          'считывать чужое состояние за секунду и создавать вокруг себя '
          'пространство, где люди чувствуют себя услышанными. Это же качество '
          'отвечает и за то, куда ведёт ваш истинный компас (тест 9): вы снова и '
          'снова выбираете связь и близость важнее собственной выгоды. Но именно '
          'эта чувствительность быстрее всего сажает вашу Социальную батарейку — '
          'вы отдаёте раньше, чем успеваете заметить, что устали. Ваша главная '
          'задача на ближайшее время — не становиться холоднее, а научиться '
          'защищать своё сердце, не закрывая его.',
    );
  }
  return null;
}

_FinaleInsight? _conflictInsight(Map<PortraitTestId, PortraitTestResultModel> byId) {
  final t1 = byId[PortraitTestId.hiddenSupports];
  final t11 = byId[PortraitTestId.attachmentStyle];
  if (t1 != null && t11 != null && t1.dominantKeys.contains('A') && t11.dominantKeys.contains('A')) {
    return const _FinaleInsight(
      'Зона роста',
      'Ваш ум работает как швейцарские часы. Там, где другие теряются в хаосе, '
          'вы почти всегда находите структуру, логику, ясный следующий шаг — это '
          'опора, которая выручала вас снова и снова (тест 1). Но в отношениях '
          'вами иногда руководит совсем другой голос — тревога и страх потери '
          '(тест 11). Логика, которая работает почти везде, не умеет успокоить '
          'сердце, когда речь идёт о близком человеке — и это не поломка, а '
          'просто другой язык, на котором говорит эта часть вас. Приглашение '
          'здесь простое: позволить себе быть уязвимым(ой) не только умом, но и '
          'чувствами — рацио не обязано разбираться со всем в одиночку.',
    );
  }
  return null;
}

// One dominant's aggregated stats across however many of the 12 results it
// appeared as a winner (or a tied hybrid winner) in.
class _DominantTally {
  final String label;
  final String light;
  final CtaAction cta;
  final String ctaLabel;
  int count;

  _DominantTally({
    required this.label,
    required this.light,
    required this.cta,
    required this.ctaLabel,
    required this.count,
  });
}

// Grounds the finale's summary and recommendation in the user's own
// already-written result texts — no new cross-test psychological claims
// invented, just an honest tally of which dominants actually won, and how
// often, across their 12 results.
List<_DominantTally> _tallyDominants(List<PortraitTestResultModel> results) {
  final map = <String, _DominantTally>{};
  for (final r in results) {
    PortraitTestId? testId;
    for (final id in PortraitTestId.values) {
      if (id.name == r.testId) {
        testId = id;
        break;
      }
    }
    if (testId == null) continue;
    final def = portraitTestDefinitions[testId]!;
    for (final k in r.dominantKeys) {
      final dom = def.dominants[k];
      if (dom == null) continue;
      final existing = map[dom.label];
      if (existing != null) {
        existing.count++;
      } else {
        map[dom.label] = _DominantTally(
          label: dom.label,
          light: dom.light,
          cta: dom.cta,
          ctaLabel: dom.ctaLabel,
          count: 1,
        );
      }
    }
  }
  final list = map.values.toList()..sort((a, b) => b.count.compareTo(a.count));
  return list;
}

String _firstSentence(String text) {
  final match = RegExp(r'^.*?[.!?](?=\s|$)').firstMatch(text);
  return match != null ? match.group(0)! : text;
}

_FinaleInsight _personalitySummary(List<_DominantTally> tally) {
  if (tally.isEmpty) {
    return _FinaleInsight('portrait_finale_title'.tr(), '');
  }
  final top = tally.take(3).toList();
  final buffer = StringBuffer();
  buffer.write(
    'За эти 12 тестов сложилась довольно цельная картина. Чаще всего в вас '
    'побеждает ${top[0].label.toLowerCase()}: ${_firstSentence(top[0].light)}',
  );
  if (top.length > 1) {
    buffer.write(
      ' Рядом с этим заметно проявляется ${top[1].label.toLowerCase()} — '
      '${_firstSentence(top[1].light).toLowerCase()}',
    );
  }
  if (top.length > 2) {
    buffer.write(
      ' И третья опора, на которую вы тоже регулярно опираетесь — это '
      '${top[2].label.toLowerCase()}.',
    );
  }
  buffer.write(
    ' Ни одна из этих черт не описывает вас целиком — вы шире любого теста. '
    'Но именно эта комбинация чаще всего определяет, как вы принимаете решения, '
    'восстанавливаетесь и выстраиваете отношения с людьми вокруг.',
  );
  return _FinaleInsight('Ваша проекция', buffer.toString());
}

class PortraitFinalePage extends StatefulWidget {
  const PortraitFinalePage({Key? key}) : super(key: key);

  @override
  State<PortraitFinalePage> createState() => _PortraitFinalePageState();
}

class _PortraitFinalePageState extends State<PortraitFinalePage> {
  List<PortraitTestResultModel>? _results;

  @override
  void initState() {
    super.initState();
    PortraitRepo().getResults().then((value) {
      if (mounted) setState(() => _results = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1917),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _results == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, _results!),
    );
  }

  Widget _buildBody(BuildContext context, List<PortraitTestResultModel> results) {
    final byId = <PortraitTestId, PortraitTestResultModel>{
      for (final r in results) PortraitTestId.values.firstWhere((e) => e.name == r.testId): r,
    };
    final tally = _tallyDominants(results);

    // "Что увидели" — always present, grounded summary of the user's own
    // results (per feedback: a proper closing description of the
    // personality/projection, not just a one-liner).
    final insights = <_FinaleInsight>[_personalitySummary(tally)];
    final polarity = _polarityInsight(byId);
    final conflict = _conflictInsight(byId);
    if (polarity != null) insights.add(polarity);
    if (conflict != null) insights.add(conflict);

    // Recommendation — the most frequently winning dominant's own CTA,
    // surfaced as a concrete next step (a specific exercise or audio
    // practice), not a generic "explore the app" nudge.
    final recommendation = tally.isNotEmpty ? tally.first : null;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Full-bleed replay of the whole journey — near-darkness through
          // every phase to the final, richest state — instead of just
          // landing on the end result with no sense of the arc.
          const ProjectionOrbReplay(height: 280),
          Padding(
            padding: getPadding(left: 20, right: 20, top: 20, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'portrait_finale_title'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyle.txtH1WhiteA700.copyWith(fontSize: getFontSize(26)),
                ),
                SizedBox(height: getVerticalSize(14)),
                Text(
                  'portrait_finale_intro'.tr(),
                  textAlign: TextAlign.center,
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white.withOpacity(0.8), height: 1.5),
                ),
                SizedBox(height: getVerticalSize(26)),
                for (final insight in insights)
                  Container(
                    margin: getMargin(bottom: 16),
                    padding: getPadding(left: 18, top: 18, right: 18, bottom: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E211E),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC9A24B).withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          insight.title,
                          style: AppStyle.txtSFProDisplayRegular14.copyWith(
                            color: const Color(0xFFC9A24B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (insight.body.isNotEmpty) ...[
                          SizedBox(height: getVerticalSize(8)),
                          Text(
                            insight.body,
                            style: AppStyle.txtSFProDisplayLight14
                                .copyWith(color: Colors.white.withOpacity(0.85), height: 1.5),
                          ),
                        ],
                      ],
                    ),
                  ),
                if (recommendation != null)
                  Container(
                    margin: getMargin(bottom: 16),
                    padding: getPadding(left: 18, top: 18, right: 18, bottom: 18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF14312C), Color(0xFF1FAE7A)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Рекомендуем сделать упор на это',
                          style: AppStyle.txtSFProDisplayRegular14
                              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: getVerticalSize(8)),
                        Text(
                          'Ваша доминанта «${recommendation.label}» проявлялась чаще всего — '
                          'конкретное упражнение или аудио-практика для неё может дать больше, '
                          'чем что-то случайное.',
                          style: AppStyle.txtSFProDisplayLight14
                              .copyWith(color: Colors.white.withOpacity(0.9), height: 1.5),
                        ),
                        SizedBox(height: getVerticalSize(14)),
                        CustomButton(
                          text: recommendation.ctaLabel,
                          width: double.infinity,
                          height: 47,
                          showBorder: false,
                          bgColor: ColorConstant.cyan700.withOpacity(0.55),
                          borderRadius: 14,
                          textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white),
                          onTap: () => CtaActionRouter.navigate(
                            context,
                            recommendation.cta,
                            audioLabel: recommendation.ctaLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: getVerticalSize(10)),
                CustomButton(
                  text: 'portrait_finale_cta'.tr(),
                  width: double.infinity,
                  height: 47,
                  showBorder: false,
                  bgColor: ColorConstant.cyan700.withOpacity(0.55),
                  borderRadius: 14,
                  textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
