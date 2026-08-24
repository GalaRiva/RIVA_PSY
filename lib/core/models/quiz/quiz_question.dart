import 'strength_trait.dart';

class QuizQuestion {
  final StrengthTrait trait;
  const QuizQuestion(this.trait);

  String get statementKey => trait.statementKey;
}

// Order matches the original IPIP-VIA-based TЗ table — trait names are
// never shown to the user (only the statement), to avoid social-desirability
// bias skewing the answers.
const List<QuizQuestion> strengthsQuizQuestions = [
  QuizQuestion(StrengthTrait.curiosity),
  QuizQuestion(StrengthTrait.kindness),
  QuizQuestion(StrengthTrait.gratitude),
  QuizQuestion(StrengthTrait.hope),
  QuizQuestion(StrengthTrait.wisdom),
  QuizQuestion(StrengthTrait.selfRegulation),
  QuizQuestion(StrengthTrait.love),
  QuizQuestion(StrengthTrait.humor),
];
