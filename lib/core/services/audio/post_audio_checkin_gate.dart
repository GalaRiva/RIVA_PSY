/// Caps the post-meditation mood check-in to once per app session. In-memory
/// only, on purpose — it resets naturally on a cold start, no persistence
/// needed for "once per session" semantics.
class PostAudioCheckinGate {
  static bool _shown = false;

  static bool get canShow => !_shown;

  static void markShown() => _shown = true;
}
