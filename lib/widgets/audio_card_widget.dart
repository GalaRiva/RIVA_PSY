import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:vibration/vibration.dart';

import '../../widgets/custom_icon_button.dart';

// One row in a track list — plays through the app-wide AppAudioService
// instead of owning any player state itself, so "am I the one currently
// playing" is just a track-id comparison against the shared state
// (AppAudioService.instance.state), not a per-screen index the parent has
// to keep passing around. Real playback position, too — no more local
// timer standing in for it.
class AudioCardWidget extends StatefulWidget {
  final String text;
  final AppAudioTrack track;
  final Duration maxDuration;
  final VoidCallback? onNaturalCompletion;

  const AudioCardWidget({
    Key? key,
    required this.text,
    required this.track,
    required this.maxDuration,
    this.onNaturalCompletion,
  }) : super(key: key);

  @override
  State<AudioCardWidget> createState() => _AudioCardWidgetState();
}

class _AudioCardWidgetState extends State<AudioCardWidget> {
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

  String _formatTime(int milliseconds) {
    var secs = milliseconds ~/ 1000;
    var minutes = ((secs % 3600) ~/ 60).toString().padLeft(2, '0');
    var seconds = (secs % 60).toString().padLeft(2, '0');
    return "$minutes.$seconds";
  }

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

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: dimmed ? 0.65 : 1.0,
          child: Padding(
            padding: EdgeInsets.only(bottom: getVerticalSize(23)),
            child: SizedBox(
              height: getVerticalSize(80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.text,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(
                      fontSize: getFontSize(16),
                      fontWeight: FontWeight.w600,
                      color: ColorConstant.gray800,
                      letterSpacing: getHorizontalSize(0.44),
                    ),
                  ),
                  SizedBox(height: getVerticalSize(12)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomIconButton(
                        height: getVerticalSize(44),
                        width: getVerticalSize(44),
                        child: CustomImageView(
                          svgPath: ImageConstant.imgMusicCyan70032x32,
                        ),
                      ),
                      Padding(
                        padding: getPadding(left: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: size.width - 86,
                          height: getVerticalSize(44),
                          decoration: AppDecoration.back.copyWith(
                            color: isMine ? ColorConstant.cyan700.withOpacity(0.22) : ColorConstant.gray300,
                            borderRadius: BorderRadiusStyle.roundedBorder3,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: onTap,
                                child: SizedBox(
                                  height: getSize(38),
                                  width: getSize(38),
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: playing ? 1.0 : 0.0),
                                    duration: const Duration(milliseconds: 250),
                                    builder: (context, value, _) => AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      progress: AlwaysStoppedAnimation(value),
                                      color: ColorConstant.cyan700,
                                      size: getSize(30),
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: playing
                                    ? SizedBox(
                                        key: const ValueKey('slider'),
                                        width: size.width - 171,
                                        child: SliderTheme(
                                          data: SliderTheme.of(context).copyWith(
                                            trackHeight: 3,
                                            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 9),
                                            overlayShape: RoundSliderOverlayShape(overlayRadius: 20),
                                          ),
                                          child: Slider(
                                            value: position.inSeconds.toDouble() >= total.inSeconds.toDouble()
                                                ? total.inSeconds.toDouble()
                                                : position.inSeconds.toDouble(),
                                            min: 0.0,
                                            thumbColor: ColorConstant.cyan700,
                                            activeColor: ColorConstant.cyan700,
                                            inactiveColor: Colors.white,
                                            max: total.inSeconds.toDouble() > 0 ? total.inSeconds.toDouble() : 1,
                                            onChanged: (double value) {
                                              AppAudioService.instance.seek(Duration(seconds: value.toInt()));
                                            },
                                          ),
                                        ),
                                      )
                                    : const SizedBox(key: ValueKey('no-slider')),
                              ),
                              Text(
                                _formatTime(total.inMilliseconds),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayMedium9.copyWith(
                                  color: ColorConstant.gray500,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
