import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../bloc/portrait_cubit.dart';
import '../../bloc/portrait_state.dart';

// Cyrillic labels for Russian, matching the source ТЗ's own А/Б/В/Г option
// lettering — Latin A/B/C/D was shown here originally, but Latin "B" and
// Cyrillic "В" are visual homoglyphs at different alphabet positions (Latin
// B = 2nd, Cyrillic В = 3rd), which caused a real mis-tap during on-device
// testing: a user reading "B" as Cyrillic landed on dominant B (2nd, Latin)
// while intending dominant C (3rd, "В"). dominantKey values themselves
// ('A'..'D') are unchanged — only this on-screen label changed, and only for
// Russian — English/Spanish never had the homoglyph problem, so they keep
// the plain Latin letters.
const List<String> _kLettersRu = ['А', 'Б', 'В', 'Г'];
const List<String> _kLettersLatin = ['A', 'B', 'C', 'D'];

const _kProjectionBg = Color(0xFF0B1917);

class PortraitQuestionPage extends StatelessWidget {
  const PortraitQuestionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PortraitCubit, PortraitState>(
      builder: (context, state) {
        final id = state.selectedTestId;
        if (id == null) return const ColoredBox(color: _kProjectionBg);
        final def = portraitTestDefinitions[id]!;
        final question = def.questions[state.questionIndex];
        final letters =
            context.locale.languageCode == 'ru' ? _kLettersRu : _kLettersLatin;

        return ColoredBox(
          color: _kProjectionBg,
          child: SingleChildScrollView(
            padding: getPadding(left: 16, right: 16, top: 8, bottom: 40),
            child: Column(
              key: ValueKey(state.questionIndex),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.read<PortraitCubit>().previousQuestion(),
                      child: Padding(
                        padding: getPadding(right: 8, top: 4, bottom: 4),
                        child: Icon(Icons.arrow_back_rounded,
                            size: getSize(20), color: Colors.white.withOpacity(0.7)),
                      ),
                    ),
                    Text(
                      'portrait_question_progress'
                          .tr(args: ['${state.questionIndex + 1}', '${def.questions.length}']),
                      style: AppStyle.txtSFProDisplayLight12.copyWith(color: Colors.white.withOpacity(0.6)),
                    ),
                  ],
                ),
                SizedBox(height: getVerticalSize(10)),
                Text(question.text.tr(), style: AppStyle.txtH2.copyWith(color: Colors.white)),
                SizedBox(height: getVerticalSize(20)),
                for (var i = 0; i < question.options.length; i++)
                  Padding(
                    padding: getPadding(bottom: 12),
                    child: _OptionCard(
                      letter: letters[i],
                      text: question.options[i].text.tr(),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<PortraitCubit>().answer(question.options[i].dominantKey);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Tap-to-advance card — no separate "Далее" button, per the master-plan's
// "Zero-Click Navigation" requirement for this flow.
class _OptionCard extends StatelessWidget {
  final String letter;
  final String text;
  final VoidCallback onTap;

  const _OptionCard({required this.letter, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: getPadding(left: 14, top: 14, right: 14, bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: getSize(26),
              height: getSize(26),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: ColorConstant.cyan700.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: Text(
                letter,
                style: AppStyle.txtSFProDisplayRegular12.copyWith(
                  color: ColorConstant.cyan700,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: getHorizontalSize(12)),
            Expanded(
              child: Text(text, style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white.withOpacity(0.9))),
            ),
          ],
        ),
      ),
    );
  }
}
