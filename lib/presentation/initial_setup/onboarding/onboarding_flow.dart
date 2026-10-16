import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/audio/audio.dart';
import '../../../core/services/notifications/awesome_notification_service.dart';
import '../../../core/utils/audio_cover_map.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/helpline_link.dart';
import '../../../widgets/medical_disclaimer.dart';
import '../strengths_quiz/quiz_flow.dart';
import 'onboarding_concern.dart';

const String _r2AudioBase = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';

// First launch: one question -> one short practice picked for the answer ->
// one-tap "how do you feel now" -> the existing quiz + paywall. The old
// order put the paywall in front of any real value; this puts a 2-3 minute
// win first. Everything is skippable and stored locally only.
Future<void> startOnboardingFlow(BuildContext context) async {
  await OnboardingPrefs.markStarted();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OnboardingConcernScreen(
        onSkip: (ctx) => startPostRegistrationQuizFlow(ctx, skipBridge: true),
      ),
    ),
  );
}

class OnboardingConcernScreen extends StatelessWidget {
  final void Function(BuildContext context) onSkip;
  const OnboardingConcernScreen({Key? key, required this.onSkip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: getPadding(left: 22, right: 22, top: 28, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('onb_title'.tr(), style: AppStyle.txtH1),
              SizedBox(height: getVerticalSize(8)),
              Text('onb_subtitle'.tr(),
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
              SizedBox(height: getVerticalSize(18)),
              Expanded(
                child: ListView.separated(
                  itemCount: OnboardingConcern.values.length,
                  separatorBuilder: (_, __) => SizedBox(height: getVerticalSize(10)),
                  itemBuilder: (context, i) {
                    final c = OnboardingConcern.values[i];
                    return Semantics(
                      button: true,
                      label: c.labelKey.tr(),
                      excludeSemantics: true,
                      child: GestureDetector(
                        onTap: () async {
                          await OnboardingPrefs.saveConcern(c);
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => OnboardingPracticeScreen(concern: c),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          padding: getPadding(left: 18, top: 16, right: 18, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: ColorConstant.cyan700.withOpacity(0.18)),
                          ),
                          child: Text(c.labelKey.tr(),
                              style: AppStyle.txtSFProDisplayLight16
                                  .copyWith(color: ColorConstant.gray800)),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: getVerticalSize(8)),
              Center(
                child: TextButton(
                  onPressed: () => onSkip(context),
                  child: Text('onb_skip'.tr(),
                      style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class OnboardingPracticeScreen extends StatefulWidget {
  final OnboardingConcern concern;
  const OnboardingPracticeScreen({Key? key, required this.concern}) : super(key: key);

  @override
  State<OnboardingPracticeScreen> createState() => _OnboardingPracticeScreenState();
}

class _OnboardingPracticeScreenState extends State<OnboardingPracticeScreen> {
  final List<_Practice> _options = [];
  _Practice? _selected;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
      for (final id in widget.concern.audioDocIds) {
        final doc = await FirebaseFirestore.instance.collection('Audio').doc(id).get();
        final data = doc.data();
        if (data == null) continue;
        final audio = Audio.fromJson(data);
        final url = '$_r2AudioBase${audio.localizedFileName(langCode)}.${audio.format}';
        _options.add(_Practice(
          AppAudioTrack.forUrl(url,
              title: audio.localizedName(langCode),
              coverAsset: audioCoverAsset(audio.name),
              coverBuilder: animatedAudioCoverBuilder(audio.name)),
          audio.localizedDuration(langCode),
        ));
      }
      if (_options.isEmpty) throw Exception('no onboarding audio found');
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_options.length == 1) _selected = _options.first;
      });
      if (_selected != null) await AppAudioService.instance.play(_selected!.track);
    } catch (_) {
      if (mounted) setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  Future<void> _choose(_Practice p) async {
    setState(() => _selected = p);
    await AppAudioService.instance.play(p.track);
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _next() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingFeelingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnknown = widget.concern == OnboardingConcern.unknown;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: getPadding(left: 22, right: 22, top: 28, bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('onb_practice_title'.tr(), style: AppStyle.txtH1),
              SizedBox(height: getVerticalSize(8)),
              Text(
                  isUnknown ? 'onb_unknown_note'.tr() : 'onb_practice_subtitle'.tr(),
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
              SizedBox(height: getVerticalSize(20)),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (_failed)
                Text('network_error_try_later'.tr(), style: AppStyle.txtSFProDisplayLight16)
              else if (isUnknown && _selected == null)
                ..._options.map((p) => Padding(
                      padding: EdgeInsets.only(bottom: getVerticalSize(10)),
                      child: GestureDetector(
                        onTap: () => _choose(p),
                        child: Container(
                          width: double.infinity,
                          padding: getPadding(left: 18, top: 16, right: 18, bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: ColorConstant.cyan700.withOpacity(0.18)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                  child: Text(p.track.title,
                                      style: AppStyle.txtSFProDisplayLight16
                                          .copyWith(color: ColorConstant.gray800))),
                              if (p.duration != null)
                                Text(_fmt(p.duration!),
                                    style: AppStyle.txtSFProDisplayRegular11Gray800),
                            ],
                          ),
                        ),
                      ),
                    ))
              else if (_selected != null)
                GlassCard(
                  padding: getPadding(left: 22, top: 22, right: 22, bottom: 20),
                  child: ValueListenableBuilder<AppAudioState>(
                    valueListenable: AppAudioService.instance.state,
                    builder: (context, s, _) {
                      final t = _selected!.track;
                      final mine = s.isCurrent(t.id);
                      final position = mine ? s.position : Duration.zero;
                      final duration = mine ? s.duration : Duration.zero;
                      final playing = mine && s.playing;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(t.title,
                              textAlign: TextAlign.center,
                              style: AppStyle.txtH1.copyWith(fontSize: getFontSize(19))),
                          SizedBox(height: getVerticalSize(16)),
                          Slider(
                            value: position.inSeconds
                                .toDouble()
                                .clamp(0.0, duration.inSeconds.toDouble()),
                            min: 0,
                            max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1,
                            activeColor: ColorConstant.cyan700,
                            inactiveColor: ColorConstant.cyan700.withOpacity(0.2),
                            onChanged: (v) => AppAudioService.instance.seek(Duration(seconds: v.toInt())),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_fmt(position), style: AppStyle.txtSFProDisplayRegular11Gray800),
                              Text(_fmt(duration), style: AppStyle.txtSFProDisplayRegular11Gray800),
                            ],
                          ),
                          SizedBox(height: getVerticalSize(10)),
                          Semantics(
                            button: true,
                            label: playing ? 'pause' : 'play',
                            excludeSemantics: true,
                            child: GestureDetector(
                              onTap: () => AppAudioService.instance.togglePlayPause(),
                              child: Container(
                                width: getSize(56),
                                height: getSize(56),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle, color: ColorConstant.cyan700),
                                child: Icon(
                                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: getSize(30)),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              const Spacer(),
              const MedicalDisclaimer(compact: true),
              SizedBox(height: getVerticalSize(8)),
              if (!_loading && (_selected != null || _failed))
                CustomButton(
                  height: getVerticalSize(48),
                  width: double.infinity,
                  text: 'continue'.tr().toUpperCase(),
                  variant: ButtonVariant.Cyan,
                  fontStyle: ButtonFontStyle.White16,
                  onTap: () async {
                    await OnboardingPrefs.markFirstPracticeDone();
                    // Don't leave a track playing under the quiz/paywall.
                    await AppAudioService.instance.stop();
                    _next();
                  },
                ),
            ],
          ),
        ),
      ),
    ));
  }
}

class _Practice {
  final AppAudioTrack track;
  final Duration? duration;
  _Practice(this.track, this.duration);
}

class OnboardingFeelingScreen extends StatefulWidget {
  const OnboardingFeelingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingFeelingScreen> createState() => _OnboardingFeelingScreenState();
}

class _OnboardingFeelingScreenState extends State<OnboardingFeelingScreen> {
  String? _picked;

  Future<void> _pick(String v) async {
    await OnboardingPrefs.saveFeeling(v);
    if (mounted) setState(() => _picked = v);
  }

  // Asks for notification permission here — right after the person got
  // value, the moment it's easiest to justify — and schedules tomorrow's
  // 11:00 follow-up in their own theme. Fire-and-forget on purpose: on iOS
  // a plugin call can hang, and nothing here may block the flow.
  Future<void> _scheduleFollowUp() async {
    try {
      final allowed = await AwesomeNotifications().isNotificationAllowed();
      if (!allowed) {
        final granted = await AwesomeNotifications().requestPermissionToSendNotifications();
        if (!granted) return;
      }
      final concern = await OnboardingPrefs.concern();
      await AwesomeNotificationService()
          .scheduleFirstStepFollowUp(concernKey: concern?.key ?? 'generic');
    } catch (_) {}
  }

  void _continue() {
    _scheduleFollowUp();
    startPostRegistrationQuizFlow(context, skipBridge: true);
  }

  @override
  Widget build(BuildContext context) {
    final options = const [
      ['better', 'onb_feeling_better'],
      ['same', 'onb_feeling_same'],
      ['worse', 'onb_feeling_worse'],
    ];
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: getPadding(left: 22, right: 22, top: 28, bottom: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('onb_feeling_title'.tr(), style: AppStyle.txtH1),
              SizedBox(height: getVerticalSize(18)),
              for (final o in options)
                Padding(
                  padding: EdgeInsets.only(bottom: getVerticalSize(10)),
                  child: GestureDetector(
                    onTap: () => _pick(o[0]),
                    child: Container(
                      width: double.infinity,
                      padding: getPadding(left: 18, top: 16, right: 18, bottom: 16),
                      decoration: BoxDecoration(
                        color: _picked == o[0]
                            ? ColorConstant.cyan700.withOpacity(0.10)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                            color: ColorConstant.cyan700
                                .withOpacity(_picked == o[0] ? 0.7 : 0.18)),
                      ),
                      child: Text(o[1].tr(),
                          style: AppStyle.txtSFProDisplayLight16
                              .copyWith(color: ColorConstant.gray800)),
                    ),
                  ),
                ),
              if (_picked == 'worse')
                Padding(
                  padding: getPadding(top: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('onb_feeling_worse_note'.tr(),
                          style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
                      const HelplineLink(),
                    ],
                  ),
                ),
              const Spacer(),
              if (_picked != null)
                CustomButton(
                  height: getVerticalSize(48),
                  width: double.infinity,
                  text: 'continue'.tr().toUpperCase(),
                  variant: ButtonVariant.Cyan,
                  fontStyle: ButtonFontStyle.White16,
                  onTap: _continue,
                ),
            ],
          ),
        ),
      ),
    ));
  }
}
