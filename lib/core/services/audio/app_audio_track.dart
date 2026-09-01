import 'package:flutter/widgets.dart' show WidgetBuilder;

// One playable "content" track — the shape AppAudioService and any screen's
// UI agree on. `id` is the track's stable identity (the resolved URL is
// used everywhere else in the app as the de-facto unique key, so reusing
// it here avoids inventing a second id scheme). `coverAsset`/`coverUrl`/
// `coverBuilder` are mutually exclusive in practice — a bundled local
// image (audioCoverAssets), an R2-hosted cover (Guided Journals), or a
// live animated cover (animatedAudioCovers, e.g. the heart-congruence
// meditation) — never more than one, and all three are allowed to be
// absent (most tracks today have no cover at all).
class AppAudioTrack {
  final String id;
  final String url;
  final String title;
  final String? coverAsset;
  final String? coverUrl;
  final WidgetBuilder? coverBuilder;

  // Optional — when a screen knows what comes after this track in its own
  // list, AppAudioService.play() warms this URL's disk cache in the
  // background once this track starts, so advancing to it doesn't hit a
  // network wait (same idea as Spotify preloading the next queued song).
  final String? nextUrl;

  const AppAudioTrack({
    required this.id,
    required this.url,
    required this.title,
    this.coverAsset,
    this.coverUrl,
    this.coverBuilder,
    this.nextUrl,
  });

  factory AppAudioTrack.forUrl(String url,
      {required String title,
      String? coverAsset,
      String? coverUrl,
      WidgetBuilder? coverBuilder,
      String? nextUrl}) {
    return AppAudioTrack(
        id: url,
        url: url,
        title: title,
        coverAsset: coverAsset,
        coverUrl: coverUrl,
        coverBuilder: coverBuilder,
        nextUrl: nextUrl);
  }
}
