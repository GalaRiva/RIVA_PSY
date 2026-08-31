// Hand-written toJson/fromJson (no build_runner) — same choice as Audio/
// EventModel elsewhere in the app, for a model this simple.
class PortraitTestResultModel {
  final String testId; // PortraitTestId.name
  final List<int> answers; // option index (0-3) per question, in order
  final List<String> dominantKeys; // 1 = clean win, 2 = tie/hybrid
  final DateTime completedAt;

  const PortraitTestResultModel({
    required this.testId,
    required this.answers,
    required this.dominantKeys,
    required this.completedAt,
  });

  factory PortraitTestResultModel.fromJson(Map<String, dynamic> json) {
    return PortraitTestResultModel(
      testId: json['testId'] as String,
      answers: (json['answers'] as List).map((e) => e as int).toList(),
      dominantKeys:
          (json['dominantKeys'] as List).map((e) => e as String).toList(),
      completedAt: DateTime.parse(json['completedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'testId': testId,
        'answers': answers,
        'dominantKeys': dominantKeys,
        'completedAt': completedAt.toIso8601String(),
      };
}
