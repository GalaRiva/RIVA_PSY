import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:vibration/vibration.dart';

/// A calm, soft track card for lists of practices: cover on the left, the
/// title (up to two lines) with the duration under it, a round play button on
/// the right. The whole card is tappable. While it plays it takes a light tint
/// and shows a thin, seekable progress line under the row.
///
/// Plays through the app-wide [AppAudioService], like the older
/// `AudioCardWidget`: "is this the current track" is a track-id comparison
/// against the shared state, and position/duration are the real ones.
class SoftAudioCard extends StatefulWidget {
  final String text;
  final AppAudioTrack track;
  final Duration maxDuration;
  final VoidCallback? onNaturalCompletion;

  const SoftAudioCard({
    Key? key,
    required this.text,
    required this.track,
    required this.maxDuration,
    this.onNaturalCompletion,
  }) : super(key: key);

  /// "1:35" — minutes without a leading zero, seconds with one.
  static String formatTime(Duration d) {
    final s = d.inSeconds;
    final m = s ~/ 60;
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  State<SoftAudioCard> createState() => _SoftAudioCardState();
}

class _SoftAudioCardState extends State<SoftAudioCard> {
  StreamSubscription<String>? _completedSub;

  @override
  void initState() {
    super.initState();
    _completedSub = AppAudioService.instance.onCompleted.listen((id) {
      if (id == widget.track.id) widget.onNaturalCompletion?.call();
    });
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    super.dispose();
  }

  Widget _cover() {
    final asset = widget.track.coverAsset;
    final side = getSize(56);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: side,
        height: side,
        child: asset != null
            ? Image.asset(
                asset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _coverFallback(),
              )
            : _coverFallback(),
      ),
    );
  }

  // Quiet tinted tile with a headphones icon, for tracks without a cover.
  Widget _coverFallback() => Container(
        color: AppColors.primaryLight,
        alignment: Alignment.center,
        child: Icon(Icons.headphones_rounded, color: AppColors.primary, size: getSize(24)),
      );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppAudioState>(
      valueListenable: AppAudioService.instance.state,
      builder: (context, audioState, _) {
        final isMine = audioState.isCurrent(widget.track.id);
        final playing = isMine && audioState.playing;
        final position = isMine ? audioState.position : Duration.zero;
        final total = isMine && audioState.duration > Duration.zero ? audioState.duration : widget.maxDuration;
        final dimmed = audioState.playing && !isMine;

        void onTap() {
          final service = AppAudioService.instance;
          if (isMine) {
            service.togglePlayPause();
          } else {
            service.play(widget.track);
          }
          Vibration.vibrate(duration: 50);
        }

        final maxSeconds = total.inSeconds.toDouble();
        final value = position.inSeconds.toDouble().clamp(0.0, maxSeconds > 0 ? maxSeconds : 1.0).toDouble();

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: dimmed ? 0.8 : 1.0,
          child: Padding(
            padding: EdgeInsets.only(bottom: getVerticalSize(12)),
            child: Semantics(
              button: true,
              label: widget.text,
              child: Material(
                color: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: isMine ? AppColors.primaryLight : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: isMine ? AppColors.primary.withOpacity(0.18) : AppColors.divider),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: onTap,
                    child: Padding(
                      padding: getPadding(left: 12, top: 12, right: 12, bottom: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              _cover(),
                              SizedBox(width: getHorizontalSize(12)),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.text,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                        fontSize: getFontSize(15),
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                        height: 1.25,
                                      ),
                                    ),
                                    SizedBox(height: getVerticalSize(4)),
                                    Text(
                                      isMine && total > Duration.zero
                                          ? '${SoftAudioCard.formatTime(position)} / ${SoftAudioCard.formatTime(total)}'
                                          : SoftAudioCard.formatTime(total),
                                      style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                        fontSize: getFontSize(13),
                                        color: const Color(0xFF5B6469),
                                        fontFeatures: const [FontFeature.tabularFigures()],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: getHorizontalSize(10)),
                              Container(
                                width: getSize(44),
                                height: getSize(44),
                                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                alignment: Alignment.center,
                                child: TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0.0, end: playing ? 1.0 : 0.0),
                                  duration: const Duration(milliseconds: 250),
                                  builder: (context, v, _) => AnimatedIcon(
                                    icon: AnimatedIcons.play_pause,
                                    progress: AlwaysStoppedAnimation(v),
                                    color: Colors.white,
                                    size: getSize(26),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Thin, seekable progress line only for the current track.
                          AnimatedSize(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            alignment: Alignment.topCenter,
                            child: isMine
                                ? SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                      activeTrackColor: AppColors.primary,
                                      inactiveTrackColor: Colors.white,
                                      thumbColor: AppColors.primary,
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.only(top: getVerticalSize(6)),
                                      child: Slider(
                                        value: value,
                                        min: 0.0,
                                        max: maxSeconds > 0 ? maxSeconds : 1.0,
                                        onChanged: (v) => AppAudioService.instance.seek(Duration(seconds: v.toInt())),
                                      ),
                                    ),
                                  )
                                : const SizedBox(width: double.infinity),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
