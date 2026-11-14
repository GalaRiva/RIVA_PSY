import 'package:shared_preferences/shared_preferences.dart';

// Start time of the 24h welcome offer for someone WITHOUT an account.
//
// The offer is anchored to when the strengths quiz was finished. Registered
// users keep it in Firestore (Users/{id}.quiz_completed_at). But the app is
// anonymous-first: at the end of the quiz there is usually no account, so
// userId() is empty, the Firestore write was skipped, and the "-70%" banner on
// the main screen could never appear. This keeps the same moment on the phone
// as a fallback. The first value wins, so finishing the quiz again does not
// restart the 24 hours. The discount itself is still decided by the app, and
// Google Play only applies the "welcome70" offer that the app asks for.
class QuizOfferAnchor {
  static const String _key = 'quiz_completed_at_local';

  static Future<void> saveLocalIfAbsent(DateTime at) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_key) == null) {
        await prefs.setString(_key, at.toIso8601String());
      }
    } catch (_) {}
  }

  static Future<DateTime?> loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      return raw == null ? null : DateTime.tryParse(raw);
    } catch (_) {
      return null;
    }
  }
}
