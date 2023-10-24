import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/models/event_model.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

import '../../presentation/main/path/what_body_parts_screen/k32_model.dart';
import 'body_parts_model.dart';

part 'generated/day_event_model.g.dart';

@JsonSerializable()
class DayEventModel implements Comparable<DayEventModel>{
  int? howDoYouFeel;
  DateTime? date;
  EventModel? whatHappened;
  EventModel? whereHappened;
  EventModel? whoDidItHappen;
  List<EventModel>? whatEmotion;
  List<K32Model>? whatBodyParts;
  int emotionIntensity;
  String? whatIDo;
  String? firstThoughts;
  String? pathToAudio;
  bool workingOut;
  EmotionInDayEvent? emotionInDayEvent = EmotionInDayEvent.NEGATIVE;
  DayEventModel(
      {this.howDoYouFeel,
      this.whatHappened,
      this.whereHappened,
      this.whoDidItHappen,
      this.whatEmotion,
      this.emotionIntensity = 10,
      this.whatIDo,
      this.whatBodyParts,
      this.firstThoughts,
      this.date,
      this.pathToAudio,
      this.workingOut = false
      });

  DayEventModel copyWith({
    int? howDoYouFeel,
    EventModel? whatHappened,
    EventModel? whereHappened,
    EventModel? whoDidItHappen,
    List<EventModel>? whatEmotion,
    List<K32Model>? whatBodyParts,
    int? emotionIntensity,
    String? whatIDo,
    String? firstThoughts,
    DateTime? date,
    String? pathToAudio,
    bool? workingOut,
    EmotionInDayEvent? emotionInDayEvent,
  }) {
    return DayEventModel(
      howDoYouFeel: howDoYouFeel ?? this.howDoYouFeel,
      whatHappened: whatHappened ?? this.whatHappened,
      whereHappened: whereHappened ?? this.whereHappened,
      whoDidItHappen: whoDidItHappen ?? this.whoDidItHappen,
      whatEmotion: whatEmotion ?? this.whatEmotion,
      whatBodyParts: whatBodyParts ?? this.whatBodyParts,
      emotionIntensity: emotionIntensity ?? this.emotionIntensity,
      whatIDo: whatIDo ?? this.whatIDo,
      firstThoughts: firstThoughts ?? this.firstThoughts,
      date: date ?? this.date,
      pathToAudio: pathToAudio ?? this.pathToAudio,
      workingOut: workingOut ?? this.workingOut,
    )..emotionInDayEvent = emotionInDayEvent ?? this.emotionInDayEvent;
  }

  factory DayEventModel.fromJson(Map<String, dynamic> json) =>
      _$DayEventModelFromJson(json);

  Map<String, dynamic> toJson() => _$DayEventModelToJson(this);

  String getEmotionType () {
    switch (emotionInDayEvent) {
      case EmotionInDayEvent.NEGATIVE:
        return 'Негативные';
      case EmotionInDayEvent.POSITIVE:
        return 'Позитивные';
      default:
        return 'Нейтральны';
    }
  }

  static DayEventModel defaultModel = DayEventModel(
      howDoYouFeel: 6,
      date: DateTime.now(),
      whatHappened: EventModel(
        'a',
        ImageConstant.eventPlace2,
      ),
      whereHappened: EventModel(
        'a',
        ImageConstant.eventPlace2,
      ),
      whoDidItHappen: EventModel(
        'a',
        ImageConstant.eventPlace2,
      ),
      whatEmotion: [
        EventModel(
          'a',
          ImageConstant.eventPlace2,
        )
      ],
      emotionIntensity: 5,
      whatIDo: '',
      whatBodyParts: [
        K32Model(BodyPartsModel(bodyPart: 'a', whatHurts: ['a']), 'aa')
      ],
      firstThoughts: '');

  @override
  int compareTo(DayEventModel other) {
    return date!.compareTo(other.date!);
  }

  @override
  bool operator ==(Object other) {
    // TODO: implement ==
    return super == other && date != null && (other as DayEventModel).date == date;
  }
}

enum EmotionInDayEvent {
  POSITIVE,
  NEGATIVE,
  NEUTRAL
}