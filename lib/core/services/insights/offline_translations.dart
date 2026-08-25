import 'dart:convert';

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
  static Future<Map<String, dynamic>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final localeTag = (prefs.getString('locale') ?? 'ru_RU').replaceAll('_', '-');
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
