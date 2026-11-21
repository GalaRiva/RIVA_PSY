import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';
import 'package:riva_psy/presentation/settings/help_now_screen/help_now_screen.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';
import 'package:riva_psy/core/user_data/user.dart';

import '../data/course_flow.dart';
import '../data/course_progress_store.dart';
import '../models/course.dart';
import '../widgets/course_sheets.dart';
import 'course_audio_player.dart';
import 'situation_tool_screen.dart';
import 'course_checkin.dart';
import 'form_task_screen.dart';
import 'night_box_screen.dart';
import '../widgets/course_ui.dart';
import '../widgets/course_basis.dart';
import '../widgets/daily_thought_card.dart';


// One step: audio -> task -> small practices for the next days. Opening a
// step records it for the daily pace (done by CourseScreen before pushing).
class CourseStepScreen extends StatefulWidget {
  final Course course;
  final CourseStep step;
  final int index;

  const CourseStepScreen({Key? key, required this.course, required this.step, required this.index})
      : super(key: key);

  @override
  State<CourseStepScreen> createState() => _CourseStepScreenState();
}

class _CourseStepScreenState extends State<CourseStepScreen> {
  CourseProgress? _progress;
  final _scroll = ScrollController();
  final _taskKey = GlobalKey();
  final _audioKey = GlobalKey();
  final _microKey = GlobalKey();
  final _dailyKey = GlobalKey();
  // Reading cards folded into one line until opened (courses with `micro_read`).
  bool? _microSecOpen;
  int _dailyCount = 0;
  // Soft glow around the task card after the audio ends.
  bool _glow = false;
  // Soft glow around the player when the big button says "listen".
  bool _audioGlow = false;
  // The step description is shown as three lines, opened on request.
  bool _descOpen = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  // After the audio (and the "how are you now?" check) the task is brought
  // into view and glows briefly — the task is what turns listening into a
  // skill, and it is easy to miss below the fold.
  Future<void> _focusTask() async {
    if (_progress == null || _state.taskDone || widget.step.night) return;
    await Future.delayed(const Duration(milliseconds: 350));
    final ctx = _taskKey.currentContext;
    if (!mounted || ctx == null) return;
    await Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 550), curve: Curves.easeInOut, alignment: 0.15);
    for (var i = 0; i < 3 && mounted; i++) {
      setState(() => _glow = true);
      await Future.delayed(const Duration(milliseconds: 650));
      if (!mounted) return;
      setState(() => _glow = false);
      await Future.delayed(const Duration(milliseconds: 450));
    }
  }

  @override
  void initState() {
    super.initState();
    CourseProgressStore.load(widget.course.id).then((p) {
      if (mounted) setState(() => _progress = p);
    });
  }

  // First sentence of the description: enough to know what the week is about
  // without opening it. Short descriptions are shown whole.
  String _lead(String card) {
    if (card.length <= 140) return card;
    final m = RegExp(r'^.{20,}?[.!?](?=\s)').firstMatch(card);
    final first = m?.group(0) ?? card;
    return first.length < card.length ? first : card;
  }

  CourseStepState get _state => _progress!.step(widget.step.id);

  // Reading cards the course requires before the step counts as done (the
  // "what this course is not" texts): the step cannot finish without them.
  int get _unreadRequired => widget.step.micro.where((m) => m.required && !_state.microDone.contains(m.id)).length;

  Future<void> _focusMicro() async {
    if (widget.course.microRead && _microSecOpen != true) {
      setState(() => _microSecOpen = true);
      await Future.delayed(const Duration(milliseconds: 80));
    }
    final ctx = _microKey.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut, alignment: 0.05);
  }

  Future<void> _persist() async {
    await CourseProgressStore.save(widget.course.id, _progress!);
    if (mounted) setState(() {});
  }

  Future<void> _openTask() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => widget.step.special == 'night_box'
            ? NightBoxScreen(course: widget.course)
            : FormTaskScreen(
                courseId: widget.course.id,
                task: widget.step.task,
                round: _progress!.round,
                course: widget.course,
                stepTitle: widget.step.title,
              ),
      ),
    );
    if (saved == true) {
      _state.taskDone = true;
      await _persist();
      if (_state.complete) {
        await _showDone();
      } else if (_unreadRequired > 0 && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('course_read_required_snack'.tr())));
        await _focusMicro();
      }
    }
  }

  // "Step complete": a calm moment with the next step offered. Only when both
  // the audio and the task are done.
  Future<void> _showDone() async {
    final p = _progress;
    final c = widget.course;
    if (p == null || !mounted || !_state.complete) return;
    final i = nextStepIndexAfter(c, p, widget.index);
    final n = i == null ? null : c.steps[i];
    await showStepDoneSheet(
      context: context,
      course: c,
      next: n,
      nextBlocked: n != null && stepBlockedByPace(c, p, n) && !CurrentUser.debugUnlockPace,
      nextLocked: n != null && !n.free && !CurrentUser.tariffIsOrion(),
      onOpenNext: () {
        if (i != null && mounted) Navigator.pop(context, i);
      },
    );
  }

  // The big button says "listen": bring the player into view and let it glow.
  Future<void> _focusAudio() async {
    final ctx = _audioKey.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(ctx,
        duration: const Duration(milliseconds: 450), curve: Curves.easeInOut, alignment: 0.2);
    for (var i = 0; i < 2 && mounted; i++) {
      setState(() => _audioGlow = true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _audioGlow = false);
      await Future.delayed(const Duration(milliseconds: 400));
    }
  }

  // After every play-through: a quiet "how are you now?" check (not on the
  // night audio — the person may already be asleep), and the optional
  // follow-up notification some minutes later.
  Future<void> _onAudioFinished() async {
    final step = widget.step;
    if (step.followUpMinutes != null) {
      try {
        await AwesomeNotificationService().scheduleOneOff(
          idKey: 'course_followup_${widget.course.id}_${step.id}',
          at: DateTime.now().add(Duration(minutes: step.followUpMinutes!)),
          title: step.followUpTitle.isEmpty ? widget.course.title : step.followUpTitle,
          body: step.followUpBody,
          askPermission: false,
        );
      } catch (_) {}
    }
    if (step.night || !mounted || _progress == null) return;
    await showCourseCheckin(
      context: context,
      course: widget.course,
      progress: _progress!,
      onOpenStep: _openOtherStep,
    );
    if (!mounted) return;
    setState(() {});
    // Only nudge towards the task when the person is not having a hard time.
    if (_progress!.worseStreak == 0) _focusTask();
  }

  // From the "worse" answer: the calm practice, opened in place of this step.
  void _openOtherStep(String stepId) {
    final i = widget.course.steps.indexWhere((s) => s.id == stepId);
    if (i < 0) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (_) => CourseStepScreen(course: widget.course, step: widget.course.steps[i], index: i)),
    );
  }

  // Three status chips — Audio, Task, Every day — that say at a glance what is
  // done; each one is a shortcut to its part of the page.
  Widget _chips(bool dark) {
    final accent = courseAccent(dark);
    final step = widget.step;
    final c = widget.course;
    Widget chip(IconData icon, String labelKey, String status, bool done, VoidCallback onTap, {bool partial = false}) {
      final on = done || partial;
      return Expanded(
        child: Semantics(
          button: true,
          label: '${labelKey.tr()}, $status',
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 88),
              padding: getPadding(left: 10, top: 10, right: 8, bottom: 10),
              decoration: BoxDecoration(
                color: done
                    ? accent.withOpacity(0.14)
                    : (dark ? Colors.white.withOpacity(0.06) : AppColors.surface),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: on ? accent.withOpacity(0.55) : (dark ? Colors.white12 : AppColors.divider)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, size: getSize(20), color: on ? accent : courseMuted(dark)),
                      const Spacer(),
                      if (done) Icon(Icons.check_circle_rounded, size: getSize(18), color: accent),
                    ],
                  ),
                  SizedBox(height: getVerticalSize(6)),
                  Text(labelKey.tr(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: courseBody().copyWith(
                          color: courseText(dark), fontWeight: FontWeight.w600, height: 1.2)),
                  SizedBox(height: getVerticalSize(2)),
                  Text(status,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: courseCaption().copyWith(color: on ? accent : courseMuted(dark), height: 1.25)),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final items = <Widget>[
      chip(Icons.headphones_rounded, 'course_chip_audio', (_state.audioDone ? 'course_chip_done' : 'course_chip_todo').tr(),
          _state.audioDone, _focusAudio),
      chip(Icons.edit_outlined, 'course_chip_task', (_state.taskDone ? 'course_chip_done' : 'course_chip_todo').tr(),
          _state.taskDone, () async {
        final ctx = _taskKey.currentContext;
        if (ctx != null) {
          await Scrollable.ensureVisible(ctx,
              duration: const Duration(milliseconds: 450), curve: Curves.easeInOut, alignment: 0.1);
        }
      }),
      if (c.dailyThought && step.number != null)
        chip(Icons.edit_note_rounded, 'course_chip_daily',
            'course_chip_daily_n'.tr(namedArgs: {'n': '$_dailyCount'}), _dailyCount >= 3, () async {
          final ctx = _dailyKey.currentContext;
          if (ctx != null) {
            await Scrollable.ensureVisible(ctx,
                duration: const Duration(milliseconds: 450), curve: Curves.easeInOut, alignment: 0.1);
          }
        }, partial: _dailyCount > 0)
      else if (step.micro.isNotEmpty && !c.microRead)
        chip(Icons.event_note_outlined, 'course_part_days_short',
            (step.micro.every((m) => _state.microDone.contains(m.id)) ? 'course_chip_done' : 'course_chip_todo').tr(),
            step.micro.every((m) => _state.microDone.contains(m.id)), () {}),
    ];
    // Equal height chips: IntrinsicHeight, because the page scrolls (no bounded height).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: getHorizontalSize(8)),
            items[i],
          ],
        ],
      ),
    );
  }

  // The reading cards as one line "Коротко о главном · прочитано 2 из 5" that opens
  // the cards. Open by itself while a required card is still unread.
  Widget _microSection(bool dark) {
    final step = widget.step;
    final accent = courseAccent(dark);
    final done = step.micro.where((m) => _state.microDone.contains(m.id)).length;
    final open = _microSecOpen ?? (_unreadRequired > 0);
    return Column(
      key: _microKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftCard(
          dark: dark,
          padding: getPadding(left: 16, top: 12, right: 10, bottom: 12),
          onTap: () => setState(() => _microSecOpen = !open),
          child: Row(
            children: [
              Icon(Icons.menu_book_outlined, size: getSize(22), color: accent),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('course_micro_summary'.tr(),
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: courseText(dark), fontWeight: FontWeight.w600)),
                    Text(
                        'course_micro_summary_n'.tr(namedArgs: {'done': '$done', 'total': '${step.micro.length}'}) +
                            (_unreadRequired > 0 ? '  ·  ' + 'course_micro_required'.tr() : ''),
                        style: courseCaption().copyWith(color: _unreadRequired > 0 ? accent : courseMuted(dark))),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: open ? 0.5 : 0,
                duration: const Duration(milliseconds: 220),
                child: Icon(Icons.expand_more_rounded, color: courseMuted(dark), size: getSize(26)),
              ),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: open
              ? Padding(
                  padding: getPadding(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('course_micro_hint_read'.tr(),
                          style: courseCaption().copyWith(color: courseMuted(dark), height: 1.45)),
                      SizedBox(height: getVerticalSize(10)),
                      for (final m in step.micro) _micro(m, dark),
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }

  // "Urgent help" / "I do not feel safe": quiet, but with a comfortable touch
  // target (about 48 px high), since these are the safety links.
  Widget _help(bool dark) {
    final color = courseMuted(dark);
    Widget link(String key) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpNowScreen())),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: getPadding(right: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: Text(key.tr(),
                    style: courseCaption().copyWith(color: color, decoration: TextDecoration.underline, decorationColor: color)),
              ),
            ),
          ),
        );
    return Wrap(children: [link('course_urgent_help'), link('course_unsafe')]);
  }

  // Reading/practice cards. Tapping a card marks it; a marked card folds
  // into one line "Прочитано" (tap to open it again, with a way to un-mark).
  final Set<String> _microOpen = {};

  Widget _micro(CourseMicro m, bool dark) {
    final done = _state.microDone.contains(m.id);
    final open = !done || _microOpen.contains(m.id);
    final accent = courseAccent(dark);
    final doneKey = widget.course.microRead ? 'course_micro_read' : 'course_micro_marked';
    return Padding(
      padding: getPadding(bottom: 10),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: SoftCard(
          dark: dark,
          padding: getPadding(left: 16, top: 14, right: 12, bottom: open ? 14 : 12),
          onTap: () {
            if (!done) {
              final was = _state.complete;
              _state.microDone.add(m.id);
              _microOpen.remove(m.id);
              _persist().then((_) {
                // The last required card read: the step is complete now.
                if (!was && _state.complete) _showDone();
              });
            } else {
              setState(() => _microOpen.contains(m.id) ? _microOpen.remove(m.id) : _microOpen.add(m.id));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title,
                            style: AppStyle.txtSFProDisplayLight16.copyWith(
                                color: done ? courseSoft(dark) : courseText(dark), fontWeight: FontWeight.w600)),
                        if (done) ...[
                          SizedBox(height: getVerticalSize(2)),
                          Text(doneKey.tr(), style: courseCaption().copyWith(color: accent)),
                        ] else ...[
                          if (m.required) ...[
                            SizedBox(height: getVerticalSize(2)),
                            Text('course_micro_required'.tr(),
                                style: courseCaption().copyWith(color: accent, fontWeight: FontWeight.w700)),
                          ],
                          SizedBox(height: getVerticalSize(4)),
                          Text(m.body,
                              style: courseBody().copyWith(color: courseSoft(dark), height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(width: getHorizontalSize(10)),
                  Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: getSize(24), color: done ? accent : courseMuted(dark)),
                ],
              ),
              if (done && open) ...[
                SizedBox(height: getVerticalSize(8)),
                Text(m.body, style: courseBody().copyWith(color: courseSoft(dark), height: 1.5)),
                SizedBox(height: getVerticalSize(4)),
                // The reading marks of the safety texts cannot be taken back:
                // they record that the person has read what the course is not.
                if (!widget.course.microRead) GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _state.microDone.remove(m.id);
                    _microOpen.remove(m.id);
                    _persist();
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 44),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: Text('course_micro_unmark'.tr(),
                          style: courseCaption().copyWith(
                              color: courseMuted(dark),
                              decoration: TextDecoration.underline,
                              decorationColor: courseMuted(dark))),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // The big button at the bottom always says the one next thing to do.
  Widget _bottomBar(bool dark) {
    final c = widget.course;
    final p = _progress!;
    final s = _state;
    final next = nextStepIndexAfter(c, p, widget.index);
    final String label;
    final IconData icon;
    final VoidCallback onTap;
    if (!s.audioDone) {
      label = 'course_cta_listen';
      icon = Icons.headphones_rounded;
      onTap = _focusAudio;
    } else if (!s.taskDone) {
      label = 'course_task_open';
      icon = Icons.edit_outlined;
      onTap = _openTask;
    } else if (_unreadRequired > 0) {
      label = 'course_cta_read';
      icon = Icons.menu_book_outlined;
      onTap = _focusMicro;
    } else if (next != null) {
      label = 'course_next_step';
      icon = Icons.arrow_forward_rounded;
      onTap = () => Navigator.pop(context, next);
    } else {
      label = 'course_cta_done';
      icon = Icons.check_rounded;
      onTap = () => Navigator.pop(context);
    }
    final urge = urgeTool(c);
    final accent = courseAccent(dark);
    return Container(
      decoration: BoxDecoration(
        color: dark ? kNightBg : AppColors.background,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(dark ? 0.35 : 0.07), blurRadius: 18, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: getPadding(left: 20, right: 20, top: 12, bottom: 12),
          child: Row(
            children: [
              if (urge != null) ...[
                Semantics(
                  button: true,
                  label: urge.title,
                  excludeSemantics: true,
                  child: Tooltip(
                    message: urge.title,
                    child: Material(
                      color: Colors.transparent,
                      shape: CircleBorder(side: BorderSide(color: accent.withOpacity(0.55))),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => SituationToolScreen(course: c, tool: urge))),
                        child: SizedBox(
                          width: getVerticalSize(52),
                          height: getVerticalSize(52),
                          child: Icon(Icons.spa_outlined, color: accent, size: getSize(24)),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: getHorizontalSize(12)),
              ],
              Expanded(child: CapsuleButton(label: label.tr(), icon: icon, dark: dark, onTap: onTap)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final dark = step.night;
    final accent = courseAccent(dark);
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: courseSoft(dark), height: 1.55);
    final numbered = widget.course.steps.where((s) => s.number != null).length;
    final pillText = step.number != null && numbered > 0
        ? 'course_step_of'.tr(namedArgs: {'n': '${step.number}', 'total': '$numbered'})
        : widget.course.groupOf(step).title;
    final taskDone = _progress != null && _state.taskDone;
    final lead = _lead(step.card);
    final longDesc = lead.length < step.card.length;
    return CourseTextScale(
        child: Scaffold(
      backgroundColor: dark ? kNightBg : AppColors.background,
      bottomNavigationBar: _progress == null ? null : _bottomBar(dark),
      body: SafeArea(top: false, bottom: false, child: _progress == null
          ? CourseSkeleton(dark: dark)
          : SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverHeader(
                    coverAsset: stepCoverAsset(step),
                    height: 236,
                    dark: dark,
                    leftScrim: step.cover != null || (audioCoverAsset(step.coverKey)?.contains('/program_') ?? false),
                    onBack: () => Navigator.pop(context),
                    // Text in the left ~62%, the picture stays clear on the right.
                    child: FractionallySizedBox(
                      widthFactor: 0.62,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (pillText.isNotEmpty) ...[
                            MetaPill(pillText),
                            SizedBox(height: getVerticalSize(10)),
                          ],
                          // The step number is in the pill above, not in the title.
                          Text(step.title,
                              style: AppStyle.txtH1.copyWith(
                                  color: Colors.white, fontSize: getFontSize(28), fontWeight: FontWeight.w300, height: 1.15)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: getPadding(left: 20, right: 20, top: 4, bottom: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // The description: three lines, the rest on request, so the
                        // player is in view without scrolling.
                        Text(_descOpen ? step.card : lead,
                            maxLines: _descOpen ? null : 3,
                            overflow: _descOpen ? TextOverflow.visible : TextOverflow.ellipsis,
                            style: body),
                        if (longDesc)
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _descOpen = !_descOpen),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minHeight: 44),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: 1,
                                child: Text((_descOpen ? 'course_read_less' : 'course_read_more').tr(),
                                    style: courseBody()
                                        .copyWith(color: accent, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        if (dark) ...[
                          SizedBox(height: getVerticalSize(10)),
                          Text('course_night_sleep_hint'.tr(),
                              style: courseCaption().copyWith(color: courseMuted(dark), height: 1.45)),
                        ],
                        if (step.basis.isNotEmpty) ...[
                          SizedBox(height: getVerticalSize(6)),
                          CourseBasisRow(text: step.basis, refIds: step.basisRefs, accent: accent),
                        ],
                        SizedBox(height: getVerticalSize(18)),
                        _chips(dark),
                        if (widget.course.microRead && step.micro.isNotEmpty) ...[
                          SizedBox(height: getVerticalSize(16)),
                          _microSection(dark),
                        ],
                        SizedBox(height: getVerticalSize(26)),
                        SectionLabel('course_part_audio'.tr(), dark: dark),
                        SizedBox(height: getVerticalSize(10)),
                        AnimatedContainer(
                          key: _audioKey,
                          duration: const Duration(milliseconds: 350),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: _audioGlow
                                ? [BoxShadow(color: accent.withOpacity(0.40), blurRadius: 24, spreadRadius: 2)]
                                : const [],
                          ),
                          child: CourseAudioPlayer(
                            docId: step.audioDocId,
                            listened: _state.audioDone,
                            dark: dark,
                            onListened: () {
                              _state.audioDone = true;
                              _persist();
                            },
                            onFinished: _onAudioFinished,
                          ),
                        ),
                        // More audios of the same step (not part of "listened").
                        for (final id in step.extraAudioDocIds) ...[
                          SizedBox(height: getVerticalSize(12)),
                          CourseAudioPlayer(
                              key: ValueKey('extra_$id'),
                              docId: id,
                              listened: false,
                              dark: dark,
                              showMark: false,
                              onListened: () {}),
                        ],
                        _help(dark),
                        SizedBox(height: getVerticalSize(28)),
                        SectionLabel('course_part_task'.tr(), dark: dark),
                        SizedBox(height: getVerticalSize(10)),
                        AnimatedContainer(
                          key: _taskKey,
                          duration: const Duration(milliseconds: 350),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: _glow
                                ? [BoxShadow(color: accent.withOpacity(0.45), blurRadius: 26, spreadRadius: 2)]
                                : const [],
                          ),
                          child: SoftCard(
                          dark: dark,
                          padding: getPadding(left: 16, top: 16, right: 16, bottom: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(step.task.title,
                                        style: AppStyle.txtH2.copyWith(
                                            color: courseText(dark), fontWeight: FontWeight.w600, height: 1.2)),
                                  ),
                                  if (taskDone) Icon(Icons.check_circle_rounded, color: accent, size: getSize(22)),
                                ],
                              ),
                              if (step.task.intro.isNotEmpty) ...[
                                SizedBox(height: getVerticalSize(8)),
                                Text(step.task.intro,
                                    style: courseBody()
                                        .copyWith(color: courseSoft(dark), height: 1.5)),
                              ],
                              SizedBox(height: getVerticalSize(16)),
                              CapsuleButton(
                                dark: dark,
                                label: (taskDone ? 'course_task_again' : 'course_task_open').tr(),
                                onTap: _openTask,
                              ),
                              if (taskDone)
                                Padding(
                                  padding: getPadding(top: 8),
                                  child: Text('course_task_done'.tr(), style: courseCaption().copyWith(color: accent)),
                                ),
                            ],
                          ),
                        ),
                        ),
                        if (widget.course.dailyThought && step.number != null) ...[
                          SizedBox(height: getVerticalSize(22)),
                          DailyThoughtCard(
                              key: _dailyKey,
                              dark: dark,
                              onChanged: (n) {
                                if (mounted && n != _dailyCount) setState(() => _dailyCount = n);
                              }),
                        ],
                        if (step.micro.isNotEmpty && !widget.course.microRead) ...[
                          SizedBox(key: _microKey, height: getVerticalSize(30)),
                          SectionLabel((widget.course.microRead ? 'course_part_days_read' : 'course_part_days').tr(),
                              dark: dark),
                          SizedBox(height: getVerticalSize(4)),
                          Text((widget.course.microRead ? 'course_micro_hint_read' : 'course_micro_hint').tr(),
                              style: courseCaption().copyWith(color: courseMuted(dark), height: 1.45)),
                          SizedBox(height: getVerticalSize(12)),
                          for (final m in step.micro) _micro(m, dark),
                        ],
                        SizedBox(height: getVerticalSize(18)),
                        Text('course_step_hint'.tr(),
                            style: courseCaption().copyWith(color: courseMuted(dark), height: 1.45)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
    ));
  }
}
