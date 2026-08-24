enum StrengthTrait {
  curiosity,
  kindness,
  gratitude,
  hope,
  wisdom,
  selfRegulation,
  love,
  humor,
}

extension StrengthTraitAssets on StrengthTrait {
  static const Map<StrengthTrait, String> _imageFileNames = {
    StrengthTrait.curiosity: 'curiosity',
    StrengthTrait.kindness: 'kindness',
    StrengthTrait.gratitude: 'gratitude',
    StrengthTrait.hope: 'hope',
    StrengthTrait.wisdom: 'wisdom',
    StrengthTrait.selfRegulation: 'self_regulation',
    StrengthTrait.love: 'love',
    StrengthTrait.humor: 'humor',
  };

  String get imageAsset => 'assets/images/quiz/${_imageFileNames[this]}.png';

  // easy_localization keys — one statement per trait, and the paired
  // result text (strength + shadow side + how the app helps, as one
  // flowing paragraph) shown after the quiz.
  String get statementKey => 'quiz_statement_${name}';
  String get resultBodyKey => 'quiz_result_body_${name}';
}
