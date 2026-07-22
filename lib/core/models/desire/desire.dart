
import 'package:freezed_annotation/freezed_annotation.dart';

part 'desire.g.dart';
part 'desire.freezed.dart';


@freezed
class Desire with _$Desire {
  const factory Desire({
    required String simpleDesires,
    required String desireDetails,
    required DateTime dateOfExecution,
    required DateTime createdAt,
    required bool completed

  }) = _Desire;

  const Desire._();

  factory Desire.fromJson(Map<String, Object?> json) => _$DesireFromJson(json);
}