import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What [RatingRequestService.maybeRequestReview] actually did — surfaced in
/// debug builds only (via a SnackBar at the call site) since the native
/// review dialog gives no visual feedback on sideloaded/debug installs.
enum RatingRequestOutcome {
  requested,
  skippedMaxCount,
  skippedInterval,
  skippedUnavailable,
}

/// Triggers the native App Store / Google Play in-app review prompt after a
/// warm moment (the strengths-quiz result screen), throttled locally since
/// neither platform reports whether the dialog actually appeared or what the
/// user chose — see [maybeRequestReview] for the exact rules.
class RatingRequestService {
  static const _lastRequestKey = 'rating_request_last_timestamp';
  static const _requestCountKey = 'rating_request_count';

  static const _minInterval = Duration(days: 90);
  static const _maxLifetimeRequests = 4;

  /// Calls the native review prompt if the local throttle allows it.
  /// Always records the attempt (not a confirmed display — the platform
  /// APIs never tell us that) so the interval/count limits stay accurate.
  static Future<RatingRequestOutcome> maybeRequestReview() async {
    final prefs = await SharedPreferences.getInstance();

    final count = prefs.getInt(_requestCountKey) ?? 0;
    if (count >= _maxLifetimeRequests) return RatingRequestOutcome.skippedMaxCount;

    final lastMillis = prefs.getInt(_lastRequestKey);
    if (lastMillis != null) {
      final since = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastMillis),
      );
      if (since < _minInterval) return RatingRequestOutcome.skippedInterval;
    }

    final inAppReview = InAppReview.instance;
    if (!await inAppReview.isAvailable()) return RatingRequestOutcome.skippedUnavailable;

    await prefs.setInt(_lastRequestKey, DateTime.now().millisecondsSinceEpoch);
    await prefs.setInt(_requestCountKey, count + 1);

    await inAppReview.requestReview();
    return RatingRequestOutcome.requested;
  }

  /// Debug-only: clears the throttle so the flow can be re-tested without
  /// waiting 90 days. Wired to a 🧪-prefixed Settings entry, kDebugMode-gated.
  static Future<void> debugResetThrottle() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastRequestKey);
    await prefs.remove(_requestCountKey);
  }
}
