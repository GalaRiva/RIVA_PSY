import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/audio/audio.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

// Standalone single-track player for the quiz bridge's "Конгруэнтность
// сердца" recommendation — deliberately not built on K70Controller/
// AudioCardWidget, which assume a whole tab's worth of tracks and a shared
// list-index state this one-off screen doesn't have.
class MeditationPlayerScreen extends StatefulWidget {
  final void Function(BuildContext context) onContinue;

  const MeditationPlayerScreen({Key? key, required this.onContinue}) : super(key: key);

  @override
  State<MeditationPlayerScreen> createState() => _MeditationPlayerScreenState();
}

class _MeditationPlayerScreenState extends State<MeditationPlayerScreen> {
  final _player = AudioPlayer();
  bool _loading = true;
  bool _failed = false;
  String _title = '';
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _playing = false;

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
      final duration = await _player.setUrl(source);
      _player.positionStream.listen((p) {
        if (mounted) setState(() => _position = p);
      });
      _player.playerStateStream.listen((s) {
        if (mounted) setState(() => _playing = s.playing);
      });
      if (!mounted) return;
      setState(() {
        _title = audio.localizedName(langCode);
        _duration = duration ?? Duration.zero;
        _loading = false;
      });
      _player.play();
    } catch (e) {
      if (mounted) setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
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
          Image.asset('assets/images/quiz/love.png', fit: BoxFit.cover),
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
                        Text(
                          _loading
                              ? '…'
                              : _failed
                                  ? 'network_error_try_later'.tr()
                                  : _title,
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
                              value: _position.inSeconds
                                  .toDouble()
                                  .clamp(0.0, _duration.inSeconds.toDouble()),
                              min: 0,
                              max: _duration.inSeconds.toDouble() > 0
                                  ? _duration.inSeconds.toDouble()
                                  : 1,
                              activeColor: ColorConstant.cyan700,
                              inactiveColor: ColorConstant.cyan700.withOpacity(0.2),
                              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
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
                            onTap: () => _playing ? _player.pause() : _player.play(),
                            child: Container(
                              width: getSize(56),
                              height: getSize(56),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ColorConstant.cyan700,
                              ),
                              child: Icon(
                                _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: getSize(30),
                              ),
                            ),
                          ),
                        ],
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
