import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_pop_button.dart';
import 'package:riva_psy/widgets/medical_disclaimer.dart';

import 'package:riva_psy/presentation/initial_setup/onboarding/onboarding_concern.dart';

import '../data/course_progress_store.dart';
import '../models/course.dart';
import 'course_audio_player.dart';
import 'course_insights_screen.dart';
import 'course_library_screen.dart';
import 'course_paywall_page.dart';
import 'course_step_screen.dart';
import 'screening_screen.dart';
import 'situation_tool_screen.dart';

// The course home: one clear "today" card, the steps, the always-open tools
// and the personal library. No percentages, no streaks — a skipped day is
// not a failure. New steps are paced (max 2 a day); repeats, the tools and
// help are never limited.
class CourseScreen extends StatefulWidget {
  final Course course;
  const CourseScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  CourseProgress? _progress;
  // The onboarding answer, used to choose which block "today" starts in.
  String? _concernKey;

  Course get _c => widget.course;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _concernKey = (await OnboardingPrefs.concern())?.key;
    final p = await CourseProgressStore.load(_c.id);
    if (!mounted) return;
    setState(() => _progress = p);
    if (!p.screened && _c.screening.isNotEmpty) {
      final ok = await Navigator.push<bool>(
          context, MaterialPageRoute(builder: (_) => ScreeningScreen(course: _c)));
      if (!mounted) return;
      if (ok == true) {
        p.screened = true;
        await CourseProgressStore.save(_c.id, p);
        if (mounted) setState(() {});
      } else {
        Navigator.pop(context);
      }
    }
  }

  Future<void> _reload() async {
    final p = await CourseProgressStore.load(_c.id);
    if (mounted) setState(() => _progress = p);
  }

  bool get _isOrion => CurrentUser.tariffIsOrion();

  Future<void> _openStep(int index) async {
    final step = _c.steps[index];
    final p = _progress!;
    if (!step.free && !_isOrion) {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursePaywallPage()));
      return;
    }
    if (!p.canOpen(step.id, alwaysAvailable: step.alwaysAvailable, maxPerDay: _c.maxNewPerDay)) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Text((_c.maxNewPerDay == 1 ? 'course_limit_one' : 'course_limit').tr()),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text('helpnow_notice_ok'.tr()))],
        ),
      );
      return;
    }
    p.markOpened(step.id, alwaysAvailable: step.alwaysAvailable);
    await CourseProgressStore.save(_c.id, p);
    if (!mounted) return;
    await Navigator.push(
        context, MaterialPageRoute(builder: (_) => CourseStepScreen(course: _c, step: step, index: index)));
    _reload();
  }

  // The block "today" works in: where the person last started something,
  // otherwise the block that matches their onboarding answer, otherwise the
  // first suggested block. Blocks that are finished are skipped.
  int? _nextIndex() {
    final p = _progress!;
    bool blockDone(String id) => _c.steps
        .where((s) => s.groupId == id)
        .every((s) => p.step(s.id).complete);
    final suggested = _c.groups.where((g) => g.suggest && _c.steps.any((s) => s.groupId == g.id)).toList();
    if (suggested.isEmpty) return null;
    String? lastStartedBlock;
    for (final s in _c.steps) {
      if (_c.groupOf(s).suggest && p.step(s.id).started) lastStartedBlock = s.groupId;
    }
    CourseGroup? first;
    if (lastStartedBlock != null && !blockDone(lastStartedBlock)) {
      first = suggested.firstWhere((g) => g.id == lastStartedBlock);
    } else {
      final byConcern = suggested.where((g) => g.startConcerns.contains(_concernKey) && !blockDone(g.id));
      first = byConcern.isNotEmpty ? byConcern.first : null;
    }
    final order = [if (first != null) first, ...suggested.where((g) => g != first)];
    for (final g in order) {
      for (var i = 0; i < _c.steps.length; i++) {
        if (_c.steps[i].groupId == g.id && !p.step(_c.steps[i].id).complete) return i;
      }
    }
    return null;
  }

  int? _lastStartedIndex() {
    final p = _progress!;
    int? last;
    for (var i = 0; i < _c.steps.length; i++) {
      if (!_c.groupOf(_c.steps[i]).suggest) continue;
      if (p.step(_c.steps[i].id).started) last = i;
    }
    return last;
  }

  Future<void> _newRound() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text('course_new_round_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('yes'.tr())),
        ],
      ),
    );
    if (ok != true) return;
    final fresh = await CourseProgressStore.newRound(_c.id, _progress!);
    if (mounted) setState(() => _progress = fresh);
  }

  Widget _stateChip(CourseStepState s, bool locked) {
    String? key;
    if (locked) {
      return Icon(Icons.lock_outline_rounded, size: getSize(16), color: ColorConstant.gray500);
    }
    if (s.complete) {
      key = 'course_state_done';
    } else if (s.started) {
      key = 'course_state_started';
    }
    if (key == null) return const SizedBox.shrink();
    return Text(key.tr(),
        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.cyan700));
  }

  @override
  Widget build(BuildContext context) {
    final p = _progress;
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5);
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500, height: 1.4);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: p == null || (!p.screened && _c.screening.isNotEmpty)
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: getPadding(left: 16, right: 16, top: 12, bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPopButton(text: 'gaining'.tr()),
                    SizedBox(height: getVerticalSize(14)),
                    if (_c.cover != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(_c.cover!, height: getVerticalSize(150), width: double.infinity, fit: BoxFit.cover),
                      ),
                    SizedBox(height: getVerticalSize(14)),
                    Text(_c.title, style: AppStyle.txtH1),
                    SizedBox(height: getVerticalSize(4)),
                    Text('course_round'.tr(namedArgs: {'n': '${p.round}'}), style: small),
                    SizedBox(height: getVerticalSize(10)),
                    Text(_c.intro, style: body),
                    SizedBox(height: getVerticalSize(10)),
                    Text(_c.paceNote, style: small),
                    if (_c.introAudioDocId != null) ...[
                      SizedBox(height: getVerticalSize(14)),
                      Text('course_intro_audio'.tr(), style: small.copyWith(color: ColorConstant.cyan700)),
                      CourseAudioPlayer(
                          docId: _c.introAudioDocId, listened: false, onListened: () {}, showMark: false),
                    ],
                    SizedBox(height: getVerticalSize(18)),
                    _todayCard(p, body, small),
                    SizedBox(height: getVerticalSize(18)),
                    Text('course_my_tools'.tr().toUpperCase(),
                        style: small.copyWith(color: ColorConstant.cyan700, letterSpacing: 0.5)),
                    SizedBox(height: getVerticalSize(8)),
                    for (final t in _c.tools)
                      _tile(
                        title: t.title,
                        subtitle: t.subtitle,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => SituationToolScreen(course: _c, tool: t))),
                      ),
                    _tile(
                      title: 'course_dynamics'.tr(),
                      subtitle: 'course_dynamics_sub'.tr(),
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => CourseInsightsScreen(course: _c))),
                    ),
                    _tile(
                      title: 'course_my_library'.tr(),
                      subtitle: '',
                      onTap: () => Navigator.push(
                          context, MaterialPageRoute(builder: (_) => CourseLibraryScreen(course: _c))),
                    ),
                    SizedBox(height: getVerticalSize(18)),
                    Text('course_steps_title'.tr().toUpperCase(),
                        style: small.copyWith(color: ColorConstant.cyan700, letterSpacing: 0.5)),
                    SizedBox(height: getVerticalSize(8)),
                    for (final g in _c.groups) ..._groupSection(g, p),
                    if (_c.freeNote.isNotEmpty && !_isOrion)
                      Padding(padding: getPadding(top: 4), child: Text(_c.freeNote, style: small)),
                    SizedBox(height: getVerticalSize(18)),
                    Center(
                      child: TextButton(
                        onPressed: _newRound,
                        child: Text('course_new_round'.tr(),
                            style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () async {
                          final ok = await Navigator.push<bool>(context,
                              MaterialPageRoute(builder: (_) => ScreeningScreen(course: _c)));
                          if (ok == true) _reload();
                        },
                        child: Text('course_rescreen'.tr(), style: small),
                      ),
                    ),
                    const MedicalDisclaimer(compact: true),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _todayCard(CourseProgress p, TextStyle body, TextStyle small) {
    final next = _nextIndex();
    final last = _lastStartedIndex();
    return Container(
      width: double.infinity,
      padding: getPadding(left: 16, top: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorConstant.cyan700.withOpacity(0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('course_today'.tr().toUpperCase(),
              style: small.copyWith(color: ColorConstant.cyan700, letterSpacing: 0.6)),
          SizedBox(height: getVerticalSize(6)),
          if (next != null) ...[
            Text(_label(_c.steps[next]),
                style: body.copyWith(fontWeight: FontWeight.w600)),
            SizedBox(height: getVerticalSize(2)),
            Text('≈ ${_c.steps[next].minutes} ${'course_min'.tr()}', style: small),
            SizedBox(height: getVerticalSize(12)),
            CustomButton(
              height: getVerticalSize(46),
              width: double.infinity,
              text: 'course_open_step'.tr().toUpperCase(),
              variant: ButtonVariant.Cyan,
              fontStyle: ButtonFontStyle.White16,
              onTap: () => _openStep(next),
            ),
          ] else
            Text('course_all_done'.tr(), style: body),
          if (last != null && last != next)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _openStep(last),
                child: Text('course_repeat_prev'.tr(),
                    style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.cyan700)),
              ),
            ),
        ],
      ),
    );
  }

  String _label(CourseStep step) => step.number == null ? step.title : '${step.number}. ${step.title}';

  // A named block of steps (the support blocks have no numbers).
  List<Widget> _groupSection(CourseGroup g, CourseProgress p) {
    final idx = [for (var i = 0; i < _c.steps.length; i++) if (_c.steps[i].groupId == g.id) i];
    if (idx.isEmpty) return const [];
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500, height: 1.4);
    return [
      if (g.title.isNotEmpty) ...[
        SizedBox(height: getVerticalSize(8)),
        Text(g.title,
            style: AppStyle.txtSFProDisplayLight16
                .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w700)),
        if (g.subtitle.isNotEmpty) Padding(padding: getPadding(top: 2, bottom: 8), child: Text(g.subtitle, style: small)),
      ],
      for (final i in idx) _stepTile(i, p),
    ];
  }

  Widget _stepTile(int i, CourseProgress p) {
    final step = _c.steps[i];
    final locked = !step.free && !_isOrion;
    return _tile(
      title: _label(step),
      subtitle: '≈ ${step.minutes} ${'course_min'.tr()}',
      trailing: _stateChip(p.step(step.id), locked),
      onTap: () => _openStep(i),
    );
  }

  Widget _tile({required String title, required String subtitle, VoidCallback? onTap, Widget? trailing}) {
    return Padding(
      padding: getPadding(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: getPadding(left: 16, top: 13, right: 12, bottom: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ColorConstant.cyan700.withOpacity(0.18)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w600)),
                    if (subtitle.isNotEmpty)
                      Text(subtitle,
                          style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
                  ],
                ),
              ),
              if (trailing != null) trailing else Icon(Icons.chevron_right_rounded, color: ColorConstant.cyan700),
            ],
          ),
        ),
      ),
    );
  }
}
