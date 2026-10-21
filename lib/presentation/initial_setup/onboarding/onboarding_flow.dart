import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_service.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/audio/audio.dart';
import '../../../core/services/exercise_notice.dart';
import '../../../core/services/notifications/awesome_notification_service.dart';
import '../../../core/utils/audio_cover_map.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/helpline_link.dart';
import '../../../widgets/medical_disclaimer.dart';
import '../../recomendation/recomendation_screen/working_out/programs/data/course_repository.dart';
import '../strengths_quiz/quiz_flow.dart';
import 'onboarding_concern.dart';

const String _r2AudioBase = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/';

// "Первый шаг": one question -> one short practice picked for the answer ->
// one-tap "how do you feel now". On the very first launch it continues into
// the existing quiz + paywall; opened from Settings ([fromSettings]) it is a
// self-contained mini flow that simply returns to Settings. Every screen has
// a back arrow and a close button, and is stored locally only.
//
// [repeatLaunch]: a later app launch where nothing was chosen yet (the screen
// is shown on every launch until a concern is picked once). The quiz/paywall
// already ran on the first launch, so closing or finishing goes straight on
// to the app instead of repeating them.
bool _repeatLaunch = false;

Future<void> startOnboardingFlow(BuildContext context,
    {bool fromSettings = false, bool repeatLaunch = false}) async {
  _repeatLaunch = repeatLaunch && !fromSettings;
  if (!fromSettings && !repeatLaunch) await OnboardingPrefs.markStarted();
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => OnboardingConcernScreen(fromSettings: fromSettings)),
  );
}

// Leaving the flow: first launch -> on to the quiz/paywall (the rest of the
// welcome), Settings -> just back to Settings.
void _exitFlow(BuildContext context, bool fromSettings) {
  AppAudioService.instance.stop();
  if (fromSettings) {
    Navigator.pop(context);
  } else if (_repeatLaunch) {
    goToAppAfterOnboarding(context);
  } else {
    startPostRegistrationQuizFlow(context, skipBridge: true);
  }
}

IconData _iconFor(OnboardingConcern c) {
  switch (c.key) {
    case 'anxious':
      return Icons.air_rounded;
    case 'resentment':
      return Icons.heart_broken_outlined;
    case 'anger':
      return Icons.local_fire_department_outlined;
    case 'exhausted':
      return Icons.bedtime_outlined;
    case 'lonely':
      return Icons.nights_stay_outlined;
    case 'relationships':
      return Icons.people_outline_rounded;
    case 'sadness':
      return Icons.water_drop_outlined;
    case 'lost':
      return Icons.explore_outlined;
    case 'self_doubt':
      return Icons.psychology_alt_outlined;
    case 'eating':
      return Icons.spa_outlined;
    case 'breakup':
      return Icons.favorite_border_rounded;
    default:
      return Icons.help_outline_rounded;
  }
}

// Top bar shared by all three screens: back arrow, step dots, close.
class _OnbHeader extends StatelessWidget {
  final int step; // 1..3
  final VoidCallback? onBack;
  final VoidCallback onClose;
  final bool light; // white icons over the art

  const _OnbHeader({required this.step, this.onBack, required this.onClose, this.light = false});

