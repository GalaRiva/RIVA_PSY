// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../day_event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DayEventModel _$DayEventModelFromJson(Map<String, dynamic> json) =>
    DayEventModel(
      howDoYouFeel: json['howDoYouFeel'],
      workingOut: json['workingOut'] ?? false,
      whatHappened: json['whatHappened'] == null
          ? null
          : EventModel.fromJson(json['whatHappened'] as Map<String, dynamic>),
      whereHappened: json['whereHappened'] == null
          ? null
          : EventModel.fromJson(json['whereHappened'] as Map<String, dynamic>),
      whoDidItHappen: json['whoDidItHappen'] == null
          ? null
          : EventModel.fromJson(json['whoDidItHappen'] as Map<String, dynamic>),
      whatEmotion: (json['whatEmotion'] as List<dynamic>?)
          ?.map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      emotionIntensity: json['emotionIntensity'] as int? ?? 10,
      whatIDo: json['whatIDo'] as String?,
whatBodyParts: (json['whatBodyParts'] as List<dynamic>).map((e) => K32Model.fromJson(e)).toList(),
      firstThoughts: json['firstThoughts'] as String?,
        pathToAudio: json['pathToAudio'] as String?,

        date: json['date'] == null ? null : DateTime.parse(json['date'])
    );

Map<String, dynamic> _$DayEventModelToJson(DayEventModel instance) =>
    <String, dynamic>{
      'howDoYouFeel' : instance.howDoYouFeel,
      'whatHappened': instance.whatHappened,
      'workingOut': instance.workingOut,
      'whereHappened': instance.whereHappened,
      'whoDidItHappen': instance.whoDidItHappen,
      'whatEmotion': instance.whatEmotion,
      'whatBodyParts': instance.whatBodyParts,
      'emotionIntensity': instance.emotionIntensity,
      'whatIDo': instance.whatIDo,
      'firstThoughts': instance.firstThoughts,
          'date': instance.date == null ? null : instance.date!.toIso8601String(),
      'pathToAudio': instance.pathToAudio
    };
