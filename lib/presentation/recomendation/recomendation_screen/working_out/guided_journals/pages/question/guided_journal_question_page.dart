import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../portrait/widgets/glass_button.dart';
import '../../bloc/guided_journals_cubit.dart';
import '../../bloc/guided_journals_state.dart';
import '../../widgets/guided_journal_page_background.dart';

class GuidedJournalQuestionPage extends StatelessWidget {
  const GuidedJournalQuestionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuidedJournalsCubit, GuidedJournalsState>(
      builder: (context, state) {
        final topic = state.selectedTopic;
        if (topic == null) return const SizedBox.shrink();
        // Keying by questionIndex forces a fresh field (and fresh initial
        // text from any already-given answer) instead of carrying over the
        // previous question's controller state — same reason RecordPage
        // seeds its controller in the constructor rather than reusing one
        // across different content.
        return _QuestionBody(
          key: ValueKey(state.questionIndex),
          question: topic.questions[state.questionIndex],
          initialAnswer: state.answers.length > state.questionIndex
              ? state.answers[state.questionIndex]
              : '',
          questionNumber: state.questionIndex + 1,
          totalQuestions: topic.questions.length,
          isLast: state.questionIndex + 1 == topic.questions.length,
          imageUrl: topic.imageUrl,
        );
      },
    );
  }
}

class _QuestionBody extends StatefulWidget {
  final String question;
  final String initialAnswer;
  final int questionNumber;
  final int totalQuestions;
  final bool isLast;
  final String? imageUrl;

  const _QuestionBody({
    Key? key,
    required this.question,
    required this.initialAnswer,
    required this.questionNumber,
    required this.totalQuestions,
    required this.isLast,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<_QuestionBody> createState() => _QuestionBodyState();
}

class _QuestionBodyState extends State<_QuestionBody> {
  late final answerController =
      TextEditingController(text: widget.initialAnswer);

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GuidedJournalsCubit>();
    return GuidedJournalPageBackground(
      imageUrl: widget.imageUrl,
      child: SingleChildScrollView(
        child: Padding(
          padding: getPadding(left: 16, right: 16, top: 4, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'guided_journal_question_progress'.tr(args: [
                  '${widget.questionNumber}',
                  '${widget.totalQuestions}'
                ]),
                style: AppStyle.txtSFProDisplayLight12
                    .copyWith(color: Colors.white.withOpacity(0.75)),
              ),
              SizedBox(height: getVerticalSize(10)),
              Text(widget.question,
                  style: AppStyle.txtH2.copyWith(color: Colors.white)),
              SizedBox(height: getVerticalSize(20)),
              TextFormField(
                controller: answerController,
                maxLines: 8,
                minLines: 5,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: ColorConstant.grayLight,
                  filled: true,
                  hintText: 'guided_journal_answer_hint'.tr(),
                  hintStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                    color: ColorConstant.fromHex('#3B3B4A'),
                  ),
                ),
              ),
              SizedBox(height: getVerticalSize(24)),
              GlassButton(
                text: (widget.isLast
                        ? 'guided_journal_finish'.tr()
                        : 'continue'.tr())
                    .toUpperCase(),
                height: 47,
                onTap: () => cubit.answerAndContinue(answerController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
