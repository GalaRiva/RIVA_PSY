import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:vibration/vibration.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../../core/utils/audio_cover_map.dart';
import '../../../../../../widgets/fullscreen_audio_player_screen.dart';
import '../exercise_content/controller.dart';

// "Decoupled Player": the carousel above only shows artwork/mood — track
// controls live in a static block below that never resizes. Swiping just
// changes which card is focused; playback (and the shared audioInstance/
// currentAudioIndex on ExerciseContentController) keeps running in the
// background regardless of what's focused, exactly like the row-based
// AudioCardWidget it replaces for this screen's main practices list.
class HeroAudioCarousel extends StatefulWidget {
  final List<AudioCardModel> audios;
  final ExerciseContentController controller;
  final Color accentColor;

  const HeroAudioCarousel({
    Key? key,
    required this.audios,
    required this.controller,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<HeroAudioCarousel> createState() => _HeroAudioCarouselState();
}

class _HeroAudioCarouselState extends State<HeroAudioCarousel> {
  late final PageController _pageController =
      PageController(viewportFraction: 0.8, initialPage: 0);
  double _page = 0;
  int _focusedIndex = 0;

  int? _activePlayIndex;
  bool _isPlaying = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  List<Duration?> _maxDurations = [];
  bool _durationsLoading = true;

  StreamSubscription? _playerStateSub;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
    _loadDurations();
    _playerStateSub = widget.controller.audioInstance.playerStateStream.listen((playerState) {
      if (!mounted || _activePlayIndex == null) return;
      // Real end-of-track signal from just_audio — the sole source of
      // truth for stopping/resetting (a local wall-clock timer racing
      // against the actual decoded duration was the previous approach and
      // could drift, leaving the UI stuck showing "playing" forever after
      // a track had already finished).
      if (playerState.processingState == ProcessingState.completed) {
        _stopLocalTimer();
        widget.controller.audioInstance.seek(Duration.zero);
        widget.controller.audioInstance.pause();
        setState(() {
          _isPlaying = false;
          _elapsed = Duration.zero;
          _activePlayIndex = null;
        });
        return;
      }
      // Something else (e.g. the "additional emotions" list below, sharing
      // the same audioInstance/currentAudioIndex) took over playback.
      if (widget.controller.audioInstance.playing &&
          widget.controller.currentAudioIndex != _activePlayIndex) {
        _stopLocalTimer();
        setState(() => _isPlaying = false);
      }
    });
  }

  Future<void> _loadDurations() async {
    final list = <Duration?>[];
    for (var item in widget.audios) {
      // Known ahead of time (Audio.duration_ms, precomputed once and
      // stored in Firestore) — skip the network probe entirely.
      if (item.knownDuration != null) {
        list.add(item.knownDuration);
        continue;
      }
      try {
        if (DataSourceService.dataSourceIsRemote()) {
          list.add(await widget.controller.audioInstance.setAudioSource(
              await AudioCacheManager.sourceFor(item.audioAsset),
              initialPosition: Duration.zero, preload: true));
        } else {
          list.add(await widget.controller.audioInstance.setAudioSource(
              AudioSource.file(item.audioAsset),
              initialPosition: Duration.zero));
        }
      } catch (_) {
        list.add(null);
      }
    }
    if (mounted) setState(() { _maxDurations = list; _durationsLoading = false; });
  }

  void _stopLocalTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // Drives the elapsed-time display/progress ring only — actually stopping
  // playback on completion is left entirely to the real
  // ProcessingState.completed event (see initState), since this is just a
  // wall-clock estimate and can drift from the real decoded duration.
  void _startLocalTimer() {
    _stopLocalTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _elapsed = Duration(seconds: _elapsed.inSeconds + 1));
    });
  }

  Future<void> _onPlayTap() async {
    Vibration.vibrate(duration: 50);
    if (_activePlayIndex == _focusedIndex && _isPlaying) {
      await widget.controller.audioInstance.pause();
      _stopLocalTimer();
      setState(() => _isPlaying = false);
    } else if (_activePlayIndex == _focusedIndex && !_isPlaying) {
      widget.controller.currentAudioIndex = _focusedIndex;
      await widget.controller.audioInstance.play();
      _startLocalTimer();
      setState(() => _isPlaying = true);
    } else {
      final asset = widget.audios[_focusedIndex].audioAsset;
      widget.controller.currentAudioIndex = _focusedIndex;
      _activePlayIndex = _focusedIndex;
      _elapsed = Duration.zero;
      if (DataSourceService.dataSourceIsRemote()) {
        await widget.controller.audioInstance.setAudioSource(
            await AudioCacheManager.sourceFor(asset), initialPosition: Duration.zero);
      } else {
        await widget.controller.audioInstance
            .setAudioSource(AudioSource.file(asset), initialPosition: Duration.zero);
      }
      await widget.controller.audioInstance.play();
      _startLocalTimer();
      setState(() => _isPlaying = true);
    }
    widget.controller.update();
    // Pausing just stops in place — only a transition into "playing" opens
    // the full-screen view.
    if (_isPlaying && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullscreenAudioPlayerScreen(
            title: widget.audios[_focusedIndex].title,
            cover: _cover(_focusedIndex),
            audioInstance: widget.controller.audioInstance,
            accentColor: widget.accentColor,
          ),
        ),
      );
    }
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _stopLocalTimer();
    _playerStateSub?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _cover(int index) {
    final ruTitle = widget.audios[index].ruTitle;
    final radius = BorderRadius.circular(28);
    final animatedBuilder = animatedAudioCoverBuilder(ruTitle);
    if (animatedBuilder != null) {
      return ClipRRect(borderRadius: radius, child: animatedBuilder(context));
    }
    final asset = audioCoverAsset(ruTitle);
    if (asset != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.asset(asset, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
      );
    }
    // No dedicated art for this track — a soft accent-colored fallback
    // instead of a broken image or a hard crash.
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.accentColor.withOpacity(0.55),
            widget.accentColor.withOpacity(0.85),
          ],
        ),
      ),
      child: Icon(Icons.music_note_rounded, color: Colors.white.withOpacity(0.85), size: 48),
    );
  }

  @override
  Widget build(BuildContext context) {
    final focusedTrack = widget.audios[_focusedIndex];
    final focusedMax = _focusedIndex < _maxDurations.length
        ? _maxDurations[_focusedIndex] ?? Duration.zero
        : Duration.zero;
    final showingPause = _activePlayIndex == _focusedIndex && _isPlaying;
    final progress = (_activePlayIndex == _focusedIndex && focusedMax.inSeconds > 0)
        ? (_elapsed.inSeconds / focusedMax.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    if (_durationsLoading) {
      return Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(color: widget.accentColor),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: size.width * 0.8,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.audios.length,
            onPageChanged: (index) => setState(() => _focusedIndex = index),
            itemBuilder: (context, index) {
              final distance = (_page - index).abs().clamp(0.0, 1.0);
              final scale = 1 - (distance * 0.1);
              final opacity = 1 - (distance * 0.5);
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: getPadding(left: 8, right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withOpacity(0.25),
                            blurRadius: 24,
                            spreadRadius: 1,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: _cover(index),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: getPadding(top: 20, left: 10, right: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Column(
                    key: ValueKey(_focusedIndex),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        focusedTrack.title,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(
                          fontSize: getFontSize(17),
                          fontWeight: FontWeight.w600,
                          color: ColorConstant.gray800,
                        ),
                      ),
                      SizedBox(height: getVerticalSize(4)),
                      Text(
                        showingPause
                            ? '${_formatTime(_elapsed.inSeconds)} / ${_formatTime(focusedMax.inSeconds)}'
                            : _formatTime(focusedMax.inSeconds),
                        style: AppStyle.txtSFProDisplayMedium9.copyWith(
                          color: ColorConstant.gray500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: getHorizontalSize(16)),
              GestureDetector(
                onTap: _onPlayTap,
                child: SizedBox(
                  width: getSize(56),
                  height: getSize(56),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: getSize(56),
                        height: getSize(56),
                        child: CircularProgressIndicator(
                          value: progress,
                          backgroundColor: widget.accentColor.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(widget.accentColor),
                          strokeWidth: 3,
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: showingPause ? 1.0 : 0.0),
                        duration: const Duration(milliseconds: 250),
                        builder: (context, value, _) => AnimatedIcon(
                          icon: AnimatedIcons.play_pause,
                          progress: AlwaysStoppedAnimation(value),
                          color: widget.accentColor,
                          size: getSize(28),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
