import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/medical_disclaimer.dart';

import 'package:riva_psy/presentation/initial_setup/onboarding/onboarding_concern.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/course_progress_store.dart';
import '../models/course.dart';
import '../widgets/course_ui.dart';
import 'course_audio_player.dart';
import 'course_insights_screen.dart';
import 'course_library_screen.dart';
import 'course_paywall_page.dart';
import 'course_step_screen.dart';
import 'course_welcome_screen.dart';
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
  bool _introOpen = false;
  // Android-only tip about the app-icon shortcut, dismissible for good.
  bool _showShortcutHint = false;
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
    if (Platform.isAndroid) {
      final prefs = await SharedPreferences.getInstance();
      if (!(prefs.getBool('shortcut_hint_dismissed_v1') ?? false) && mounted) {
        setState(() => _showShortcutHint = true);
      }
    }
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
        return;
      }
    }
    await _maybeWelcome();
  }

  // The short "how it works" pages, once per program.
  Future<void> _maybeWelcome() async {
    if (_c.welcome.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final key = 'course_welcome_seen_${_c.id}';
    if (prefs.getBool(key) ?? false) return;
    await prefs.setBool(key, true);
    if (!mounted) return;
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseWelcomeScreen(course: _c)));
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

  IconData _toolIcon(String id) {
    switch (id) {
      case 'contact':
      case 'urge':
        return Icons.spa_outlined;
      case 'after_contact':
        return Icons.refresh_rounded;
      case 'evening_plan':
      case 'evening':
        return Icons.nights_stay_outlined;
      case 'meeting':
        return Icons.people_outline_rounded;
      case 'direct_result':
        return Icons.chat_bubble_outline_rounded;
      default:
        return Icons.self_improvement_rounded;
    }
  }

  String _label(CourseStep step) => step.number == null ? step.title : '${step.number}. ${step.title}';

  @override
  Widget build(BuildContext context) => CourseTextScale(child: _buildBody(context));

  Widget _buildBody(BuildContext context) {
    final p = _progress;
    if (p == null || (!p.screened && _c.screening.isNotEmpty)) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: courseSoft(false), height: 1.55);
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary, height: 1.45);
    return Scaffold(
      backgroundColor: AppColors.background,
      // The program lives inside Рекомендации, but the course is a pushed
      // page: the app's bottom menu is shown here so there is always a way
      // to another section or the home screen.
      bottomNavigationBar: CustomBottomBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CoverHeader(
              coverAsset: _c.cover,
              height: 250,
              leftScrim: true,
              onBack: () => Navigator.pop(context),
              actions: [
                PopupMenuButton<String>(
                  tooltip: 'course_more'.tr(),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  icon: Container(
                    width: getSize(40),
                    height: getSize(40),
                    decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withOpacity(0.28)),
                    child: Icon(Icons.more_horiz_rounded, color: Colors.white, size: getSize(22)),
                  ),
                  onSelected: (v) async {
                    if (v == 'round') {
                      _newRound();
                    } else {
                      final ok = await Navigator.push<bool>(
                          context, MaterialPageRoute(builder: (_) => ScreeningScreen(course: _c)));
                      if (ok == true) _reload();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 'round', child: Text('course_new_round'.tr())),
                    PopupMenuItem(value: 'screen', child: Text('course_rescreen'.tr())),
                  ],
                ),
              ],
              // Text stays in the left ~60%: the bubble on the right is never covered.
              child: FractionallySizedBox(
                widthFactor: 0.6,
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MetaPill('course_round'.tr(namedArgs: {'n': '${p.round}'}), icon: Icons.autorenew_rounded),
                    SizedBox(height: getVerticalSize(8)),
                    Text(_c.title,
                        style: AppStyle.txtH1.copyWith(color: Colors.white, fontSize: getFontSize(24), height: 1.15)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: getPadding(left: 20, right: 20, top: 2, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: _introOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    firstChild: Text(_c.intro, maxLines: 4, overflow: TextOverflow.ellipsis, style: body),
                    secondChild: Text(_c.intro, style: body),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _introOpen = !_introOpen),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: getPadding(top: 6, bottom: 4),
                      child: Text((_introOpen ? 'course_read_less' : 'course_read_more').tr(),
                          style: AppStyle.txtSFProDisplayLight14
                              .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (_introOpen) ...[
                    SizedBox(height: getVerticalSize(6)),
                    Text(_c.paceNote, style: small),
                  ],
                  if (_c.introAudioDocId != null) ...[
                    SizedBox(height: getVerticalSize(14)),
                    CourseAudioPlayer(
                        docId: _c.introAudioDocId, listened: false, onListened: () {}, showMark: false),
                  ],
                  SizedBox(height: getVerticalSize(18)),
                  _todayCard(p),
                  SizedBox(height: getVerticalSize(26)),
                  SectionLabel('course_my_tools'.tr()),
                  SizedBox(height: getVerticalSize(12)),
                  SizedBox(
                    height: getVerticalSize(118),
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      itemCount: _c.tools.length,
                      separatorBuilder: (_, __) => SizedBox(width: getHorizontalSize(10)),
                      itemBuilder: (_, i) => _toolCard(_c.tools[i]),
                    ),
                  ),
                  if (_showShortcutHint && _c.tools.any((t) => t.id == 'contact'))
                    Padding(
                      padding: getPadding(top: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.touch_app_rounded, size: getSize(16), color: AppColors.textSecondary),
                          SizedBox(width: getHorizontalSize(8)),
                          Expanded(
                            child: Text('course_shortcut_hint'.tr(),
                                style: AppStyle.txtSFProDisplayRegular11
                                    .copyWith(color: AppColors.textSecondary, height: 1.45)),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setBool('shortcut_hint_dismissed_v1', true);
                              if (mounted) setState(() => _showShortcutHint = false);
                            },
                            child: Padding(
                              padding: getPadding(left: 8, top: 0, bottom: 4),
                              child: Icon(Icons.close_rounded, size: getSize(16), color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: getVerticalSize(18)),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _row(
                          icon: Icons.show_chart_rounded,
                          title: 'course_dynamics'.tr(),
                          subtitle: 'course_dynamics_sub'.tr(),
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => CourseInsightsScreen(course: _c))),
                        ),
                        Divider(height: 1, color: AppColors.divider, indent: getHorizontalSize(64)),
                        _row(
                          icon: Icons.bookmark_border_rounded,
                          title: 'course_my_library'.tr(),
                          subtitle: '',
                          onTap: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => CourseLibraryScreen(course: _c))),
                        ),
                      ],
                    ),
                  ),
                  for (final g in _c.groups) ..._groupSection(g, p, small),
                  if (_c.freeNote.isNotEmpty && !_isOrion)
                    Padding(padding: getPadding(top: 6), child: Text(_c.freeNote, style: small)),
                  const MedicalDisclaimer(compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: getPadding(left: 16, top: 14, right: 12, bottom: 14),
        child: Row(
          children: [
            Container(
              width: getSize(34),
              height: getSize(34),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
              child: Icon(icon, size: getSize(18), color: AppColors.primary),
            ),
            SizedBox(width: getHorizontalSize(14)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppStyle.txtSFProDisplayLight16
                          .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _toolCard(CourseTool t) {
    return SizedBox(
      width: getHorizontalSize(148),
      child: SoftCard(
        padding: getPadding(left: 14, top: 14, right: 12, bottom: 12),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => SituationToolScreen(course: _c, tool: t))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: getSize(34),
              height: getSize(34),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
              child: Icon(_toolIcon(t.id), size: getSize(18), color: AppColors.primary),
            ),
            Text(t.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: AppStyle.txtSFProDisplayLight14
                    .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.25)),
          ],
        ),
      ),
    );
  }

  Widget _todayCard(CourseProgress p) {
    final next = _nextIndex();
    final last = _lastStartedIndex();
    final step = next == null ? null : _c.steps[next];
    final cover = step == null ? null : audioCoverAsset(step.title);
    return Container(
      width: double.infinity,
      padding: getPadding(left: 18, top: 18, right: 18, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('course_today'.tr()),
          SizedBox(height: getVerticalSize(10)),
          if (step != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_label(step),
                          style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary, height: 1.2)),
                      SizedBox(height: getVerticalSize(4)),
                      Text('≈ ${step.minutes} ${'course_min'.tr()}',
                          style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                if (cover != null)
                  Padding(
                    padding: getPadding(left: 12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(cover, width: getSize(64), height: getSize(64), fit: BoxFit.cover),
                    ),
                  ),
              ],
            ),
            SizedBox(height: getVerticalSize(16)),
            CapsuleButton(label: 'course_open_step'.tr(), onTap: () => _openStep(next!)),
          ] else
            Text('course_all_done'.tr(),
                style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textPrimary, height: 1.5)),
          if (last != null && last != next)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _openStep(last),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
                child: Text('course_repeat_prev'.tr(),
                    style: AppStyle.txtSFProDisplayLight14
                        .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  // A named block of steps (the support blocks have no numbers).
  List<Widget> _groupSection(CourseGroup g, CourseProgress p, TextStyle small) {
    final idx = [for (var i = 0; i < _c.steps.length; i++) if (_c.steps[i].groupId == g.id) i];
    if (idx.isEmpty) return const [];
    return [
      SizedBox(height: getVerticalSize(28)),
      if (g.title.isNotEmpty)
        Text(g.title, style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary))
      else
        SectionLabel('course_steps_title'.tr()),
      if (g.subtitle.isNotEmpty)
        Padding(padding: getPadding(top: 4), child: Text(g.subtitle, style: small)),
      SizedBox(height: getVerticalSize(12)),
      for (final i in idx) _stepTile(i, p),
    ];
  }

  // A step as a cover card, like the program cards: the wide dark cover with
  // the picture on the right, white text on the left.
  Widget _stepTile(int i, CourseProgress p) {
    final step = _c.steps[i];
    final state = p.step(step.id);
    final locked = !step.free && !_isOrion;
    final cover = wideStepCover(audioCoverAsset(step.title));
    final meta = StringBuffer('≈ ${step.minutes} ${'course_min'.tr()}');
    if (state.complete) {
      meta.write(' · ${'course_state_done'.tr()}');
    } else if (state.started) {
      meta.write(' · ${'course_state_started'.tr()}');
    }
    const white = Colors.white;
    return Padding(
      padding: getPadding(bottom: 12),
      child: Semantics(
        button: true,
        label: _label(step),
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _openStep(i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Container(
                height: getVerticalSize(104),
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover != null)
                      Image.asset(cover, fit: BoxFit.cover)
                    else
                      Container(color: const Color(0xFF16302C)),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.0)],
                          stops: const [0.0, 0.62],
                        ),
                      ),
                    ),
                    if (locked) Container(color: Colors.black.withOpacity(0.28)),
                    Padding(
                      padding: getPadding(left: 14, right: 12),
                      child: Row(
                        children: [
                          if (step.number != null)
                            Container(
                              width: getSize(28),
                              height: getSize(28),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: state.complete ? white : Colors.transparent,
                                border: Border.all(color: white.withOpacity(0.85), width: 1.2),
                              ),
                              child: state.complete
                                  ? Icon(Icons.check_rounded, size: getSize(16), color: AppColors.primary)
                                  : Text('${step.number}',
                                      style: AppStyle.txtSFProDisplayRegular11
                                          .copyWith(color: white, fontWeight: FontWeight.w700)),
                            ),
                          if (step.number != null) SizedBox(width: getHorizontalSize(12)),
                          Expanded(
                            flex: 11,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(step.title,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyle.txtSFProDisplayLight16
                                        .copyWith(color: white, fontWeight: FontWeight.w600, height: 1.2)),
                                SizedBox(height: getVerticalSize(4)),
                                Text(meta.toString(),
                                    style: AppStyle.txtSFProDisplayRegular11
                                        .copyWith(color: white.withOpacity(0.82), letterSpacing: 0.3)),
                              ],
                            ),
                          ),
                          const Spacer(flex: 8),
                          Icon(locked ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
                              color: white.withOpacity(0.9), size: getSize(locked ? 20 : 26)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
