import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/guided_journal_answers_store.dart';
import '../data/guided_journals_repository.dart';
import '../models/guided_journal_topic.dart';
import 'guided_journals_state.dart';

class GuidedJournalsCubit extends Cubit<GuidedJournalsState> {
  final _repo = GuidedJournalsRepository();

  GuidedJournalsCubit() : super(const GuidedJournalsState()) {
    _init();
  }

  Future<void> _init() async {
    final topics = await _repo.getTopics();
    emit(GuidedJournalsState.library(topics));
  }

  void selectTopic(GuidedJournalTopic topic) {
    emit(GuidedJournalsState(
      loading: false,
      stage: GuidedJournalStage.question,
      topics: state.topics,
      selectedTopic: topic,
      questionIndex: 0,
      answers: List.filled(topic.questions.length, ''),
    ));
  }

  // Called from the question screen's "Далее" — advances to the next
  // question, or (on the last one) saves locally, resolves audio, and
  // moves to the insight screen.
  Future<void> answerAndContinue(String answer) async {
    final topic = state.selectedTopic;
    if (topic == null) return;
    final answers = [...state.answers];
    if (state.questionIndex < answers.length) answers[state.questionIndex] = answer;

    if (state.questionIndex + 1 < topic.questions.length) {
      emit(state.copyWith(answers: answers, questionIndex: state.questionIndex + 1));
      return;
    }

    await GuidedJournalAnswersStore.save(topic.id, answers);
    emit(state.copyWith(answers: answers, stage: GuidedJournalStage.insight, resolvingAudio: true));
    final audioUrl = await _repo.resolveAudioUrl(topic);
    // The user may have already navigated back to the library while this
    // was resolving — don't stomp a newer stage with a stale audio result.
    if (state.stage == GuidedJournalStage.insight && state.selectedTopic?.id == topic.id) {
      emit(state.copyWith(audioUrl: audioUrl, resolvingAudio: false));
    }
  }

  void backToLibrary() {
    emit(GuidedJournalsState.library(state.topics));
  }
}
