import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';
import 'package:riva_psy/core/utils/audio_cover_map.dart';
import 'package:riva_psy/theme/app_colors.dart';

import '../data/course_flow.dart';
import '../models/course.dart';
import 'course_ui.dart';

// Two calm bottom sheets of the Programs:
//  * "Step complete": a quiet moment after the task (no streaks, no points),
//    with the next step offered — now, or tomorrow when today's pace is used up.
//  * "The next step opens tomorrow": instead of a refusal, an explanation and a
//    single one-off reminder.

/// Sheet shown when a step is finished. [onOpenNext] runs after the sheet closes
/// when the person taps "Next step".
Future<void> showStepDoneSheet({
  required BuildContext context,
  required Course course,
  required CourseStep? next,
  required bool nextBlocked,
  required bool nextLocked,
  required VoidCallback onOpenNext,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => CourseTextScale(
      child: _SheetFrame(
        child: _DoneBody(
          course: course,
          next: next,
          nextBlocked: nextBlocked,
          nextLocked: nextLocked,
          onOpenNext: () {
            Navigator.pop(ctx);
            onOpenNext();
          },
          onClose: () => Navigator.pop(ctx),
        ),
      ),
    ),
  );
}

/// Sheet shown when someone taps a new step that today's pace does not allow.
Future<void> showTomorrowSheet({required BuildContext context, required Course course, required CourseStep step}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => CourseTextScale(
      child: _SheetFrame(
        child: Padding(
          padding: getPadding(left: 24, right: 24, top: 8, bottom: 8),
          child: _TomorrowCard(course: course, step: step, onClose: () => Navigator.pop(ctx)),
        ),
      ),
    ),
  );
}

class _SheetFrame extends StatelessWidget {
  final Widget child;
  const _SheetFrame({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: getPadding(top: 12, bottom: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
              ),
              SizedBox(height: getVerticalSize(8)),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneBody extends StatelessWidget {
  final Course course;
  final CourseStep? next;
  final bool nextBlocked;
  final bool nextLocked;
  final VoidCallback onOpenNext;
  final VoidCallback onClose;
  const _DoneBody({
    required this.course,
    required this.next,
    required this.nextBlocked,
    required this.nextLocked,
    required this.onOpenNext,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final step = next;
    return Padding(
      padding: getPadding(left: 24, right: 24, top: 10, bottom: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: getSize(48),
            height: getSize(48),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
            child: Icon(Icons.check_rounded, color: AppColors.primary, size: getSize(26)),
          ),
          SizedBox(height: getVerticalSize(16)),
          Text('course_step_done_title'.tr(),
              style: AppStyle.txtH1.copyWith(color: AppColors.textPrimary, fontSize: getFontSize(26), height: 1.15)),
          SizedBox(height: getVerticalSize(8)),
          // When the next step opens only tomorrow, don't say "now or later".
          Text((step != null && nextBlocked ? 'course_step_done_wait' : 'course_step_done_body').tr(),
              style: AppStyle.txtSFProDisplayLight16.copyWith(color: courseSoft(false), height: 1.5)),
          if (step != null) ...[
            SizedBox(height: getVerticalSize(20)),
            if (nextBlocked)
              _TomorrowCard(course: course, step: step, onClose: onClose, embedded: true)
            else
              _NextTile(step: step, locked: nextLocked, onTap: onOpenNext),
          ],
          SizedBox(height: getVerticalSize(14)),
          Center(
            child: TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
              child: Text('course_later'.tr(),
                  style: AppStyle.txtSFProDisplayLight14.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// The next step, as a small cover card with the button.
class _NextTile extends StatelessWidget {
  final CourseStep step;
  final bool locked;
  final VoidCallback onTap;
  const _NextTile({required this.step, required this.locked, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cover = audioCoverAsset(step.coverKey);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('course_next_step'.tr()),
        SizedBox(height: getVerticalSize(10)),
        Row(
          children: [
            if (cover != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(cover, width: getSize(60), height: getSize(60), fit: BoxFit.cover),
              ),
            if (cover != null) SizedBox(width: getHorizontalSize(14)),
            Expanded(
              child: Text(step.title,
                  style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.2)),
            ),
          ],
        ),
        SizedBox(height: getVerticalSize(16)),
        CapsuleButton(
            label: 'course_next_step'.tr(),
            icon: locked ? Icons.lock_outline_rounded : Icons.arrow_forward_rounded,
            onTap: onTap),
      ],
    );
  }
}

// "Opens tomorrow", with a single reminder.
class _TomorrowCard extends StatefulWidget {
  final Course course;
  final CourseStep step;
  final VoidCallback onClose;
  final bool embedded;
  const _TomorrowCard({required this.course, required this.step, required this.onClose, this.embedded = false});

  @override
  State<_TomorrowCard> createState() => _TomorrowCardState();
}

class _TomorrowCardState extends State<_TomorrowCard> {
  // null: not asked yet, true: set, false: notifications are off.
  bool? _set;

  Future<void> _remind() async {
    bool ok = false;
    try {
      ok = await AwesomeNotificationService().scheduleOneOff(
        idKey: 'course_next_${widget.course.id}',
        at: tomorrowMorning(),
        title: widget.course.cardTitle,
        body: widget.step.title,
      );
    } catch (_) {}
    if (mounted) setState(() => _set = ok);
  }

  @override
  Widget build(BuildContext context) {
    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.wb_twilight_rounded, color: AppColors.primary, size: getSize(22)),
            SizedBox(width: getHorizontalSize(10)),
            Expanded(
              child: Text('course_next_tomorrow_title'.tr(),
                  style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.2)),
            ),
          ],
        ),
        SizedBox(height: getVerticalSize(8)),
        Text('course_next_tomorrow_body'.tr(),
            style: AppStyle.txtSFProDisplayLight14.copyWith(color: courseSoft(false), height: 1.5)),
        SizedBox(height: getVerticalSize(8)),
        Text(widget.step.title,
            style: AppStyle.txtSFProDisplayLight14.copyWith(color: courseMuted(false), fontWeight: FontWeight.w600)),
        SizedBox(height: getVerticalSize(16)),
        if (_set == null)
          CapsuleButton(label: 'course_remind_me'.tr(), icon: Icons.notifications_none_rounded, onTap: _remind)
        else
          Text((_set! ? 'course_reminder_set' : 'course_reminder_off').tr(),
              style: AppStyle.txtSFProDisplayLight14
                  .copyWith(color: _set! ? AppColors.primary : courseMuted(false), fontWeight: FontWeight.w600)),
        if (!widget.embedded) ...[
          SizedBox(height: getVerticalSize(6)),
          Center(
            child: TextButton(
              onPressed: widget.onClose,
              style: TextButton.styleFrom(minimumSize: const Size(0, 48)),
              child: Text('course_later'.tr(),
                  style: AppStyle.txtSFProDisplayLight14.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ],
    );
    if (!widget.embedded) return inner;
    return Container(
      width: double.infinity,
      padding: getPadding(left: 16, top: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(22)),
      child: inner,
    );
  }
}
