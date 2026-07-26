import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Looks up the canonical Russian display text for a stable entity `key`
/// (e.g. an emotion key like 'anger_rage' or 'doubt_positive'), read
/// directly from assets/translations/ru-RU.json — independent of the app's
/// currently active UI locale.
///
/// Why this exists: easy_localization 3.0.8 has no API to translate under a
/// specific locale without switching the globally active one — `tr()` and
/// `Localization` are backed by a single-locale singleton (see
/// easy_localization-3.0.8/lib/src/localization.dart: one `_locale` and one
/// `_translations` field, no per-call locale override). Some external data
/// (e.g. Firestore's `Audio.emotions` field, used to pick recommended audio
/// after a negative-emotion Path — see
/// presentation/main/path/path_final_screen/widgets/exercise_content/controller.dart)
/// is still tagged with Russian emotion names rather than stable keys, and
/// needs matching against a *fixed* Russian form regardless of the user's
/// current app language or whichever locale their Hive data happened to be
/// seeded in.
///
/// Reading ru-RU.json directly (instead of hardcoding a parallel Dart map)
/// keeps the JSON file the single source of truth — nothing here can drift
/// out of sync with the translations.
class RuCanonicalName {
  static Map<String, dynamic>? _cache;

  static Future<String?> forKey(String? key) async {
    if (key == null) return null;
    _cache ??= jsonDecode(
        await rootBundle.loadString('assets/translations/ru-RU.json'));
    final value = _cache![key];
    return value is String ? value : null;
  }
}
