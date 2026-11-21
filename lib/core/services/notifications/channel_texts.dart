import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

// Names the Android system shows in Settings > Notifications. They are fixed
// when the channel is registered, outside any widget (and in a background
// isolate), so the language comes from the app's own saved choice, not from
// the phone's.
class ChannelTexts {
  static const _group = {'ru': 'Напоминания', 'en': 'Reminders', 'es': 'Recordatorios'};
  static const _description = {
    'ru': 'Напоминания и подсказки RIVA PSY',
    'en': 'RIVA PSY reminders and nudges',
    'es': 'Recordatorios y sugerencias de RIVA PSY',
  };
  static const _audio = {'ru': 'Аудио', 'en': 'Audio', 'es': 'Audio'};

  static Future<String> languageCode() async {
    String? saved;
    try {
      saved = (await SharedPreferences.getInstance()).getString('locale');
    } catch (_) {}
    final code = (saved ?? Platform.localeName).split(RegExp('[_-]')).first.toLowerCase();
    return _group.containsKey(code) ? code : 'en';
  }

  static Future<String> groupName() async => _group[await languageCode()]!;
  static Future<String> description() async => _description[await languageCode()]!;
  static Future<String> audioChannelName() async => _audio[await languageCode()]!;
}
