import 'package:shared_preferences/shared_preferences.dart';

// Plain class instead of a Dart 3 record — this project's SDK constraint
// (pubspec.yaml: '>=2.12.0 <3.0.0') predates record syntax.
class InsightPopupContent {
  final String title;
  final String body;
  const InsightPopupContent(this.title, this.body);
}

/// Persists the most recent nightly-insight notification's title/body so the
/// user can still see it once from inside the app if they swipe the
/// notification away without reading it — mirrors [GratitudeNudgeStore].
class InsightPopupStore {
  static const _titleKey = 'last_insight_popup_title';
  static const _bodyKey = 'last_insight_popup_body';
  static const _seenKey = 'last_insight_popup_seen';

  static Future<void> save(String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_titleKey, title);
    await prefs.setString(_bodyKey, body);
    await prefs.setBool(_seenKey, false);
  }

  /// Returns the last title/body exactly once — same "read marks it seen"
  /// behavior as [GratitudeNudgeStore.consumeUnseen].
  static Future<InsightPopupContent?> consumeUnseen() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seenKey) ?? true) return null;
    final title = prefs.getString(_titleKey);
    final body = prefs.getString(_bodyKey);
    await prefs.setBool(_seenKey, true);
    if (title == null || body == null) return null;
    return InsightPopupContent(title, body);
  }
}
