import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';
import 'package:riva_psy/presentation/settings/help_now_screen/help_now_screen.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_pop_button.dart';

import '../data/course_progress_store.dart';
import '../models/course.dart';
import 'course_audio_player.dart';
import 'course_checkin.dart';
import 'form_task_screen.dart';
import 'night_box_screen.dart';

const _nightBg = Color(0xFF0B1917);

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
    if (mounted) setState(() {});
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
    final color = dark ? Colors.white60 : ColorConstant.gray500;
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

  Widget _section(String titleKey, Widget child, {bool dark = false}) {
    return Padding(
      padding: getPadding(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleKey.tr(),
              style: AppStyle.txtSFProDisplayRegular11
                  .copyWith(color: dark ? const Color(0xFF7FBDBA) : ColorConstant.cyan700, letterSpacing: 0.5)),
          SizedBox(height: getVerticalSize(8)),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final dark = step.night;
    final fg = dark ? Colors.white : ColorConstant.gray800;
    final soft = dark ? Colors.white70 : ColorConstant.gray800;
    final muted = dark ? Colors.white54 : ColorConstant.gray500;
    final accent = dark ? const Color(0xFF7FBDBA) : ColorConstant.cyan700;
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: soft, height: 1.5);
    final title = step.number == null ? step.title : '${step.number}. ${step.title}';
    return Scaffold(
      backgroundColor: dark ? _nightBg : AppColors.background,
      body: SafeArea(
        child: _progress == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: getPadding(left: 16, right: 16, top: 12, bottom: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (dark)
                      IconButton(
                        tooltip: 'back'.tr(),
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      CustomPopButton(text: widget.course.title),
                    SizedBox(height: getVerticalSize(18)),
                    Text(title, style: AppStyle.txtH1.copyWith(color: fg)),
                    SizedBox(height: getVerticalSize(4)),
                    Text('≈ ${step.minutes} ${'course_min'.tr()}',
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: muted)),
                    SizedBox(height: getVerticalSize(10)),
                    Text(step.card, style: body),
                    if (dark) ...[
                      SizedBox(height: getVerticalSize(10)),
                      Text('course_night_sleep_hint'.tr(),
                          style: AppStyle.txtSFProDisplayRegular11.copyWith(color: muted, height: 1.4)),
                    ],
                    _section(
                      'course_step_audio',
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
                      dark: dark,
                    ),
                    _help(dark),
                    _section(
                      'course_step_task',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(step.task.title, style: body.copyWith(fontWeight: FontWeight.w600, color: fg)),
                          SizedBox(height: getVerticalSize(8)),
                          CustomButton(
                            height: getVerticalSize(44),
                            width: double.infinity,
                            text: (_state.taskDone ? 'course_task_again' : 'course_task_open').tr().toUpperCase(),
                            textIsFitted: true,
                            variant: ButtonVariant.Cyan,
                            fontStyle: ButtonFontStyle.White16,
                            onTap: _openTask,
                          ),
                          if (_state.taskDone)
                            Padding(
                              padding: getPadding(top: 6),
                              child: Text('course_task_done'.tr(),
                                  style: AppStyle.txtSFProDisplayRegular11.copyWith(color: accent)),
                            ),
                        ],
                      ),
                      dark: dark,
                    ),
                    if (step.micro.isNotEmpty)
                      _section(
                        'course_step_between',
                        Column(
                          children: [
                            for (final m in step.micro)
                              Container(
                                width: double.infinity,
                                margin: getMargin(bottom: 10),
                                padding: getPadding(left: 14, top: 12, right: 6, bottom: 12),
                                decoration: BoxDecoration(
                                  color: dark ? Colors.white.withOpacity(0.06) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: accent.withOpacity(0.18)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(m.title, style: body.copyWith(fontWeight: FontWeight.w600, color: fg)),
                                          SizedBox(height: getVerticalSize(2)),
                                          Text(m.body,
                                              style: AppStyle.txtSFProDisplayLight14
                                                  .copyWith(color: soft, height: 1.45)),
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      activeColor: accent,
                                      side: BorderSide(color: dark ? Colors.white54 : ColorConstant.gray500),
                                      value: _state.microDone.contains(m.id),
                                      onChanged: (v) {
                                        if (v == true) {
                                          _state.microDone.add(m.id);
                                        } else {
                                          _state.microDone.remove(m.id);
                                        }
                                        _persist();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        dark: dark,
                      ),
                    SizedBox(height: getVerticalSize(10)),
                    Text('course_step_hint'.tr(),
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: muted, height: 1.4)),
                  ],
                ),
              ),
      ),
    );
  }
}
