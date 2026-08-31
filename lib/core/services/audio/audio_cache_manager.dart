import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

// Local disk cache for R2-streamed audio — first play streams the file
// while simultaneously writing it to disk (just_audio's own
// LockCachingAudioSource); every later play of the same URL is served
// straight from that file, no network involved. Capped at ~130MB with
// LRU eviction (by last-used time, not download time) so repeat listens
// to a handful of favorite tracks stay instant without the cache growing
// unbounded — see PROJECT_CONTEXT.md for the sizing rationale (catalog is
// ~64 tracks at ~3-8MB each; 130MB comfortably covers what people actually
// replay without trying to hold the whole library).
class AudioCacheManager {
  static const _maxBytes = 130 * 1024 * 1024;

  static Directory? _dirCache;

  static Future<Directory> _cacheDir() async {
    if (_dirCache != null) return _dirCache!;
    final base = await getTemporaryDirectory();
    final dir = Directory('${base.path}/audio_cache');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dirCache = dir;
    return dir;
  }

  static Future<File> _fileFor(String url) async {
    final dir = await _cacheDir();
    final hash = sha1.convert(utf8.encode(url)).toString();
    final path = Uri.parse(url).path;
    final dot = path.lastIndexOf('.');
    final ext = dot == -1 ? '.mp3' : path.substring(dot);
    return File('${dir.path}/$hash$ext');
  }

  /// A caching audio source for [url] — plug straight into
  /// `AudioPlayer.setAudioSource()` in place of `setUrl(url)`. Touches the
  /// cache file's mtime if it already exists, so an already-cached track
  /// counts as freshly used for LRU purposes even on a cold app start.
  static Future<LockCachingAudioSource> sourceFor(String url) async {
    final file = await _fileFor(url);
    if (await file.exists()) {
      unawaited(file.setLastModified(DateTime.now()).catchError((_) {}));
    }
    unawaited(_enforceLimit());
    return LockCachingAudioSource(Uri.parse(url), cacheFile: file);
  }

  /// Opportunistically downloads [url] straight to its cache slot, without
  /// touching just_audio/AudioPlayer at all — used to warm the next track
  /// in a list while the current one plays. A no-op if it's already
  /// cached (the actual `sourceFor` call later will just find the file
  /// present, per `LockCachingAudioSource`'s own cache-hit check) or the
  /// request fails for any reason; never surfaces an error to the caller,
  /// since this is a pure nice-to-have.
  static Future<void> prefetch(String url) async {
    try {
      final file = await _fileFor(url);
      if (await file.exists()) return;
      final partial = File('${file.path}.prefetch');
      final client = HttpClient();
      try {
        final request = await client.getUrl(Uri.parse(url));
        final response = await request.close();
        if (response.statusCode != 200) return;
        final sink = partial.openWrite();
        await response.pipe(sink);
        await sink.close();
        if (await file.exists()) {
          // Lost a race with a real playback download — keep that one.
          await partial.delete();
        } else {
          await partial.rename(file.path);
        }
      } finally {
        client.close();
      }
      unawaited(_enforceLimit());
    } catch (_) {
      // Best-effort only — a failed prefetch just means the next track
      // loads over the network like it always did.
    }
  }

  static Future<void> _enforceLimit() async {
    try {
      final dir = await _cacheDir();
      if (!await dir.exists()) return;
      final entries = <MapEntry<File, FileStat>>[];
      var total = 0;
      await for (final entity in dir.list()) {
        if (entity is! File) continue;
        final stat = await entity.stat();
        total += stat.size;
        entries.add(MapEntry(entity, stat));
      }
      if (total <= _maxBytes) return;
      entries.sort((a, b) => a.value.modified.compareTo(b.value.modified));
      for (final entry in entries) {
        if (total <= _maxBytes) break;
        total -= entry.value.size;
        try {
          await entry.key.delete();
        } catch (_) {}
      }
    } catch (_) {}
  }
}
