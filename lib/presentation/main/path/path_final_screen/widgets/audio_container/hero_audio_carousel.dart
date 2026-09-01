import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:vibration/vibration.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/audio/app_audio_service.dart';
import '../../../../../../core/services/audio/app_audio_track.dart';
import '../../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../../core/utils/audio_cover_map.dart';
import '../../../../../../widgets/fullscreen_audio_player_screen.dart';

// "Decoupled Player": the carousel above only shows artwork/mood — track
// controls live in a static block below that never resizes. Swiping just
// changes which card is focused; playback runs through the shared
// AppAudioService, so it keeps going in the background regardless of
// what's focused here, or even if the user navigates to a completely
// different screen — same as any other track played through that service.
class HeroAudioCarousel extends StatefulWidget {
  final List<AudioCardModel> audios;
  final Color accentColor;

  const HeroAudioCarousel({
    Key? key,
    required this.audios,
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

  List<Duration?> _maxDurations = [];
  bool _durationsLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() => _page = _pageController.page ?? 0);
    });
    _loadDurations();
  }

  Future<void> _loadDurations() async {
    final list = <Duration?>[];
    for (var item in widget.audios) {
      // Known ahead of time (Audio.duration_ms, precomputed once and
      // stored in Firestore) — skip the network probe entirely. Falls
      // back to a one-off, disposable-player probe for the rare track
      // without one.
      list.add(item.knownDuration ?? await AudioCacheManager.probeDuration(item.audioAsset));
    }
    if (mounted) setState(() { _maxDurations = list; _durationsLoading = false; });
  }

  AppAudioTrack _trackFor(int index) {
    final item = widget.audios[index];
    return AppAudioTrack.forUrl(item.audioAsset, title: item.title, coverAsset: audioCoverAsset(item.ruTitle));
  }

  Future<void> _onPlayTap() async {
    Vibration.vibrate(duration: 50);
    final service = AppAudioService.instance;
    final track = _trackFor(_focusedIndex);
    final wasPlayingMine = service.state.value.isCurrent(track.id) && service.state.value.playing;
    if (wasPlayingMine) {
      await service.pause();
    } else if (service.state.value.isCurrent(track.id)) {
      await service.resume();
    } else {
      await service.play(track);
    }
    // Pausing just stops in place — only a transition into "playing" opens
    // the full-screen view.
    final nowPlaying = service.state.value.isCurrent(track.id) && service.state.value.playing;
    if (nowPlaying && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FullscreenAudioPlayerScreen(
            title: widget.audios[_focusedIndex].title,
            cover: _cover(_focusedIndex),
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
    if (_durationsLoading) {
      return Center(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(color: widget.accentColor),
        ),
      );
    }

    return ValueListenableBuilder<AppAudioState>(
      valueListenable: AppAudioService.instance.state,
      builder: (context, audioState, _) {
        final focusedTrack = widget.audios[_focusedIndex];
        final focusedTrackId = _trackFor(_focusedIndex).id;
        final isMine = audioState.isCurrent(focusedTrackId);
        final showingPause = isMine && audioState.playing;
        final knownMax = _focusedIndex < _maxDurations.length ? _maxDurations[_focusedIndex] : null;
        final focusedMax = isMine && audioState.duration > Duration.zero
            ? audioState.duration
            : (knownMax ?? Duration.zero);
        final elapsed = isMine ? audioState.position : Duration.zero;
        final progress = (isMine && focusedMax.inSeconds > 0)
            ? (elapsed.inSeconds / focusedMax.inSeconds).clamp(0.0, 1.0)
            : 0.0;

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
                                ? '${_formatTime(elapsed.inSeconds)} / ${_formatTime(focusedMax.inSeconds)}'
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
      },
    );
  }
}
