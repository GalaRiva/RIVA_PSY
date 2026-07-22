import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/day_event_model.dart';

extension StringExtension on String {
  String md5() {
    return generateMd5(this);
  }

  String t () {
    return this.tr();
  }

  EmotionInDayEvent getEmotionTypeFromString () {
    switch (this) {
      case 'Негативные':
        return EmotionInDayEvent.NEGATIVE;
      case 'Позитивные':
        return EmotionInDayEvent.POSITIVE;
      default:
        return EmotionInDayEvent.NEUTRAL;
    }
  }

}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}
