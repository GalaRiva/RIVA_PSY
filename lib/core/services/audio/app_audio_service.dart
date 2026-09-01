import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'app_audio_track.dart';
import 'audio_cache_manager.dart';

// Immutable snapshot of "what's playing right now" — the single source of
// truth any screen's UI (a full player, a mini-player bar, eventually a
// lock-screen notification) reads from instead of owning its own player
// state. `track == null` means nothing has been played yet this session.
@immutable
class AppAudioState {
  final AppAudioTrack? track;
  final bool playing;
  final Duration position;
  final Duration duration;

  const AppAudioState({
    this.track,
    this.playing = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  AppAudioState copyWith({
    AppAudioTrack? track,
    bool? playing,
    Duration? position,
    Duration? duration,
  }) {
    return AppAudioState(
      track: track ?? this.track,
      playing: playing ?? this.playing,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  bool isCurrent(String trackId) => track?.id == trackId;
}

// The one shared player for all "content" audio in the app (negative
// emotions, guided journals, Проекция Я, meditations, relax dialog, ...) —
// deliberately NOT used for voice-note recording/playback
// (record_edit_screen), which is a separate concern. Created lazily on
// first use, not at app startup, so it costs nothing until something
// actually plays.
//
// Every screen should call `AppAudioService.instance.play(track)` instead
// of creating its own `AudioPlayer()` — that's what makes "only one thing
// plays at a time" and (later) lock-screen controls possible without
// touching every call site again. See PROJECT_CONTEXT.md / the
// project_unified_audio_player_plan memory for the full rationale.
class AppAudioService {
  AppAudioService._();
  static final AppAudioService instance = AppAudioService._();

  AudioPlayer? _player;
  bool _sessionConfigured = false;

  final ValueNotifier<AppAudioState> state = ValueNotifier(const AppAudioState());

  AudioPlayer get _p {
    final existing = _player;
    if (existing != null) return existing;
    final created = AudioPlayer();
    _player = created;
    _wire(created);
    return created;
  }

  void _wire(AudioPlayer player) {
    if (!_sessionConfigured) {
      _sessionConfigured = true;
      AudioSession.instance.then((session) => session.configure(const AudioSessionConfiguration.speech()));
    }
    // Never cancelled — this player (and these subscriptions) live for the
    // whole app process, same as the singleton itself.
    player.playerStateStream.listen((playerState) {
      state.value = state.value.copyWith(playing: playerState.playing);
      if (playerState.processingState == ProcessingState.completed) {
        player.seek(Duration.zero);
        player.pause();
        state.value = state.value.copyWith(playing: false, position: Duration.zero);
      }
    });
    player.positionStream.listen((pos) {
      state.value = state.value.copyWith(position: pos);
    });
    player.durationStream.listen((d) {
      if (d != null) state.value = state.value.copyWith(duration: d);
    });
  }

  /// Starts playing [track]. If it's already the current track, this just
  /// resumes/seeks instead of reloading it. Otherwise it replaces whatever
  /// was playing — a new track always stops the previous one, since only
  /// one thing can play app-wide at a time by design.
  Future<void> play(AppAudioTrack track, {Duration? initialPosition}) async {
    final player = _p;
    if (state.value.isCurrent(track.id)) {
      if (initialPosition != null) await player.seek(initialPosition);
      await player.play();
      return;
    }
    state.value = AppAudioState(track: track, playing: false, position: initialPosition ?? Duration.zero);
    final source = await AudioCacheManager.sourceFor(track.url);
    await player.setAudioSource(source, initialPosition: initialPosition ?? Duration.zero);
    await player.play();
  }

  Future<void> pause() => _p.pause();

  Future<void> resume() => _p.play();

  Future<void> togglePlayPause() => state.value.playing ? pause() : resume();

  Future<void> seek(Duration position) => _p.seek(position);

  Future<void> stop() async {
    await _player?.stop();
    state.value = const AppAudioState();
  }

  bool isCurrent(String trackId) => state.value.isCurrent(trackId);
}
