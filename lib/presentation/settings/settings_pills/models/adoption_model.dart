class AdoptionModel {
  final DateTime adoptionDate;
  final List<String> adoptionTimes;

  AdoptionModel({required this.adoptionDate, required this.adoptionTimes});

  Map<String, dynamic> toJson() {
    return {
      'adoptionDate': adoptionDate.toIso8601String(),
      'adoptionTimes': adoptionTimes,
    };
  }

  factory AdoptionModel.fromJson(Map<String, dynamic> json) {
    return AdoptionModel(
      adoptionDate: DateTime.parse(json['adoptionDate']),
      adoptionTimes: List<String>.from(json['adoptionTimes']),
    );
  }
}
