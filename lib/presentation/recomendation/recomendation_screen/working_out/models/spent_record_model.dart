import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'spent_record_model.g.dart';
@JsonSerializable()
class SpentRecordModel {
  final DayEventModel dayEventModel;
  final String whyThisThoughts;
  final String alternativeThoughts;
  final String whyThisDo;
  final String alternativeDo;
  final DateTime date;
  // Cognitive-distortion keys the user marked as present in this thought —
  // optional, stable slugs (see CognitiveDistortion.all), not free text.
  final List<String>? cognitiveDistortions;

  SpentRecordModel(
      {required this.dayEventModel,
      required this.whyThisThoughts,
      required this.alternativeThoughts,
      required this.whyThisDo,
      required this.alternativeDo,
        required this.date, this.cognitiveDistortions, });

  factory SpentRecordModel.fromJson (Map<String, dynamic> json) => _$SpentRecordModelFromJson(json);
  Map<String,dynamic> toJson() => _$SpentRecordModelToJson(this);

  @override
  int compareTo(SpentRecordModel other) {
    return dayEventModel.date!.compareTo(other.dayEventModel.date!);
  }

  SpentRecordModel copyWith({
    DayEventModel? dayEventModel,
    String? whyThisThoughts,
    String? alternativeThoughts,
    String? whyThisDo,
    String? alternativeDo,
    List<String>? cognitiveDistortions,
  }) {
    return SpentRecordModel(
      dayEventModel: dayEventModel ?? this.dayEventModel,
      whyThisThoughts: whyThisThoughts ?? this.whyThisThoughts,
      alternativeThoughts: alternativeThoughts ?? this.alternativeThoughts,
      whyThisDo: whyThisDo ?? this.whyThisDo,
      alternativeDo: alternativeDo ?? this.alternativeDo, date: this.date,
      cognitiveDistortions: cognitiveDistortions ?? this.cognitiveDistortions,
    );
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return other is SpentRecordModel && dayEventModel == other.dayEventModel;
  }
}
