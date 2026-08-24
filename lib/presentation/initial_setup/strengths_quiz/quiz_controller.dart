import 'package:get/get.dart';

import '../../../core/models/quiz/quiz_question.dart';
import '../../../core/models/quiz/strength_trait.dart';

class StrengthsQuizController extends GetxController {
  int currentIndex = 0;
  int? currentAnswer;
  final Map<StrengthTrait, int> scores = {};

  QuizQuestion get currentQuestion => strengthsQuizQuestions[currentIndex];
  bool get isLastQuestion => currentIndex == strengthsQuizQuestions.length - 1;
  double get progress => (currentIndex + 1) / strengthsQuizQuestions.length;

  void selectAnswer(int value) {
    currentAnswer = value;
    update();
  }

  void confirmCurrentAnswer() {
    if (currentAnswer == null) return;
    scores[currentQuestion.trait] = currentAnswer!;
    // Only advance if there's a next question to show — on the last one,
    // the caller navigates away instead, so currentIndex must never point
    // past the end of strengthsQuizQuestions (GetBuilder would otherwise
    // rebuild this screen against an out-of-range index before the
    // navigation takes effect).
    if (!isLastQuestion) {
      currentIndex++;
      currentAnswer = null;
      update();
    }
  }

  // 1-2 leading strengths, highest score first — ties broken by original
  // question order (see TЗ: "ни одна черта не должна ощущаться как минус",
  // so we only ever surface the top, never rank the rest).
  List<StrengthTrait> computeTopTraits() {
    if (scores.isEmpty) return [];
    final maxScore = scores.values.reduce((a, b) => a > b ? a : b);
    final leaders = strengthsQuizQuestions
        .map((q) => q.trait)
        .where((t) => scores[t] == maxScore)
        .toList();
    return leaders.take(2).toList();
  }
}
