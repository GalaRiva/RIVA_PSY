// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'desire.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Desire _$DesireFromJson(Map<String, dynamic> json) {
  return _Desire.fromJson(json);
}

/// @nodoc
mixin _$Desire {
  String get simpleDesires => throw _privateConstructorUsedError;
  String get desireDetails => throw _privateConstructorUsedError;
  DateTime get dateOfExecution => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DesireCopyWith<Desire> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DesireCopyWith<$Res> {
  factory $DesireCopyWith(Desire value, $Res Function(Desire) then) =
      _$DesireCopyWithImpl<$Res, Desire>;
  @useResult
  $Res call(
      {String simpleDesires,
      String desireDetails,
      DateTime dateOfExecution,
      DateTime createdAt,
      bool completed});
}

/// @nodoc
class _$DesireCopyWithImpl<$Res, $Val extends Desire>
    implements $DesireCopyWith<$Res> {
  _$DesireCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? simpleDesires = null,
    Object? desireDetails = null,
    Object? dateOfExecution = null,
    Object? createdAt = null,
    Object? completed = null,
  }) {
    return _then(_value.copyWith(
      simpleDesires: null == simpleDesires
          ? _value.simpleDesires
          : simpleDesires // ignore: cast_nullable_to_non_nullable
              as String,
      desireDetails: null == desireDetails
          ? _value.desireDetails
          : desireDetails // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfExecution: null == dateOfExecution
          ? _value.dateOfExecution
          : dateOfExecution // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DesireImplCopyWith<$Res> implements $DesireCopyWith<$Res> {
  factory _$$DesireImplCopyWith(
          _$DesireImpl value, $Res Function(_$DesireImpl) then) =
      __$$DesireImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String simpleDesires,
      String desireDetails,
      DateTime dateOfExecution,
      DateTime createdAt,
      bool completed});
}

/// @nodoc
class __$$DesireImplCopyWithImpl<$Res>
    extends _$DesireCopyWithImpl<$Res, _$DesireImpl>
    implements _$$DesireImplCopyWith<$Res> {
  __$$DesireImplCopyWithImpl(
      _$DesireImpl _value, $Res Function(_$DesireImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? simpleDesires = null,
    Object? desireDetails = null,
    Object? dateOfExecution = null,
    Object? createdAt = null,
    Object? completed = null,
  }) {
    return _then(_$DesireImpl(
      simpleDesires: null == simpleDesires
          ? _value.simpleDesires
          : simpleDesires // ignore: cast_nullable_to_non_nullable
              as String,
      desireDetails: null == desireDetails
          ? _value.desireDetails
          : desireDetails // ignore: cast_nullable_to_non_nullable
              as String,
      dateOfExecution: null == dateOfExecution
          ? _value.dateOfExecution
          : dateOfExecution // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      completed: null == completed
          ? _value.completed
          : completed // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DesireImpl extends _Desire {
  const _$DesireImpl(
      {required this.simpleDesires,
      required this.desireDetails,
      required this.dateOfExecution,
      required this.createdAt,
      required this.completed})
      : super._();

  factory _$DesireImpl.fromJson(Map<String, dynamic> json) =>
      _$$DesireImplFromJson(json);

  @override
  final String simpleDesires;
  @override
  final String desireDetails;
  @override
  final DateTime dateOfExecution;
  @override
  final DateTime createdAt;
  @override
  final bool completed;

  @override
  String toString() {
    return 'Desire(simpleDesires: $simpleDesires, desireDetails: $desireDetails, dateOfExecution: $dateOfExecution, createdAt: $createdAt, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DesireImpl &&
            (identical(other.simpleDesires, simpleDesires) ||
                other.simpleDesires == simpleDesires) &&
            (identical(other.desireDetails, desireDetails) ||
                other.desireDetails == desireDetails) &&
            (identical(other.dateOfExecution, dateOfExecution) ||
                other.dateOfExecution == dateOfExecution) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, simpleDesires, desireDetails,
      dateOfExecution, createdAt, completed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DesireImplCopyWith<_$DesireImpl> get copyWith =>
      __$$DesireImplCopyWithImpl<_$DesireImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DesireImplToJson(
      this,
    );
  }
}

abstract class _Desire extends Desire {
  const factory _Desire(
      {required final String simpleDesires,
      required final String desireDetails,
      required final DateTime dateOfExecution,
      required final DateTime createdAt,
      required final bool completed}) = _$DesireImpl;
  const _Desire._() : super._();

  factory _Desire.fromJson(Map<String, dynamic> json) = _$DesireImpl.fromJson;

  @override
  String get simpleDesires;
  @override
  String get desireDetails;
  @override
  DateTime get dateOfExecution;
  @override
  DateTime get createdAt;
  @override
  bool get completed;
  @override
  @JsonKey(ignore: true)
  _$$DesireImplCopyWith<_$DesireImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
