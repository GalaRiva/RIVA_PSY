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

  const AppAudioTrack({
    required this.id,
    required this.url,
    required this.title,
    this.coverAsset,
    this.coverUrl,
  });

  factory AppAudioTrack.forUrl(String url, {required String title, String? coverAsset, String? coverUrl}) {
    return AppAudioTrack(id: url, url: url, title: title, coverAsset: coverAsset, coverUrl: coverUrl);
  }
}
