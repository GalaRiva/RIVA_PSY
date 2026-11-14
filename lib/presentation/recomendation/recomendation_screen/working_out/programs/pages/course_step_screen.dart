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

  CourseStepState get _state => _progress!.step(widget.step.id);

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
      await _showDone();
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
      nextBlocked: n != null && stepBlockedByPace(c, p, n),
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

  // Three short segments — Audio, Task, Days — that fill in as the person goes,
  // so the order of the page is visible at a glance.
  Widget _parts(bool dark) {
    final accent = courseAccent(dark);
    final step = widget.step;
    final days = step.micro.isNotEmpty && step.micro.every((m) => _state.microDone.contains(m.id));
    Widget seg(String key, bool done) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 4,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: done ? 1 : 0),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Positioned.fill(child: Container(color: courseMuted(dark).withOpacity(0.25))),
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: v,
                            child: Container(color: accent),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: getVerticalSize(7)),
              Row(
                children: [
                  if (done) ...[
                    Icon(Icons.check_circle_rounded, size: getSize(15), color: accent),
                    SizedBox(width: getHorizontalSize(4)),
                  ],
                  Flexible(
                    child: Text(key.tr(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: courseCaption().copyWith(color: done ? courseText(dark) : courseMuted(dark))),
                  ),
                ],
              ),
            ],
          ),
        );
    return Row(
      children: [
        seg('course_part_audio', _state.audioDone),
        SizedBox(width: getHorizontalSize(10)),
        seg('course_part_task', _state.taskDone),
        if (step.micro.isNotEmpty) ...[
          SizedBox(width: getHorizontalSize(10)),
          seg('course_part_days_short', days),
        ],
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

  Widget _micro(CourseMicro m, bool dark) {
    final done = _state.microDone.contains(m.id);
    final accent = courseAccent(dark);
    return Padding(
      padding: getPadding(bottom: 10),
      child: SoftCard(
        dark: dark,
        padding: getPadding(left: 16, top: 14, right: 12, bottom: 14),
        onTap: () {
          if (done) {
            _state.microDone.remove(m.id);
          } else {
            _state.microDone.add(m.id);
          }
          _persist();
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.title,
                      style: AppStyle.txtSFProDisplayLight16
                          .copyWith(color: courseText(dark), fontWeight: FontWeight.w600)),
                  SizedBox(height: getVerticalSize(4)),
                  Text(m.body,
                      style: AppStyle.txtSFProDisplayLight14.copyWith(color: courseSoft(dark), height: 1.5)),
                ],
              ),
            ),
            SizedBox(width: getHorizontalSize(10)),
            Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                size: getSize(24), color: done ? accent : courseMuted(dark)),
          ],
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
    final longDesc = step.card.length > 120;
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
                    coverAsset: wideStepCover(audioCoverAsset(step.coverKey)),
                    height: 236,
                    dark: dark,
                    leftScrim: audioCoverAsset(step.coverKey)?.contains('/program_') ?? false,
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
                        Text(step.card,
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
                                    style: AppStyle.txtSFProDisplayLight14
                                        .copyWith(color: accent, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ),
                        if (dark) ...[
                          SizedBox(height: getVerticalSize(10)),
                          Text('course_night_sleep_hint'.tr(),
                              style: courseCaption().copyWith(color: courseMuted(dark), height: 1.45)),
                        ],
                        SizedBox(height: getVerticalSize(18)),
                        _parts(dark),
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
                                    style: AppStyle.txtSFProDisplayLight14
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
                        if (step.micro.isNotEmpty) ...[
                          SizedBox(height: getVerticalSize(30)),
                          SectionLabel('course_part_days'.tr(), dark: dark),
                          SizedBox(height: getVerticalSize(4)),
                          Text('course_micro_hint'.tr(),
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
