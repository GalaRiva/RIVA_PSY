import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:video_player/video_player.dart';

import '../../../widgets/glass_card.dart';

// Phase 3 of the onboarding quiz flow — a 5.4s "building your profile"
// beat (Ikea effect: makes the result feel computed, not instant) with the
// looping brand video as backdrop.
class ProfileGenerationLoadingScreen extends StatefulWidget {
  // Takes this screen's own live BuildContext — a context captured higher
  // up the chain (e.g. the quiz screen's) goes stale the moment an earlier
  // pushReplacement removes that screen from the tree, which silently
  // broke the next navigation.
  final void Function(BuildContext context) onComplete;

  const ProfileGenerationLoadingScreen({Key? key, required this.onComplete}) : super(key: key);

  @override
  State<ProfileGenerationLoadingScreen> createState() => _ProfileGenerationLoadingScreenState();
}

class _ProfileGenerationLoadingScreenState extends State<ProfileGenerationLoadingScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _messageKeys = ['quiz_loading_1', 'quiz_loading_2', 'quiz_loading_3'];
  static const _messageDuration = Duration(milliseconds: 1800);

  late final VideoPlayerController _videoController;
  late final AnimationController _progressController;
  int _messageIndex = 0;
  Timer? _messageTimer;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/videos/profile_generation.mp4')
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _videoController.play();
      });

    _progressController = AnimationController(
      vsync: this,
      duration: _messageDuration * _messageKeys.length,
    )..forward();

    _messageTimer = Timer.periodic(_messageDuration, (timer) {
      if (_messageIndex >= _messageKeys.length - 1) {
        timer.cancel();
        Future.delayed(_messageDuration, () {
          if (mounted) widget.onComplete(context);
        });
        return;
      }
      setState(() => _messageIndex++);
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _videoController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04201D),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Poster (the video's own first frame) shows instantly, so there's
          // no dark gap while VideoPlayerController initializes — the video
          // then crossfades in on top once ready.
          Image.asset('assets/images/quiz/profile_generation_poster.png', fit: BoxFit.cover),
          AnimatedOpacity(
            opacity: _videoReady ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: _videoReady
                ? FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.25), Colors.black.withOpacity(0.45)],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.05),
            child: Padding(
              padding: getPadding(left: 30, right: 30),
              child: GlassCard(
                padding: getPadding(left: 24, top: 24, right: 24, bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _messageKeys[_messageIndex].tr(),
                        key: ValueKey(_messageIndex),
                        textAlign: TextAlign.center,
                        style: AppStyle.txtH1.copyWith(fontSize: getFontSize(22)),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(18)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: AnimatedBuilder(
                        animation: _progressController,
                        builder: (context, _) => LinearProgressIndicator(
                          value: _progressController.value,
                          minHeight: 5,
                          backgroundColor: ColorConstant.cyan700.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(ColorConstant.cyan700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
