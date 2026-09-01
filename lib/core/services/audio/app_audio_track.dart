// One playable "content" track — the shape AppAudioService and any screen's
// UI agree on. `id` is the track's stable identity (the resolved URL is
// used everywhere else in the app as the de-facto unique key, so reusing
// it here avoids inventing a second id scheme). `coverAsset`/`coverUrl`
// are both optional and mutually exclusive in practice — a bundled local
// asset (audioCoverAssets) or an R2-hosted cover (Guided Journals), never
// both — and both are allowed to be absent (most tracks today have no
// cover at all).
class AppAudioTrack {
  final String id;
  final String url;
  final String title;
  final String? coverAsset;
  final String? coverUrl;

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
    this.nextUrl,
  });

  factory AppAudioTrack.forUrl(String url,
      {required String title, String? coverAsset, String? coverUrl, String? nextUrl}) {
    return AppAudioTrack(
        id: url, url: url, title: title, coverAsset: coverAsset, coverUrl: coverUrl, nextUrl: nextUrl);
  }
}
