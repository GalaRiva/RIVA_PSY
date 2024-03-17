// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spent_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SpentRecordModel _$SpentRecordModelFromJson(Map<String, dynamic> json) =>
    SpentRecordModel(
      dayEventModel:
          DayEventModel.fromJson(json['dayEventModel'] as Map<String, dynamic>),
      whyThisThoughts: json['whyThisThoughts'] as String,
      alternativeThoughts: json['alternativeThoughts'] as String,
      whyThisDo: json['whyThisDo'] as String,
      alternativeDo: json['alternativeDo'] as String,
      date: json['date'] == null ? DateTime.now() : DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$SpentRecordModelToJson(SpentRecordModel instance) =>
    <String, dynamic>{
      'dayEventModel': instance.dayEventModel,
      'whyThisThoughts': instance.whyThisThoughts,
      'alternativeThoughts': instance.alternativeThoughts,
      'whyThisDo': instance.whyThisDo,
      'alternativeDo': instance.alternativeDo,
      'date': instance.date.toIso8601String(),
    };
