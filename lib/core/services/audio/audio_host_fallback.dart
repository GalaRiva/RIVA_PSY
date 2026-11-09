import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Audio lives on Cloudflare R2 (free egress). In Spain, operators block the
// shared Cloudflare IPs behind the r2.dev host during/around LaLiga matches
// (see docs/audio-fallback.md), which leaves every track stuck at 00:00.
// This class decides, per track, which host to stream from:
//
//  * R2 is always the primary host.
//  * Before streaming an uncached track we do one tiny Range request (1 byte)
//    to R2. If it times out / fails at network level / answers 5xx, R2 is
//    treated as blocked for [blockWindow] (30 min) and tracks come from the
//    Firebase Storage mirror instead (paid egress, so used only when needed).
//  * When the window ends the next track probes R2 again; a new failure
//    starts a new 30-minute window. A healthy R2 is not re-probed for
//    [_healthyFor] so normal listening pays no extra latency.
//
// Every use of the fallback host writes one anonymous event to Firestore
// (`AudioFallbackEvents`: time, track path, kind, reason, platform, locale —
// no user id, no device id) so the cost of the mirror can be watched.
class AudioHostFallback {
  static const r2Base =
      'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';
  static const fallbackBase =
      'https://storage.googleapis.com/rigel-psy-9361c.firebasestorage.app/audio/';

  static const blockWindow = Duration(minutes: 30);
  static const _healthyFor = Duration(minutes: 5);
  static const _probeTimeout = Duration(seconds: 4);
  static const _blockedKey = 'audio_r2_blocked_until_ms';
  static const _eventsCollection = 'AudioFallbackEvents';

  static int _blockedUntilMs = 0;
  static int _healthyUntilMs = 0;
  static bool _loaded = false;
  static String _locale = 'ru';

  static Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      _blockedUntilMs = prefs.getInt(_blockedKey) ?? 0;
      _locale = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
    } catch (_) {}
  }

  static Future<void> _saveBlockedUntil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_blockedKey, _blockedUntilMs);
    } catch (_) {}
  }

  /// The URL to actually fetch for [url]. Anything that is not an R2 audio
  /// URL is returned untouched. [kind] is only used for the usage log:
  /// 'play', 'prefetch' or 'duration'.
  static Future<String> resolve(String url, {String kind = 'play'}) async {
    if (!url.startsWith(r2Base)) return url;
    await _load();
    final now = DateTime.now().millisecondsSinceEpoch;

    if (now < _blockedUntilMs) {
      _log(url, kind, 'window');
      return _toFallback(url);
    }
    if (now < _healthyUntilMs) return url;

    if (await _r2Reachable(url)) {
      _healthyUntilMs = now + _healthyFor.inMilliseconds;
      return url;
    }
    _blockedUntilMs = now + blockWindow.inMilliseconds;
    _healthyUntilMs = 0;
    unawaited(_saveBlockedUntil());
    _log(url, kind, 'probe_failed');
    return _toFallback(url);
  }

  static String _toFallback(String url) =>
      fallbackBase + url.substring(r2Base.length);

  // One byte of the track itself, so a per-object problem is caught too.
  // 404 counts as "reachable" (the file is missing, the host is not blocked).
  static Future<bool> _r2Reachable(String url) async {
    final client = HttpClient()..connectionTimeout = _probeTimeout;
    try {
      final request =
          await client.getUrl(Uri.parse(url)).timeout(_probeTimeout);
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-0');
      final response = await request.close().timeout(_probeTimeout);
      await response.drain<void>().timeout(_probeTimeout);
      final code = response.statusCode;
      return code < 400 || code == 404;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  static void _log(String url, String kind, String reason) {
    try {
      var path = url.substring(r2Base.length);
      try {
        path = Uri.decodeFull(path);
      } catch (_) {}
      if (path.length > 200) path = path.substring(0, 200);
      unawaited(FirebaseFirestore.instance.collection(_eventsCollection).add({
        'ts': FieldValue.serverTimestamp(),
        'path': path,
        'kind': kind,
        'reason': reason,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'locale': _locale,
      }).then<void>((_) {}, onError: (_) {}));
    } catch (_) {}
  }
}
