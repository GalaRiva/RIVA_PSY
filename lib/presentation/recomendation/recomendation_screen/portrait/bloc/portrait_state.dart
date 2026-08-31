import '../../../../../core/models/portrait/portrait_test_definitions.dart';
import '../../../../../core/models/portrait/portrait_test_result_model.dart';

enum PortraitStage { library, question, result }

class PortraitState {
  final bool loading;
  final PortraitStage stage;
  final List<PortraitTestResultModel> results;
  final PortraitTestId? selectedTestId;
  final int questionIndex;
  final List<String> answers; // dominant key ('A'..'D') per answered question so far
  final PortraitTestResultModel? lastResult;

  const PortraitState({
    this.loading = true,
    this.stage = PortraitStage.library,
    this.results = const [],
    this.selectedTestId,
    this.questionIndex = 0,
    this.answers = const [],
    this.lastResult,
  });

  PortraitState copyWith({
    bool? loading,
    PortraitStage? stage,
    List<PortraitTestResultModel>? results,
    PortraitTestId? selectedTestId,
    int? questionIndex,
    List<String>? answers,
    PortraitTestResultModel? lastResult,
  }) {
    return PortraitState(
      loading: loading ?? this.loading,
      stage: stage ?? this.stage,
      results: results ?? this.results,
      selectedTestId: selectedTestId ?? this.selectedTestId,
      questionIndex: questionIndex ?? this.questionIndex,
      answers: answers ?? this.answers,
      lastResult: lastResult ?? this.lastResult,
    );
  }

  factory PortraitState.library(List<PortraitTestResultModel> results) =>
      PortraitState(loading: false, results: results);

  PortraitTestResultModel? resultFor(PortraitTestId id) {
    for (var i = results.length - 1; i >= 0; i--) {
      if (results[i].testId == id.name) return results[i];
    }
    return null;
  }

  bool hasResultFor(PortraitTestId id) => resultFor(id) != null;

  int get completedNumberedCount =>
      kPortraitNumberedOrder.where(hasResultFor).length;

  bool get allNumberedComplete =>
      completedNumberedCount == kPortraitNumberedOrder.length;

  // 24h gate — cadence only, independent of the tariff gate (tests 7+ and
  // the bonus additionally require Orion, checked separately in the UI).
  // Test 1 is always open; each later numbered test opens 24h after the
  // previous one's completedAt; the bonus opens 24h after test 12's.
  bool isUnlocked(PortraitTestId id) {
    if (id == PortraitTestId.bonusChronotype) {
      final anchor = resultFor(PortraitTestId.futureOutlook)?.completedAt;
      if (anchor == null) return false;
      return DateTime.now().isAfter(anchor.add(const Duration(hours: 24)));
    }
    final index = kPortraitNumberedOrder.indexOf(id);
    if (index <= 0) return true;
    final prevResult = resultFor(kPortraitNumberedOrder[index - 1]);
    if (prevResult == null) return false;
    return DateTime.now().isAfter(prevResult.completedAt.add(const Duration(hours: 24)));
  }

  // Null once unlocked (or for test 1, always null).
  DateTime? unlockAt(PortraitTestId id) {
    if (id == PortraitTestId.bonusChronotype) {
      final anchor = resultFor(PortraitTestId.futureOutlook)?.completedAt;
      return anchor?.add(const Duration(hours: 24));
    }
    final index = kPortraitNumberedOrder.indexOf(id);
    if (index <= 0) return null;
    final prevResult = resultFor(kPortraitNumberedOrder[index - 1]);
    return prevResult?.completedAt.add(const Duration(hours: 24));
  }
}
