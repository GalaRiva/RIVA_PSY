import 'dart:async';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';

import 'glass_card.dart';

// Full-screen "now playing" view — reads/controls the shared
// AppAudioService instead of a player the caller passes in, so playback
// state stays in sync with whatever compact control row (e.g.
// HeroAudioCarousel) is showing the same track elsewhere.
class FullscreenAudioPlayerScreen extends StatefulWidget {
  final String title;
  final Widget cover;
  final Color accentColor;

  const FullscreenAudioPlayerScreen({
    Key? key,
    required this.title,
    required this.cover,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<FullscreenAudioPlayerScreen> createState() => _FullscreenAudioPlayerScreenState();
}

class _FullscreenAudioPlayerScreenState extends State<FullscreenAudioPlayerScreen> {
  StreamSubscription<String>? _completedSub;

  @override
  void initState() {
    super.initState();
    // Whatever track was current when this screen opened finishing —
    // close back out to the compact control row, matching the old
    // behavior when this owned its own player/completion listener.
    final openedTrackId = AppAudioService.instance.state.value.track?.id;
    _completedSub = AppAudioService.instance.onCompleted.listen((id) {
      if (id == openedTrackId) Navigator.maybePop(context);
    });
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppAudioState>(
      valueListenable: AppAudioService.instance.state,
      builder: (context, audioState, _) {
        final position = audioState.position;
        final duration = audioState.duration;
        final playing = audioState.playing;
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              widget.cover,
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.25), Colors.black.withOpacity(0.55)],
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: getPadding(left: 24, right: 24, top: 12, bottom: 24),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: getSize(38),
                            height: getSize(38),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.4),
                            ),
                            child: SizedBox(
                              width: getSize(16),
                              height: getSize(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: 0.785398,
                                    child: Container(width: getSize(16), height: 3, color: Colors.white),
                                  ),
                                  Transform.rotate(
                                    angle: -0.785398,
                                    child: Container(width: getSize(16), height: 3, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      GlassCard(
                        padding: getPadding(left: 24, top: 24, right: 24, bottom: 22),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              textAlign: TextAlign.center,
                              style: AppStyle.txtH1.copyWith(fontSize: getFontSize(19)),
                            ),
                            SizedBox(height: getVerticalSize(18)),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                              ),
                              child: Slider(
                                value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                                min: 0,
                                max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
                                activeColor: widget.accentColor,
                                inactiveColor: widget.accentColor.withOpacity(0.2),
                                onChanged: (v) => AppAudioService.instance.seek(Duration(seconds: v.toInt())),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_fmt(position), style: AppStyle.txtSFProDisplayRegular11Gray800),
                                Text(_fmt(duration), style: AppStyle.txtSFProDisplayRegular11Gray800),
                              ],
                            ),
                            SizedBox(height: getVerticalSize(10)),
                            GestureDetector(
                              onTap: () => AppAudioService.instance.togglePlayPause(),
                              child: Container(
                                width: getSize(56),
                                height: getSize(56),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(shape: BoxShape.circle, color: widget.accentColor),
                                child: Icon(
                                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: getSize(30),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
