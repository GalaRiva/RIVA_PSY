// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PillModel _$PillModelFromJson(Map<String, dynamic> json) => PillModel(
      adoptions: (json['adoptions'] as List<dynamic>)
          .map((e) => AdoptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      endDate: DateTime.parse(json['endDate'] as String),
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      hoursOfTakingPills: (json['hoursOfTakingPills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createDate: DateTime.parse(json['createDate'] as String),
      dosage: json['dosage'] as String?,
      instructionTiming: json['instructionTiming'] as String?,
      iconType: json['iconType'] as String? ?? 'capsule',
      colorValue: json['colorValue'] as int? ?? 4281390536,
      durationType: json['durationType'] as String?,
    );

Map<String, dynamic> _$PillModelToJson(PillModel instance) => <String, dynamic>{
      'name': instance.name,
      'hoursOfTakingPills': instance.hoursOfTakingPills,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'createDate': instance.createDate.toIso8601String(),
      'adoptions': instance.adoptions,
      'dosage': instance.dosage,
      'instructionTiming': instance.instructionTiming,
      'iconType': instance.iconType,
      'colorValue': instance.colorValue,
      'durationType': instance.durationType,
    };
