import 'package:listenmebaby71_s_application17/core/models/day_event_model.dart';

extension EmotionInDayEventExtension on EmotionInDayEvent {
  String getEmotionType () {
    switch (this) {
      case EmotionInDayEvent.NEGATIVE:
        return 'Негативные';
      case EmotionInDayEvent.POSITIVE:
        return 'Позитивные';
      default:
        return 'Нейтральные';
    }
  }
}