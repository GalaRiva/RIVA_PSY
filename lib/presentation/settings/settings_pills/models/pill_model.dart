import 'package:json_annotation/json_annotation.dart';

import 'adoption_model.dart';

part 'pill_model.g.dart';

@JsonSerializable()
class PillModel {
  final String name;
  final List<String> hoursOfTakingPills;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createDate;
  final List<AdoptionModel> adoptions;
  final String? dosage;
  final String? instructionTiming;
  @JsonKey(defaultValue: 'capsule')
  final String iconType;
  @JsonKey(defaultValue: 0xFF30D5C8)
  final int colorValue;
  final String? durationType;

  factory PillModel.fromJson(Map<String,dynamic> json) => _$PillModelFromJson(json);
  Map<String,dynamic> toJson()=> _$PillModelToJson(this);

  PillModel(   {required this.adoptions,required this.endDate,required this.name, required this.startDate, required this.hoursOfTakingPills, required this.createDate, this.dosage, this.instructionTiming, this.iconType = 'capsule', this.colorValue = 0xFF30D5C8, this.durationType,});

  bool actual () {
    return DateTime.now().isBefore(endDate) && DateTime.now().isAfter(startDate);
  }

  @override
  int compareTo(PillModel other) {
    return createDate.compareTo(other.createDate);
  }

}