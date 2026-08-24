import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riva_psy/core/app_export.dart';

import 'glass_card.dart';

// Full-screen "now playing" view — reads/controls the SAME AudioPlayer
// instance the caller already owns (e.g. ExerciseContentController's
// shared audioInstance) rather than creating its own, so playback state
// stays in sync with whatever compact control row the caller uses.
class FullscreenAudioPlayerScreen extends StatefulWidget {
  final String title;
  final Widget cover;
  final AudioPlayer audioInstance;
  final Color accentColor;

  const FullscreenAudioPlayerScreen({
    Key? key,
    required this.title,
    required this.cover,
    required this.audioInstance,
    required this.accentColor,
  }) : super(key: key);

  @override
  State<FullscreenAudioPlayerScreen> createState() => _FullscreenAudioPlayerScreenState();
}

class _FullscreenAudioPlayerScreenState extends State<FullscreenAudioPlayerScreen> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  StreamSubscription? _posSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    _duration = widget.audioInstance.duration ?? Duration.zero;
    _position = widget.audioInstance.position;
    _playing = widget.audioInstance.playing;
    _posSub = widget.audioInstance.positionStream.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _stateSub = widget.audioInstance.playerStateStream.listen((s) {
      if (!mounted) return;
      setState(() {
        _playing = s.playing;
        if (widget.audioInstance.duration != null) _duration = widget.audioInstance.duration!;
      });
      if (s.processingState == ProcessingState.completed) {
        Navigator.maybePop(context);
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
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
                            value: _position.inSeconds
                                .toDouble()
                                .clamp(0.0, _duration.inSeconds.toDouble()),
                            min: 0,
                            max: _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1,
                            activeColor: widget.accentColor,
                            inactiveColor: widget.accentColor.withOpacity(0.2),
                            onChanged: (v) => widget.audioInstance.seek(Duration(seconds: v.toInt())),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_fmt(_position), style: AppStyle.txtSFProDisplayRegular11Gray800),
                            Text(_fmt(_duration), style: AppStyle.txtSFProDisplayRegular11Gray800),
                          ],
                        ),
                        SizedBox(height: getVerticalSize(10)),
                        GestureDetector(
                          onTap: () =>
                              _playing ? widget.audioInstance.pause() : widget.audioInstance.play(),
                          child: Container(
                            width: getSize(56),
                            height: getSize(56),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: widget.accentColor),
                            child: Icon(
                              _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
  }
}
