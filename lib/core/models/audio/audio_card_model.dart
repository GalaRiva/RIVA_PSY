class AudioCardModel {
  final String title;
  final String audioAsset;
  // Audio.name — the raw Russian field, stable across locales — kept
  // alongside the already-localized `title` so cover art (named after the
  // Russian track title) can still be matched when the display locale
  // isn't Russian.
  final String? ruTitle;

  AudioCardModel(this.title, this.audioAsset, {this.ruTitle});
}