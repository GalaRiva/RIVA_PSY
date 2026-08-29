import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/widgets/go_to_new_tariff_widget.dart';

import 'bloc/guided_journals_cubit.dart';
import 'bloc/guided_journals_state.dart';
import 'pages/insight/guided_journal_insight_page.dart';
import 'pages/library/guided_journal_library_page.dart';
import 'pages/question/guided_journal_question_page.dart';

// "Хлебные крошки" — guided journals: a library of emotional themes, each
// walked through as one question per screen, ending in a short insight
// (+ optional audio). 4th exercise in "Обретение", alongside
// WorkingOutIrrationalTab/HappinessInFocusPage/DesiresPage — same
// self-contained BlocProvider + own tariff gate as DesiresPage.
class GuidedJournalsPage extends StatelessWidget {
  const GuidedJournalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuidedJournalsCubit(),
      child: BlocBuilder<GuidedJournalsCubit, GuidedJournalsState>(
        builder: (context, state) {
          if (!CurrentUser.tariffIsOrion()) {
            return GoToNewTariffWidget(goToFreeRecommendation: false);
          }
          switch (state.stage) {
            case GuidedJournalStage.question:
              return const GuidedJournalQuestionPage();
            case GuidedJournalStage.insight:
              return const GuidedJournalInsightPage();
            case GuidedJournalStage.library:
              return const GuidedJournalLibraryPage();
          }
        },
      ),
    );
  }
}
