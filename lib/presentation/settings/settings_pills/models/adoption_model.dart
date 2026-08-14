class AdoptionModel {
  final DateTime adoptionDate;
  final List<String> adoptionTimes;
  final List<String> skippedTimes;

  AdoptionModel({required this.adoptionDate, required this.adoptionTimes, List<String>? skippedTimes})
      : skippedTimes = skippedTimes ?? [];

  Map<String, dynamic> toJson() {
    return {
      'adoptionDate': adoptionDate.toIso8601String(),
      'adoptionTimes': adoptionTimes,
      'skippedTimes': skippedTimes,
    };
  }

  factory AdoptionModel.fromJson(Map<String, dynamic> json) {
    return AdoptionModel(
      adoptionDate: DateTime.parse(json['adoptionDate']),
      adoptionTimes: List<String>.from(json['adoptionTimes']),
      skippedTimes: json['skippedTimes'] != null ? List<String>.from(json['skippedTimes']) : [],
    );
  }
}
