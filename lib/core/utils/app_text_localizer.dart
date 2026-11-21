import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:easy_localization/easy_localization.dart' show StringTranslateExtension;
import 'package:flutter/foundation.dart' show visibleForTesting;

// Texts the app itself writes into the diary (a course name as a "place", the
// name of a scale as an "emotion", "Моя динамика" as the "event") are stored as
// plain text in the language that was on at that moment. When the person later
// switches the language they would stay in the old one, e.g. Russian words in the
// Spanish Energy Matrix. This keeps one table of every known wording of such
// texts (all app translations and all course texts) and shows the one for the
// language that is on now. A person's own words never match, so they are never
// touched.
class AppTextLocalizer {
  // any known wording -> {lang: wording}
  static final Map<String, Map<String, String>> _group = {};
  static bool _ready = false;
  static Future<void>? _loading;

  static Future<void> init() => _loading ??= _load();

  static void _add(Map<String, String> g) {
    final clean = {for (final e in g.entries) if (e.value.trim().isNotEmpty) e.key: e.value.trim()};
    if (clean.length < 2) return;
    for (final v in clean.values) {
      _group.putIfAbsent(v, () => clean);
    }
  }

  static Future<void> _load() async {
    try {
      Map<String, dynamic> read(String raw) => jsonDecode(raw) as Map<String, dynamic>;
      final ru = read(await rootBundle.loadString('assets/translations/ru-RU.json'));
      final en = read(await rootBundle.loadString('assets/translations/en-US.json'));
      final es = read(await rootBundle.loadString('assets/translations/es-ES.json'));
      for (final k in ru.keys) {
        final r = ru[k], e = en[k], s = es[k];
        if (r is String && r.length <= 120) {
          _add({'ru': r, if (e is String) 'en': e, if (s is String) 'es': s});
        }
      }
      final index = read(await rootBundle.loadString('assets/courses/index.json'));
      for (final id in (index['courses'] as List)) {
        try {
          _walk(jsonDecode(await rootBundle.loadString('assets/courses/$id.json')));
        } catch (_) {}
      }
      _ready = true;
    } catch (_) {
      _ready = true;
    }
  }

  static void _walk(dynamic o) {
    if (o is Map) {
      if (o.containsKey('ru') && o.values.every((v) => v is String)) {
        _add({for (final e in o.entries) e.key as String: e.value as String});
        return;
      }
      for (final v in o.values) {
        _walk(v);
      }
    } else if (o is List) {
      for (final v in o) {
        _walk(v);
      }
    }
  }

  @visibleForTesting
  static String? debugLang;

  // The language that is on now. easy_localization has no public "current
  // language" outside a widget, so every translation file carries its own code.
  static String get _lang {
    if (debugLang != null) return debugLang!;
    final c = 'app_lang_code'.tr();
    return c.length == 2 ? c : 'ru';
  }

  /// [text] in the language that is on now, when it is a known app wording;
  /// otherwise [text] unchanged. Works on "A · B" combinations part by part.
  static String of(String text) {
    if (!_ready || text.isEmpty) return text;
    String one(String t) {
      final g = _group[t.trim()];
      return g == null ? t : (g[_lang] ?? t);
    }

    if (text.contains(' · ')) return text.split(' · ').map(one).join(' · ');
    return one(text);
  }
}