  @override
  Widget build(BuildContext context) {
    final iconColor = light ? Colors.white : ColorConstant.gray800;
    return SizedBox(
      height: getVerticalSize(48),
      child: Row(
        children: [
          SizedBox(
            width: getSize(48),
            child: onBack == null
                ? null
                : IconButton(
                    tooltip: 'back'.tr(),
                    icon: Icon(Icons.arrow_back_rounded, color: iconColor),
                    onPressed: onBack,
                  ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 3; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == step ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: i == step
                          ? (light ? Colors.white : ColorConstant.cyan700)
                          : (light ? Colors.white.withOpacity(0.45) : ColorConstant.cyan700.withOpacity(0.25)),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: getSize(48),
            child: IconButton(
              tooltip: 'close'.tr(),
              icon: Icon(Icons.close_rounded, color: iconColor),
              onPressed: onClose,
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingConcernScreen extends StatefulWidget {
  final bool fromSettings;
  const OnboardingConcernScreen({Key? key, this.fromSettings = false}) : super(key: key);

  @override
  State<OnboardingConcernScreen> createState() => _OnboardingConcernScreenState();
}

class _OnboardingConcernScreenState extends State<OnboardingConcernScreen> {
  OnboardingConcern? _picked;

  Future<void> _pick(OnboardingConcern c) async {
    setState(() => _picked = c);
    await OnboardingPrefs.saveConcern(c);
    // Also covers a first choice made on a later launch.
    await OnboardingPrefs.markStarted();
    await Future.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => OnboardingPracticeScreen(concern: c, fromSettings: widget.fromSettings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return WillPopScope(
      // First launch: no system back (nothing to go back to). Settings: normal.
      onWillPop: () async => widget.fromSettings,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            // Soft art fading into the page background.
            SizedBox(
              height: getVerticalSize(260),
              width: w,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/onboarding_header.jpg', fit: BoxFit.cover),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.18),
                          Colors.transparent,
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _OnbHeader(
                    step: 1,
                    light: true,
                    onBack: widget.fromSettings ? () => Navigator.pop(context) : null,
                    onClose: () => _exitFlow(context, widget.fromSettings),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: getPadding(left: 18, right: 18, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: getVerticalSize(96)),
                          Text('onb_title'.tr(), style: AppStyle.txtH1.copyWith(fontSize: getFontSize(26), height: 1.2)),
                          SizedBox(height: getVerticalSize(8)),
                          Text('onb_subtitle'.tr(),
                              style: AppStyle.txtSFProDisplayLight16
                                  .copyWith(color: ColorConstant.gray800.withOpacity(0.8))),
                          SizedBox(height: getVerticalSize(18)),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 1.45,
                            children: [
                              for (final c in OnboardingConcern.values) _concernCard(c),
                            ],
                          ),
                          SizedBox(height: getVerticalSize(6)),
                          Center(
                            child: TextButton(
                              onPressed: () => _exitFlow(context, widget.fromSettings),
                              child: Text('onb_skip'.tr(),
                                  style: AppStyle.txtSFProDisplayRegular11
                                      .copyWith(color: ColorConstant.gray500)),
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
        ),
      ),
    );
  }

  Widget _concernCard(OnboardingConcern c) {
    final selected = _picked == c;
    return Semantics(
      button: true,
      selected: selected,
      label: c.labelKey.tr(),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: _picked == null ? () => _pick(c) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: getPadding(left: 14, top: 12, right: 12, bottom: 12),
          decoration: BoxDecoration(
            color: selected ? ColorConstant.cyan700.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: selected ? ColorConstant.cyan700 : ColorConstant.cyan700.withOpacity(0.16),
                width: selected ? 1.6 : 1),
            boxShadow: [
              BoxShadow(
                color: ColorConstant.cyan700.withOpacity(selected ? 0.18 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: getSize(34),
                height: getSize(34),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorConstant.cyan700.withOpacity(0.1),
                ),
                child: Icon(_iconFor(c), size: getSize(19), color: ColorConstant.cyan700),
              ),
              Text(
                c.labelKey.tr(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppStyle.txtSFProDisplayLight14
                    .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w500, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingPracticeScreen extends StatefulWidget {
  final OnboardingConcern concern;
  final bool fromSettings;
  const OnboardingPracticeScreen({Key? key, required this.concern, this.fromSettings = false})
      : super(key: key);

  @override
  State<OnboardingPracticeScreen> createState() => _OnboardingPracticeScreenState();
}

class _OnboardingPracticeScreenState extends State<OnboardingPracticeScreen> {
  final List<_Practice> _options = [];
  _Practice? _selected;
  bool _loading = true;
  bool _failed = false;
  // The concern's course exists in the current language (courses are Russian
  // first), so the note about it is only shown when it is true.
  bool _courseAvailable = false;

  @override
  void initState() {
    super.initState();
    _load();
    final id = widget.concern.courseId;
    if (id != null) {
      CourseRepository().load(id).then((c) {
        if (mounted) setState(() => _courseAvailable = c != null);
      });
    }
  }

  Future<void> _load() async {
    // Onboarding shows its own inline note below, so the one-time dialog
    // must not interrupt the very first practice.
    await ExerciseNotice.markShown();
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

  void _back() {
    AppAudioService.instance.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OnboardingConcernScreen(fromSettings: widget.fromSettings)),
    );
  }

  Future<void> _continue() async {
    await OnboardingPrefs.markFirstPracticeDone();
    // Don't leave a track playing under the next screen.
    await AppAudioService.instance.stop();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => OnboardingFeelingScreen(fromSettings: widget.fromSettings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUnknown = widget.concern.audioDocIds.length > 1; // choose between two practices
    final hasCourse = _courseAvailable;
    final relationsNote = widget.concern.key == 'relationships' || widget.concern.key == 'breakup';
    final canContinue = !_loading && (_selected != null || _failed);
    return WillPopScope(
      onWillPop: () async {
        _back();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _OnbHeader(
                step: 2,
                onBack: _back,
                onClose: () => _exitFlow(context, widget.fromSettings),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: getPadding(left: 20, right: 20, top: 6, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('onb_practice_title'.tr(),
                          style: AppStyle.txtH1.copyWith(fontSize: getFontSize(26))),
                      SizedBox(height: getVerticalSize(8)),
                      Text(
                          hasCourse
                              ? (relationsNote ? 'onb_course_note_relations' : 'onb_course_note').tr()
                              : (isUnknown ? 'onb_unknown_note'.tr() : 'onb_practice_subtitle'.tr()),
                          style: AppStyle.txtSFProDisplayLight16
                              .copyWith(color: ColorConstant.gray800.withOpacity(0.85), height: 1.45)),
                      SizedBox(height: getVerticalSize(18)),
                      if (_loading)
                        const Center(child: CircularProgressIndicator())
                      else if (_failed)
                        Text('network_error_try_later'.tr(), style: AppStyle.txtSFProDisplayLight16)
                      else if (isUnknown && _selected == null)
                        ..._options.map(_chooserTile)
                      else if (_selected != null)
                        _player(_selected!),
                      SizedBox(height: getVerticalSize(14)),
                      Center(
                        child: Text('onb_practice_stop_note'.tr(),
                            textAlign: TextAlign.center,
                            style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
                      ),
                      const MedicalDisclaimer(compact: true),
                    ],
                  ),
                ),
              ),
              // Always visible — the content above scrolls, the button doesn't.
              Padding(
                padding: getPadding(left: 20, right: 20, top: 8, bottom: 14),
                child: CustomButton(
                  height: getVerticalSize(50),
                  width: double.infinity,
                  text: 'continue'.tr().toUpperCase(),
                  variant: ButtonVariant.Cyan,
                  fontStyle: ButtonFontStyle.White16,
                  onTap: canContinue ? _continue : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chooserTile(_Practice p) {
    return Padding(
      padding: EdgeInsets.only(bottom: getVerticalSize(10)),
      child: GestureDetector(
        onTap: () => _choose(p),
        child: Container(
          width: double.infinity,
          padding: getPadding(left: 14, top: 12, right: 16, bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ColorConstant.cyan700.withOpacity(0.18)),
            boxShadow: [BoxShadow(color: ColorConstant.cyan700.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5))],
          ),
          child: Row(
            children: [
              _cover(p, 52),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(
                child: Text(p.track.title,
                    style: AppStyle.txtSFProDisplayLight16
                        .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w500)),
              ),
              if (p.duration != null) Text(_fmt(p.duration!), style: AppStyle.txtSFProDisplayRegular11Gray800),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cover(_Practice p, double size) {
    final asset = p.track.coverAsset;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: asset != null
          ? Image.asset(asset, width: getSize(size), height: getSize(size), fit: BoxFit.cover)
          : Container(
              width: getSize(size),
              height: getSize(size),
              color: ColorConstant.cyan700.withOpacity(0.15),
              child: Icon(Icons.headphones_rounded, color: ColorConstant.cyan700),
            ),
    );
  }

  Widget _player(_Practice p) {
    final t = p.track;
    return GlassCard(
      padding: getPadding(left: 20, top: 20, right: 20, bottom: 18),
      child: ValueListenableBuilder<AppAudioState>(
        valueListenable: AppAudioService.instance.state,
        builder: (context, s, _) {
          final mine = s.isCurrent(t.id);
          final position = mine ? s.position : Duration.zero;
          final duration = mine ? s.duration : Duration.zero;
          final playing = mine && s.playing;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _cover(p, 120),
              SizedBox(height: getVerticalSize(12)),
              Text(t.title,
                  textAlign: TextAlign.center,
                  style: AppStyle.txtH1.copyWith(fontSize: getFontSize(19))),
              SizedBox(height: getVerticalSize(10)),
              Slider(
                value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
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
              SizedBox(height: getVerticalSize(8)),
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
                    decoration: BoxDecoration(shape: BoxShape.circle, color: ColorConstant.cyan700),
                    child: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white, size: getSize(30)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Practice {
  final AppAudioTrack track;
  final Duration? duration;
  _Practice(this.track, this.duration);
}

class OnboardingFeelingScreen extends StatefulWidget {
  final bool fromSettings;
  const OnboardingFeelingScreen({Key? key, this.fromSettings = false}) : super(key: key);

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
    if (widget.fromSettings) {
      Navigator.pop(context); // back to Settings; no follow-up re-scheduled
      return;
    }
    _scheduleFollowUp();
    if (_repeatLaunch) {
      goToAppAfterOnboarding(context);
    } else {
      startPostRegistrationQuizFlow(context, skipBridge: true);
    }
  }

  Future<void> _back() async {
    final concern = await OnboardingPrefs.concern();
    if (!mounted) return;
    if (concern == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => OnboardingConcernScreen(fromSettings: widget.fromSettings)));
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => OnboardingPracticeScreen(concern: concern, fromSettings: widget.fromSettings)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      ['better', 'onb_feeling_better', Icons.wb_sunny_outlined],
      ['same', 'onb_feeling_same', Icons.remove_rounded],
      ['worse', 'onb_feeling_worse', Icons.cloud_outlined],
    ];
    return WillPopScope(
      onWillPop: () async {
        _back();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              _OnbHeader(
                step: 3,
                onBack: _back,
                onClose: () => _exitFlow(context, widget.fromSettings),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: getPadding(left: 20, right: 20, top: 6, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('onb_feeling_title'.tr(),
                          style: AppStyle.txtH1.copyWith(fontSize: getFontSize(26))),
                      SizedBox(height: getVerticalSize(20)),
                      for (final o in options)
                        Padding(
                          padding: EdgeInsets.only(bottom: getVerticalSize(12)),
                          child: GestureDetector(
                            onTap: () => _pick(o[0] as String),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              padding: getPadding(left: 16, top: 16, right: 16, bottom: 16),
                              decoration: BoxDecoration(
                                color: _picked == o[0]
                                    ? ColorConstant.cyan700.withOpacity(0.12)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                    color: ColorConstant.cyan700
                                        .withOpacity(_picked == o[0] ? 0.9 : 0.16),
                                    width: _picked == o[0] ? 1.6 : 1),
                                boxShadow: [
                                  BoxShadow(
                                      color: ColorConstant.cyan700.withOpacity(0.06),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5)),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: getSize(38),
                                    height: getSize(38),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: ColorConstant.cyan700.withOpacity(0.1)),
                                    child: Icon(o[2] as IconData,
                                        size: getSize(20), color: ColorConstant.cyan700),
                                  ),
                                  SizedBox(width: getHorizontalSize(14)),
                                  Expanded(
                                    child: Text((o[1] as String).tr(),
                                        style: AppStyle.txtSFProDisplayLight16.copyWith(
                                            color: ColorConstant.gray800, fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
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
                                  style: AppStyle.txtSFProDisplayLight16
                                      .copyWith(color: ColorConstant.gray800, height: 1.45)),
                              const HelplineLink(),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: getPadding(left: 20, right: 20, top: 8, bottom: 14),
                child: CustomButton(
                  height: getVerticalSize(50),
                  width: double.infinity,
                  text: 'continue'.tr().toUpperCase(),
                  variant: ButtonVariant.Cyan,
                  fontStyle: ButtonFontStyle.White16,
                  onTap: _picked == null ? null : _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
