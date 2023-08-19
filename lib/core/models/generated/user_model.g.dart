// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      login: json['login'] as String?,
      email: json['email'] as String?,
      password: json['password'] as String?,
      reminderTime: json['reminderTime'] as int?,
      currentTariff: json['currentTariff'] == null
          ? null
          : TariffModel.fromJson(
              json['currentTariff'] as Map<String, dynamic>),
      old: json['old'] as int?,
      male: json['male'] as bool?, registrationDate: DateTime.parse(json['registrationDate']),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'login': instance.login,
      'email' : instance.email,
      'password': instance.password,
      'reminderTime': instance.reminderTime,
      'currentTariff': instance.currentTariff,
      'old': instance.old,
      'male': instance.male,
      'registrationDate': instance.registrationDate.toIso8601String()
    };
