import '../../utils/shared_prefs.dart';

/// Tracks "not helpful" feedback on a dashboard insight so the same finding
/// doesn't keep repeating right after the user dismisses it. A soft
/// cooldown, not a permanent hide — the underlying data pattern may still
/// be real and worth resurfacing once the cooldown passes.
class DashboardFeedbackStore {
  static const _prefix = 'dashboard_feedback_';
  static const cooldownDays = 14;

  static bool isSuppressed(String signature) {
    final ts = SharedPrefs.sharedPreferences.getInt('$_prefix$signature');
    if (ts == null) return false;
    final markedAt = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(markedAt).inDays < cooldownDays;
  }

  static Future<void> markNotHelpful(String signature) async {
    await SharedPrefs.sharedPreferences.setInt('$_prefix$signature', DateTime.now().millisecondsSinceEpoch);
  }
}
