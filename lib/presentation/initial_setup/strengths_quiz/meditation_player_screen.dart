import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/audio/audio.dart';
import '../../../core/utils/audio_cover_map.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

// Standalone single-track player for the quiz bridge's "Конгруэнтность
// сердца" recommendation — plays through the shared AppAudioService like
// every other screen now, instead of owning its own AudioPlayer.
class MeditationPlayerScreen extends StatefulWidget {
  final void Function(BuildContext context) onContinue;

  const MeditationPlayerScreen({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen> {
  bool _loading = true;
  bool _failed = false;
  AppAudioTrack? _track;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Audio')
          .doc('meditation__meditaciya_serdce')
          .get();
      final data = doc.data();
      if (data == null) throw Exception('meditation doc not found');
      final audio = Audio.fromJson(data);
      final prefs = await SharedPreferences.getInstance();
      final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
      final fileName = audio.localizedFileName(langCode);
      final source =
          'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/$fileName.${audio.format}';
      final track = AppAudioTrack.forUrl(
        source,
        title: audio.localizedName(langCode),
        coverAsset: audioCoverAsset(audio.name),
        coverBuilder: animatedAudioCoverBuilder(audio.name),
      );
      if (!mounted) return;
      setState(() {
        _track = track;
        _loading = false;
      });
      await AppAudioService.instance.play(track);
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _failed = true;
      });
    }
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
          Image.asset('assets/images/quiz/love.jpg', fit: BoxFit.cover),
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
                      onTap: () => widget.onContinue(context),
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
                        ValueListenableBuilder<AppAudioState>(
                          valueListenable: AppAudioService.instance.state,
                          builder: (context, audioState, _) {
                            final track = _track;
                            final isMine = track != null && audioState.isCurrent(track.id);
                            final position = isMine ? audioState.position : Duration.zero;
                            final duration = isMine ? audioState.duration : Duration.zero;
                            final playing = isMine && audioState.playing;
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _loading
                                      ? '…'
                                      : _failed
                                          ? 'network_error_try_later'.tr()
                                          : track?.title ?? '',
                                  textAlign: TextAlign.center,
                                  style: AppStyle.txtH1.copyWith(fontSize: getFontSize(19)),
                                ),
                                if (!_loading && !_failed) ...[
                                  SizedBox(height: getVerticalSize(18)),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                    ),
                                    child: Slider(
                                      value: position.inSeconds
                                          .toDouble()
                                          .clamp(0.0, duration.inSeconds.toDouble()),
                                      min: 0,
                                      max: duration.inSeconds.toDouble() > 0
                                          ? duration.inSeconds.toDouble()
                                          : 1,
                                      activeColor: ColorConstant.cyan700,
                                      inactiveColor: ColorConstant.cyan700.withOpacity(0.2),
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
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorConstant.cyan700,
                                      ),
                                      child: Icon(
                                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: getSize(30),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        SizedBox(height: getVerticalSize(18)),
                        CustomButton(
                          height: getVerticalSize(48),
                          width: double.infinity,
                          text: 'continue'.tr().toUpperCase(),
                          variant: ButtonVariant.Cyan,
                          fontStyle: ButtonFontStyle.White16,
                          onTap: () => widget.onContinue(context),
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
