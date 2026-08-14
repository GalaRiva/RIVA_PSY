class InsightModel {
  final String id;
  final DateTime generatedAt;
  final String category;
  final String templateKey;
  final Map<String, String> namedArgs;
  final bool isRead;
  final String? feedback;

  InsightModel({
    required this.id,
    required this.generatedAt,
    required this.category,
    required this.templateKey,
    required this.namedArgs,
    this.isRead = false,
    this.feedback,
  });

  InsightModel copyWith({bool? isRead, String? feedback}) {
    return InsightModel(
      id: id,
      generatedAt: generatedAt,
      category: category,
      templateKey: templateKey,
      namedArgs: namedArgs,
      isRead: isRead ?? this.isRead,
      feedback: feedback ?? this.feedback,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'generatedAt': generatedAt.toIso8601String(),
      'category': category,
      'templateKey': templateKey,
      'namedArgs': namedArgs,
      'isRead': isRead,
      'feedback': feedback,
    };
  }

  factory InsightModel.fromJson(Map<String, dynamic> json) {
    return InsightModel(
      id: json['id'],
      generatedAt: DateTime.parse(json['generatedAt']),
      category: json['category'],
      templateKey: json['templateKey'],
      namedArgs: json['namedArgs'] != null
          ? Map<String, String>.from(json['namedArgs'])
          : const {},
      isRead: json['isRead'] ?? false,
      feedback: json['feedback'],
    );
  }
}
