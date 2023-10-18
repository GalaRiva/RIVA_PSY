import 'package:listenmebaby71_s_application17/core/models/day_event_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'spent_record_model.g.dart';
@JsonSerializable()
class SpentRecordModel {
  final DayEventModel dayEventModel;
  final String whyThisThoughts;
  final String alternativeThoughts;
  final String whyThisDo;
  final String alternativeDo;

  SpentRecordModel(
      {required this.dayEventModel,
      required this.whyThisThoughts,
      required this.alternativeThoughts,
      required this.whyThisDo,
      required this.alternativeDo});

  factory SpentRecordModel.fromJson (Map<String, dynamic> json) => _$SpentRecordModelFromJson(json);
  Map<String,dynamic> toJson() => _$SpentRecordModelToJson(this);

  @override
  int compareTo(SpentRecordModel other) {
    return dayEventModel.date!.compareTo(other.dayEventModel.date!);
  }
}
