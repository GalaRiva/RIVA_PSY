import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../../../../core/models/portrait/portrait_test_result_model.dart';
import '../../../../../core/services/notifications/awesome_notification_service.dart';
import '../data/portrait_repo.dart';
import 'portrait_state.dart';

class PortraitCubit extends Cubit<PortraitState> {
  final _repo = PortraitRepo();

  PortraitCubit() : super(const PortraitState()) {
    _init();
  }

  Future<void> _init() async {
    final results = await _repo.getResults();
    emit(PortraitState.library(results));
  }

  void selectTest(PortraitTestId id) {
    emit(PortraitState(
      loading: false,
      stage: PortraitStage.question,
      results: state.results,
      selectedTestId: id,
      questionIndex: 0,
      answers: const [],
    ));
  }

  void answer(String dominantKey) {
    final id = state.selectedTestId;
    if (id == null) return;
    final def = portraitTestDefinitions[id]!;
    final answers = [...state.answers, dominantKey];

    if (answers.length < def.questions.length) {
      emit(state.copyWith(answers: answers, questionIndex: answers.length));
      return;
    }

    _finish(id, answers);
  }

  Future<void> _finish(PortraitTestId id, List<String> answers) async {
    final counts = <String, int>{'A': 0, 'B': 0, 'C': 0, 'D': 0};
    for (final a in answers) {
      counts[a] = (counts[a] ?? 0) + 1;
    }
    final maxScore = counts.values.reduce((a, b) => a > b ? a : b);
    var winners = counts.entries.where((e) => e.value == maxScore).map((e) => e.key).toList();

    if (winners.length > 1) {
      // Tie-breaker: the anchor question (the 7th, last answered) — its
      // dominant wins outright if it's one of the tied leaders.
      final anchor = answers.last;
      if (winners.contains(anchor)) winners = [anchor];
      if (winners.length > 2) winners = winners.sublist(0, 2);
    }

    final result = PortraitTestResultModel(
      testId: id.name,
      answers: answers.map((a) => 'ABCD'.indexOf(a)).toList(),
      dominantKeys: winners,
      completedAt: DateTime.now(),
    );

    final results = [...state.results];
    results.removeWhere((r) => r.testId == id.name);
    results.add(result);
    await _repo.updateResults(results);

    if (kPortraitNumberedOrder.contains(id)) {
      AwesomeNotificationService()
          .schedulePortraitUnlockNotification(anchor: result.completedAt)
          .catchError((_) {});
    }

    emit(state.copyWith(
      loading: false,
      stage: PortraitStage.result,
      results: results,
      lastResult: result,
    ));
  }

  void backToLibrary() {
    emit(PortraitState.library(state.results));
  }

  // "Назад" from the question screen — one question back if mid-test (the
  // misclick case), or out to the library entirely from question 1 (the
  // "not ready to answer this one right now" case). Found missing during
  // manual testing on-device.
  void previousQuestion() {
    if (state.questionIndex == 0) {
      backToLibrary();
      return;
    }
    final answers = state.answers.sublist(0, state.answers.length - 1);
    emit(state.copyWith(answers: answers, questionIndex: state.questionIndex - 1));
  }
}
