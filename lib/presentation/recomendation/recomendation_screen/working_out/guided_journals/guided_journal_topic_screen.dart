import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';

import '../../../../initial_setup/onboarding/onboarding_concern.dart';
import 'bloc/guided_journals_cubit.dart';
import 'bloc/guided_journals_state.dart';
import 'models/guided_journal_topic.dart';
import 'pages/insight/guided_journal_insight_page.dart';
import 'pages/paywall/guided_journal_paywall_page.dart';
import 'pages/question/guided_journal_question_page.dart';

// Opens one "Хлебные крошки" topic directly (from the home "next step" card)
// without going through the Recommendations -> Обретение -> library path.
// Reuses the exact same cubit and question/insight pages as
// GuidedJournalsPage; only the library step is skipped. A locked topic
// (index >= kGuidedJournalFreeTopicCount, non-Orion) goes to the same
// paywall page the library uses. Leaving the topic pops back to the caller.
class GuidedJournalTopicScreen extends StatelessWidget {
  final String topicId;
  // The onboarding "next step" topic opens once without a subscription (the
  // caller only passes true while that free pass is still unused); the
  // library keeps its normal gating either way.
  final bool freePass;
  const GuidedJournalTopicScreen({Key? key, required this.topicId, this.freePass = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GuidedJournalsCubit(),
      child: _TopicHost(topicId: topicId, freePass: freePass),
    );
  }
}

class _TopicHost extends StatefulWidget {
  final String topicId;
  final bool freePass;
  const _TopicHost({required this.topicId, required this.freePass});

  @override
  State<_TopicHost> createState() => _TopicHostState();
}

class _TopicHostState extends State<_TopicHost> {
  bool _opened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1917),
      // The question/insight pages were built to sit inside the
      // Recommendations scaffold (which supplies the safe area); standalone
      // they would run under the status bar/notch without this.
      body: SafeArea(
        child: BlocConsumer<GuidedJournalsCubit, GuidedJournalsState>(
        listener: (context, state) {
          // Reaching the insight consumes the one-time free pass (and hides
          // the home card). Only the onboarding entry point counts.
          if (state.stage == GuidedJournalStage.insight && widget.freePass) {
            OnboardingPrefs.markNextStepDone();
          }
          if (state.stage != GuidedJournalStage.library || state.loading) return;
          if (_opened) {
            // backToLibrary() from question/insight — leave this screen.
            Navigator.of(context).maybePop();
            return;
          }
          _opened = true;
          final index = state.topics.indexWhere((t) => t.id == widget.topicId);
          if (index < 0) {
            Navigator.of(context).maybePop();
            return;
          }
          final locked = !widget.freePass &&
              index >= kGuidedJournalFreeTopicCount &&
              !CurrentUser.tariffIsOrion();
          if (locked) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const GuidedJournalPaywallPage()),
            );
            return;
          }
          context.read<GuidedJournalsCubit>().selectTopic(state.topics[index]);
        },
        builder: (context, state) {
          switch (state.stage) {
            case GuidedJournalStage.question:
              return const GuidedJournalQuestionPage();
            case GuidedJournalStage.insight:
              return const GuidedJournalInsightPage();
            case GuidedJournalStage.library:
              return Center(
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(color: ColorConstant.cyan700),
                ),
              );
          }
        },
      ),
      ),
    );
  }
}
