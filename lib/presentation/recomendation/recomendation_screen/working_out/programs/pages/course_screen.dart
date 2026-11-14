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
        // Closes this course page (the screening already closed itself).
        if (Navigator.canPop(context)) Navigator.pop(context);
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
    final nextIdx = _nextIndex();
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
                RoundIconButton(
                    icon: Icons.info_outline_rounded, onTap: _openInfo, tooltip: 'course_important'.tr()),
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
                widthFactor: 0.72,
                alignment: Alignment.centerLeft,
                // Just the (short) name, larger but still light (not bolder).
                // The full name is at the top of the "about" panel.
                child: Text(_c.cardTitle,
                    style: AppStyle.txtH1.copyWith(
                        color: Colors.white,
                        fontSize: getFontSize(30),
                        fontWeight: FontWeight.w300,
                        height: 1.14)),
              ),
            ),
            Padding(
              padding: getPadding(left: 20, right: 20, top: 2, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_c.intro, maxLines: 2, overflow: TextOverflow.ellipsis, style: body),
                  GestureDetector(
                    onTap: _openInfo,
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: getPadding(top: 6, bottom: 4),
                      child: Text('course_read_more'.tr(),
                          style: AppStyle.txtSFProDisplayLight14
                              .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  if (_c.introAudioDocId != null) ...[
                    SizedBox(height: getVerticalSize(14)),
                    CourseAudioPlayer(
                        docId: _c.introAudioDocId, listened: false, onListened: () {}, showMark: false),
                  ],
                  SizedBox(height: getVerticalSize(18)),
                  _todayCard(p),
                  SizedBox(height: getVerticalSize(34)),
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
                  SizedBox(height: getVerticalSize(22)),
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
                  for (final g in _c.groups) ..._groupSection(g, p, small, nextIdx),
                  if (_c.freeNote.isNotEmpty && !_isOrion)
                    Padding(padding: getPadding(top: 10), child: Text(_c.freeNote, style: small)),
                  // The long "not a diagnosis / helplines / sources" text lives in the
                  // panel that slides down from the top; this is just the way to it.
                  Center(
                    child: TextButton.icon(
                      onPressed: _openInfo,
                      icon: Icon(Icons.info_outline_rounded, size: getSize(16), color: AppColors.textSecondary),
                      label: Text('course_important'.tr(),
                          style: AppStyle.txtSFProDisplayLight14.copyWith(color: AppColors.textSecondary)),
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

  // "Today": the one thing to do now. A large card of its own — the step's
  // artwork behind, its number, its name, one line on what it is, and a big
  // button — so it is clear at a glance that THIS is what to do today.
  Widget _todayCard(CourseProgress p) {
    final next = _nextIndex();
    final last = _lastStartedIndex();
    if (next == null) {
      return Container(
        width: double.infinity,
        padding: getPadding(left: 18, top: 18, right: 18, bottom: 16),
        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(24)),
        child: Text('course_all_done'.tr(),
            style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textPrimary, height: 1.5)),
      );
    }
    final step = _c.steps[next];
    final cover = wideStepCover(audioCoverAsset(step.coverKey));
    final total = _c.steps.where((s) => s.number != null).length;
    final locked = !step.free && !_isOrion;
    const white = Colors.white;
    final pill = StringBuffer('course_today'.tr().toUpperCase());
    if (step.number != null && total > 0) pill.write('  ·  ${step.number} / $total');
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: getVerticalSize(330)),
        decoration: BoxDecoration(
          color: const Color(0xFF16302C),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            if (cover != null) Positioned.fill(child: Image.asset(cover, fit: BoxFit.cover)),
            // Dark at the bottom where the text sits, the artwork stays visible above.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.10), Colors.black.withOpacity(0.35), Colors.black.withOpacity(0.82)],
                    stops: const [0.0, 0.38, 1.0],
                  ),
                ),
              ),
            ),
            Padding(
              padding: getPadding(left: 22, top: 20, right: 22, bottom: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: getPadding(left: 12, right: 14, top: 6, bottom: 6),
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(pill.toString(),
                        style: AppStyle.txtSFProDisplayRegular11
                            .copyWith(color: white, letterSpacing: 1.2, fontWeight: FontWeight.w600)),
                  ),
                  SizedBox(height: getVerticalSize(104)),
                  Text(step.title,
                      style: AppStyle.txtH1.copyWith(
                          color: white, fontSize: getFontSize(28), fontWeight: FontWeight.w300, height: 1.15)),
                  if (step.card.isNotEmpty) ...[
                    SizedBox(height: getVerticalSize(10)),
                    Text(step.card,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayLight14.copyWith(color: white.withOpacity(0.86), height: 1.45)),
                  ],
                  SizedBox(height: getVerticalSize(20)),
                  Semantics(
                    button: true,
                    label: 'course_open_step'.tr(),
                    excludeSemantics: true,
                    child: GestureDetector(
                      onTap: () => _openStep(next),
                      child: Container(
                        height: getVerticalSize(54),
                        width: double.infinity,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: white, borderRadius: BorderRadius.circular(30)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(locked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
                                color: AppColors.primary, size: getSize(22)),
                            SizedBox(width: getHorizontalSize(8)),
                            Flexible(
                              child: Text('course_open_step'.tr(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppStyle.txtSFProDisplayLight16
                                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (last != null && last != next)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () => _openStep(last),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 40)),
                        child: Text('course_repeat_prev'.tr(),
                            style: AppStyle.txtSFProDisplayLight14
                                .copyWith(color: white.withOpacity(0.9), fontWeight: FontWeight.w600)),
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

  // A named block of steps (the support blocks have no numbers).
  List<Widget> _groupSection(CourseGroup g, CourseProgress p, TextStyle small, int? nextIdx) {
    final idx = [for (var i = 0; i < _c.steps.length; i++) if (_c.steps[i].groupId == g.id) i];
    if (idx.isEmpty) return const [];
    return [
      SizedBox(height: getVerticalSize(38)),
      if (g.title.isNotEmpty)
        Text(g.title, style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary))
      else
        SectionLabel('course_steps_title'.tr()),
      if (g.subtitle.isNotEmpty)
        Padding(padding: getPadding(top: 4), child: Text(g.subtitle, style: small)),
      if (g.numbered)
        Builder(builder: (_) {
          final done = idx.where((i) => p.step(_c.steps[i].id).complete).length;
          return Padding(
            padding: getPadding(top: 12),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: idx.isEmpty ? 0 : done / idx.length,
                      minHeight: 3,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
                SizedBox(width: getHorizontalSize(12)),
                Text('course_progress_of'.tr(namedArgs: {'done': '$done', 'total': '${idx.length}'}), style: small),
              ],
            ),
          );
        }),
      SizedBox(height: getVerticalSize(16)),
      for (final i in idx) _stepTile(i, p, isNext: i == nextIdx),
    ];
  }

  // A step as a cover card, like the program cards: the wide dark cover with
  // the picture on the right, white text on the left.
  Widget _stepTile(int i, CourseProgress p, {bool isNext = false}) {
    final step = _c.steps[i];
    final state = p.step(step.id);
    final locked = !step.free && !_isOrion;
    final cover = wideStepCover(audioCoverAsset(step.coverKey));
    // No duration any more: only where the person is with this step.
    final meta = state.complete
        ? 'course_state_done'.tr()
        : state.started
            ? 'course_state_started'.tr()
            : '';
    const white = Colors.white;
    return Padding(
      padding: getPadding(bottom: 14),
      child: Opacity(
        // Finished steps recede a little so the eye goes to what is next.
        opacity: state.complete ? 0.78 : 1.0,
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
                // At least the designed height; grows when the title takes three
                // lines (long Spanish names) instead of overflowing.
                constraints: BoxConstraints(minHeight: getVerticalSize(104)),
                decoration: BoxDecoration(
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 14, offset: const Offset(0, 5))],
                ),
                // A fine light ring marks the step that is next.
                foregroundDecoration: isNext
                    ? BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.6))
                    : null,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: cover != null
                          ? Image.asset(cover, fit: BoxFit.cover)
                          : Container(color: const Color(0xFF16302C)),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Colors.black.withOpacity(0.6), Colors.black.withOpacity(0.0)],
                            stops: const [0.0, 0.62],
                          ),
                        ),
                      ),
                    ),
                    if (locked) Positioned.fill(child: Container(color: Colors.black.withOpacity(0.28))),
                    Padding(
                      padding: getPadding(left: 14, right: 12, top: 14, bottom: 14),
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
                            flex: 14,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Never cut a title short: the tile grows instead.
                                Text(step.title,
                                    style: AppStyle.txtSFProDisplayLight16
                                        .copyWith(color: white, fontWeight: FontWeight.w600, height: 1.2)),
                                if (meta.isNotEmpty) ...[
                                  SizedBox(height: getVerticalSize(4)),
                                  Text(meta,
                                      style: AppStyle.txtSFProDisplayRegular11
                                          .copyWith(color: white.withOpacity(0.82), letterSpacing: 0.3)),
                                ],
                              ],
                            ),
                          ),
                          const Spacer(flex: 5),
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
      ),
    );
  }

  // The "about / not a diagnosis / helplines / sources" panel: slides down from
  // the top, over a light veil, and closes on a tap outside or on the cross.
  void _openInfo() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'close'.tr(),
      barrierColor: Colors.black.withOpacity(0.32),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, _, __) => CourseTextScale(
        child: Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.86),
              child: SafeArea(
                bottom: false,
                child: SingleChildScrollView(
                  padding: getPadding(left: 22, right: 22, top: 8, bottom: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: SectionLabel('course_about_title'.tr())),
                          IconButton(
                            tooltip: 'close'.tr(),
                            onPressed: () => Navigator.pop(ctx),
                            icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: getVerticalSize(2)),
                      Text(_c.title, style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary, height: 1.2)),
                      // Safety first: what this is not, and where to find help.
                      const MedicalDisclaimer(),
                      SizedBox(height: getVerticalSize(10)),
                      Divider(height: 1, color: AppColors.divider),
                      SizedBox(height: getVerticalSize(16)),
                      Text(_c.intro,
                          style: AppStyle.txtSFProDisplayLight14
                              .copyWith(color: courseSoft(false), height: 1.5)),
                      if (_c.paceNote.isNotEmpty) ...[
                        SizedBox(height: getVerticalSize(12)),
                        Text(_c.paceNote,
                            style: AppStyle.txtSFProDisplayRegular11
                                .copyWith(color: AppColors.textSecondary, height: 1.5)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (ctx, anim, _, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );
  }
}
