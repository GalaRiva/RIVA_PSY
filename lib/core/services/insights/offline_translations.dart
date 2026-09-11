import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads the bundled translation JSON directly instead of going through
/// easy_localization's `.tr()`. That call resolves through
/// `Localization.instance`, a package-private singleton (lib/src/, not
/// exported) normally populated by the `EasyLocalization` widget during app
/// startup. This is also used from the workmanager background isolate (see
/// insight_workmanager.dart), which never builds that widget tree, so
/// `.tr()` would have nothing to resolve against — this works identically
/// in both places.
class OfflineTranslations {
  static const _supportedByLanguageCode = {
    'ru': 'ru-RU',
    'en': 'en-US',
    'es': 'es-ES',
  };

  static Future<Map<String, dynamic>> load() async {
    // The SharedPreferences 'locale' key is the app's actual language
    // choice: main.dart seeds it once from the phone's system language on
    // first launch, and LanguagesPage/EasyLocalization.setLocale() overwrites
    // it every time the user picks a language in-app (see
    // EasyLocalizationController._saveLocale). So reading it here means
    // notifications default to the phone's language and then follow
    // whatever the user explicitly chose in the app — which is what should
    // happen. Falling back to Platform.localeName only covers the
    // never-actually-happens case of this running before main.dart's seed.
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('locale');
    final languageCode = (savedLocale?.split(RegExp('[_-]')).first ??
            Platform.localeName.split(RegExp('[_-]')).first)
        .toLowerCase();
    final localeTag = _supportedByLanguageCode[languageCode] ?? 'en-US';
    try {
      final jsonStr = await rootBundle.loadString('assets/translations/$localeTag.json');
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      final jsonStr = await rootBundle.loadString('assets/translations/ru-RU.json');
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    }
  }

  static String tr(Map<String, dynamic> translations, String key,
      [Map<String, String> namedArgs = const {}]) {
    var value = translations[key] as String? ?? key;
    namedArgs.forEach((name, arg) {
      value = value.replaceAll('{$name}', arg);
    });
    return value;
  }

  /// Breaks a notification body into one sentence per line — sentence-ending
  /// punctuation (.!?) followed by whitespace becomes a line break, so a
  /// multi-sentence insight/nudge reads as short lines in the notification
  /// shade instead of one dense paragraph. Language-agnostic (RU/EN/ES all
  /// end sentences the same way), so it works on the already-`tr()`'d text
  /// regardless of locale.
  static String toSentenceLines(String text) {
    return text
        .split(RegExp(r'(?<=[.!?])\s+(?=\S)'))
        .where((s) => s.trim().isNotEmpty)
        .join('\n');
  }
}
