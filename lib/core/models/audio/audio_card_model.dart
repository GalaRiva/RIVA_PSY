class AudioCardModel {
  final String title;
  final String audioAsset;
  // Audio.name — the raw Russian field, stable across locales — kept
  // alongside the already-localized `title` so cover art (named after the
  // Russian track title) can still be matched when the display locale
  // isn't Russian.
  final String? ruTitle;
  // Precomputed from Firestore (Audio.duration_ms) when available, so the
  // negative-emotion tabs don't need a live network probe per track just
  // to show a running time — see Audio.localizedDuration.
  final Duration? knownDuration;

  AudioCardModel(this.title, this.audioAsset, {this.ruTitle, this.knownDuration});
}