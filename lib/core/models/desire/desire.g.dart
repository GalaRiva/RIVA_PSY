// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desire.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DesireImpl _$$DesireImplFromJson(Map<String, dynamic> json) => _$DesireImpl(
      simpleDesires: json['simpleDesires'] as String,
      desireDetails: json['desireDetails'] as String,
      dateOfExecution: DateTime.parse(json['dateOfExecution'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$$DesireImplToJson(_$DesireImpl instance) =>
    <String, dynamic>{
      'simpleDesires': instance.simpleDesires,
      'desireDetails': instance.desireDetails,
      'dateOfExecution': instance.dateOfExecution.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'completed': instance.completed,
    };
