import 'package:shared_preferences/shared_preferences.dart';

/// Persists the most recent "spontaneous gratitude" push text so the user
/// can still see it once from inside the app if they swipe the notification
/// away without reading it — local notifications otherwise leave nothing
/// behind once dismissed.
class GratitudeNudgeStore {
  static const _textKey = 'last_gratitude_nudge_text';
  static const _seenKey = 'last_gratitude_nudge_seen';

  static Future<void> save(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textKey, text);
    await prefs.setBool(_seenKey, false);
  }

  /// Returns the last nudge text exactly once — the first read after a new
  /// one is saved marks it seen, so it won't pop up again on the next app
  /// open. Returns null if there's nothing new (already seen, or none yet).
  static Future<String?> consumeUnseen() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_seenKey) ?? true) return null;
    final text = prefs.getString(_textKey);
    await prefs.setBool(_seenKey, true);
    return text;
  }
}
