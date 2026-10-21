import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';
import 'package:riva_psy/presentation/settings/help_now_screen/help_now_screen.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';

import '../data/course_progress_store.dart';
import '../models/course.dart';
import 'course_audio_player.dart';
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
  // Soft glow around the task card after the audio ends.
  bool _glow = false;

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

  Widget _help(bool dark) {
    final color = courseMuted(dark);
    Widget link(String key) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpNowScreen())),
          child: Padding(
            padding: getPadding(top: 6, bottom: 6, right: 16),
            child: Text(key.tr(),
                style: AppStyle.txtSFProDisplayRegular11
                    .copyWith(color: color, decoration: TextDecoration.underline, decorationColor: color)),
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

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final dark = step.night;
    final accent = courseAccent(dark);
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: courseSoft(dark), height: 1.55);
    final title = step.number == null ? step.title : '${step.number}. ${step.title}';
    final taskDone = _progress != null && _state.taskDone;
    return CourseTextScale(
        child: Scaffold(
      backgroundColor: dark ? kNightBg : AppColors.background,
      body: _progress == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              controller: _scroll,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CoverHeader(
                    coverAsset: wideStepCover(audioCoverAsset(step.title)),
                    height: 236,
                    dark: dark,
                    leftScrim: audioCoverAsset(step.title)?.contains('/program_') ?? false,
                    onBack: () => Navigator.pop(context),
                    // Text in the left ~62%, the picture stays clear on the right.
                    child: FractionallySizedBox(
                      widthFactor: 0.62,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          MetaPill('≈ ${step.minutes} ${'course_min'.tr()}', icon: Icons.schedule_rounded),
                          SizedBox(height: getVerticalSize(8)),
                          Text(title,
                              style: AppStyle.txtH1
                                  .copyWith(color: Colors.white, fontSize: getFontSize(23), height: 1.15)),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: getPadding(left: 20, right: 20, top: 4, bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.card, style: body),
                        if (dark) ...[
                          SizedBox(height: getVerticalSize(10)),
                          Text('course_night_sleep_hint'.tr(),
                              style: AppStyle.txtSFProDisplayRegular11
                                  .copyWith(color: courseMuted(dark), height: 1.45)),
                        ],
                        SizedBox(height: getVerticalSize(22)),
                        SectionLabel('course_step_audio'.tr(), dark: dark),
                        SizedBox(height: getVerticalSize(10)),
                        CourseAudioPlayer(
                          docId: step.audioDocId,
                          listened: _state.audioDone,
                          dark: dark,
                          onListened: () {
                            _state.audioDone = true;
                            _persist();
                          },
                          onFinished: _onAudioFinished,
                        ),
                        _help(dark),
                        SizedBox(height: getVerticalSize(22)),
                        SectionLabel('course_step_task'.tr(), dark: dark),
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
                                        style: AppStyle.txtH2.copyWith(color: courseText(dark), height: 1.2)),
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
                                  child: Text('course_task_done'.tr(),
                                      style: AppStyle.txtSFProDisplayRegular11.copyWith(color: accent)),
                                ),
                            ],
                          ),
                        ),
                        ),
                        if (step.micro.isNotEmpty) ...[
                          SizedBox(height: getVerticalSize(22)),
                          SectionLabel('course_step_between'.tr(), dark: dark),
                          SizedBox(height: getVerticalSize(10)),
                          for (final m in step.micro) _micro(m, dark),
                        ],
                        SizedBox(height: getVerticalSize(8)),
                        Text('course_step_hint'.tr(),
                            style: AppStyle.txtSFProDisplayRegular11
                                .copyWith(color: courseMuted(dark), height: 1.45)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    ));
  }
}
