import 'package:riva_psy/core/models/day_event_model.dart';

extension EmotionInDayEventExtension on EmotionInDayEvent {
  // Returns a translation key, not display text — callers must call
  // .tr() at the point of rendering. Kept as-is where already stable
  // (this is display-only now; JSON persistence uses EmotionInDayEvent.name
  // directly, see day_event_model.g.dart).
  String getEmotionType () {
    switch (this) {
      case EmotionInDayEvent.NEGATIVE:
        return 'negative';
      case EmotionInDayEvent.POSITIVE:
        return 'positive';
      default:
        return 'neutral';
    }
  }
}