import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/helpline_link.dart';
import 'package:riva_psy/widgets/pause_content.dart';

import '../data/course_progress_store.dart';
import '../models/course.dart';

// "Как ты сейчас?" after a course audio: three plain answers, nothing is
// scored. "Тяжелее" gets a pause instruction, a pointer to the calm practice
// and the helplines; a second "тяжелее" in a row also suggests talking to a
// specialist. The streak is kept per course on the device only.
Future<void> showCourseCheckin({
  required BuildContext context,
  required Course course,
  required CourseProgress progress,
  required void Function(String stepId) onOpenStep,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CheckinSheet(course: course, progress: progress, onOpenStep: onOpenStep),
  );
}

class _CheckinSheet extends StatefulWidget {
  final Course course;
  final CourseProgress progress;
  final void Function(String stepId) onOpenStep;
  const _CheckinSheet({required this.course, required this.progress, required this.onOpenStep});

  @override
  State<_CheckinSheet> createState() => _CheckinSheetState();
}

class _CheckinSheetState extends State<_CheckinSheet> {
  bool _worse = false;

  Future<void> _answer(String a) async {
    final p = widget.progress;
    if (a == 'worse') {
      p.worseStreak += 1;
      await CourseProgressStore.save(widget.course.id, p);
      if (mounted) setState(() => _worse = true);
    } else {
      p.worseStreak = 0;
      await CourseProgressStore.save(widget.course.id, p);
      if (mounted) Navigator.pop(context);
    }
  }

  Widget _option(String key, String answer) {
    return Padding(
      padding: getPadding(bottom: 10),
      child: GestureDetector(
        onTap: () => _answer(answer),
        child: Container(
          width: double.infinity,
          height: getVerticalSize(46),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(color: ColorConstant.cyan700.withOpacity(0.35)),
          ),
          child: Text(key.tr(),
              style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5);
    final calmId = widget.course.calmStepId;
    final calm = calmId == null ? null : widget.course.steps.where((s) => s.id == calmId).toList();
    return Container(
      padding: getPadding(left: 20, right: 20, top: 22, bottom: 26),
      decoration: BoxDecoration(
        color: ColorConstant.whiteA700,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: ColorConstant.gray50, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              SizedBox(height: getVerticalSize(18)),
              if (!_worse) ...[
                Text('course_checkin_title'.tr(), style: AppStyle.txtH2),
                SizedBox(height: getVerticalSize(14)),
                _option('course_checkin_better', 'better'),
                _option('course_checkin_same', 'same'),
                _option('course_checkin_worse', 'worse'),
              ] else ...[
                Text('course_checkin_worse_title'.tr(), style: AppStyle.txtH2),
                SizedBox(height: getVerticalSize(12)),
                const PauseContent(),
                SizedBox(height: getVerticalSize(12)),
                Text('course_checkin_break'.tr(), style: body),
                if (widget.progress.worseStreak >= 2) ...[
                  SizedBox(height: getVerticalSize(12)),
                  Text('course_checkin_specialist'.tr(), style: body),
                ],
                if (calm != null && calm.isNotEmpty) ...[
                  SizedBox(height: getVerticalSize(16)),
                  CustomButton(
                    height: getVerticalSize(46),
                    width: double.infinity,
                    text: 'course_checkin_calm_button'.tr(namedArgs: {'name': calm.first.title}).toUpperCase(),
                    textIsFitted: true,
                    variant: ButtonVariant.Cyan,
                    fontStyle: ButtonFontStyle.White16,
                    onTap: () {
                      Navigator.pop(context);
                      widget.onOpenStep(calm.first.id);
                    },
                  ),
                ],
                const HelplineLink(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('close'.tr(),
                        style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
