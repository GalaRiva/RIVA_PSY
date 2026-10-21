import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';

import '../data/course_progress_store.dart';
import '../data/course_records.dart';
import '../models/course.dart';
import '../widgets/course_ui.dart';

// Generic form for every course task (chain, rule, emotion map, if-then…).
// Fields come from the course JSON, so a new task type needs no new code.
// Saving adds a card to the course's personal library; returns true.
class FormTaskScreen extends StatefulWidget {
  final String courseId;
  final CourseTask task;
  final int round;
  // When given, the saved answers are also written to "Записи".
  final Course? course;
  final String stepTitle;

  const FormTaskScreen(
      {Key? key,
      required this.courseId,
      required this.task,
      required this.round,
      this.course,
      this.stepTitle = ''})
      : super(key: key);

  @override
  State<FormTaskScreen> createState() => _FormTaskScreenState();
}

class _FormTaskScreenState extends State<FormTaskScreen> {
  final Map<String, TextEditingController> _text = {};
  final Map<String, bool> _check = {};
  final Map<String, double> _scale = {};
  final Map<String, TimeOfDay?> _time = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final f in widget.task.fields) {
      if (f.type == 'check') {
        _check[f.id] = false;
      } else if (f.type == 'scale') {
        _scale[f.id] = 5;
      } else if (f.type == 'time') {
        _time[f.id] = null;
      } else {
        _text[f.id] = TextEditingController(text: f.defaultText ?? '');
      }
    }
    // Pre-fill from the most recent card of the same type so a repeat round
    // starts from what the person wrote before, not from blank.
    CourseProgressStore.latest(widget.courseId, widget.task.cardType).then((card) {
      if (card == null || !mounted) return;
      setState(() {
        for (final f in widget.task.fields) {
          final v = card.values[f.id];
          if (v == null) continue;
          if (f.type == 'check') {
            _check[f.id] = v == '1';
          } else if (f.type == 'scale') {
            _scale[f.id] = double.tryParse(v) ?? 5;
          } else if (f.type == 'time') {
            final p = v.split(':');
            if (p.length == 2) {
              _time[f.id] = TimeOfDay(hour: int.tryParse(p[0]) ?? 0, minute: int.tryParse(p[1]) ?? 0);
            }
          } else {
            _text[f.id]?.text = v;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final values = <String, String>{};
    for (final f in widget.task.fields) {
      if (f.type == 'check') {
        values[f.id] = (_check[f.id] ?? false) ? '1' : '0';
      } else if (f.type == 'scale') {
        values[f.id] = (_scale[f.id] ?? 5).round().toString();
      } else if (f.type == 'time') {
        final t = _time[f.id];
        if (t != null) values[f.id] = '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
      } else {
        final t = (_text[f.id]?.text ?? '').trim();
        if (t.isNotEmpty) values[f.id] = t;
      }
    }
    final anyText = widget.task.fields
        .where((f) => f.type == 'text')
        .any((f) => (values[f.id] ?? '').isNotEmpty);
    if (!anyText) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('course_fill_something'.tr())));
      return;
    }
    setState(() => _saving = true);
    await CourseProgressStore.addCard(
      widget.courseId,
      CourseCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        cardType: widget.task.cardType,
        round: widget.round,
        createdAt: DateTime.now(),
        values: values,
      ),
    );
    await _scheduleTimeReminders(values);
    final course = widget.course;
    if (course != null) {
      await CourseRecords.task(course: course, stepTitle: widget.stepTitle, task: widget.task, values: values);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('course_saved'.tr())));
    Navigator.pop(context, true);
  }

  // A 'time' field with notify_before: quiet one-off reminders for the next
  // week (not repeating, no counters), e.g. 30 minutes before a hard evening.
  Future<void> _scheduleTimeReminders(Map<String, String> values) async {
    for (final f in widget.task.fields) {
      final minutes = f.notifyBefore;
      final t = _time[f.id];
      if (f.type != 'time' || minutes == null || t == null) continue;
      try {
        final now = DateTime.now();
        for (var d = 0; d < 7; d++) {
          final at = DateTime(now.year, now.month, now.day + d, t.hour, t.minute)
              .subtract(Duration(minutes: minutes));
          await AwesomeNotificationService().scheduleOneOff(
            idKey: 'course_time_${widget.courseId}_${f.id}_$d',
            at: at,
            title: widget.task.title,
            body: f.notifyBody,
            askPermission: d == 0 || !at.isBefore(now),
          );
        }
      } catch (_) {}
    }
  }

  Future<void> _pickTime(CourseField f) async {
    final t = await showTimePicker(context: context, initialTime: _time[f.id] ?? const TimeOfDay(hour: 20, minute: 0));
    if (t != null) setState(() => _time[f.id] = t);
  }

  Widget _label(CourseField f) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label,
            style: AppStyle.txtSFProDisplayLight16
                .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.25)),
        if (f.hint.isNotEmpty)
          Padding(
            padding: getPadding(top: 3),
            child: Text(f.hint,
                style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary, height: 1.4)),
          ),
      ],
    );
  }

  Widget _field(CourseField f) {
    if (f.type == 'check') {
      final on = _check[f.id] ?? false;
      return SoftCard(
        padding: getPadding(left: 16, top: 12, right: 12, bottom: 12),
        onTap: () => setState(() => _check[f.id] = !on),
        child: Row(
          children: [
            Expanded(
              child: Text(f.label,
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textPrimary)),
            ),
            Icon(on ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: on ? AppColors.primary : AppColors.textSecondary, size: getSize(26)),
          ],
        ),
      );
    }
    if (f.type == 'scale') {
      final v = _scale[f.id] ?? 5;
      return SoftCard(
        padding: getPadding(left: 16, top: 14, right: 12, bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _label(f)),
                Text('${v.round()}',
                    style: AppStyle.txtH1.copyWith(color: AppColors.primary, fontSize: getFontSize(30))),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              ),
              child: Slider(
                value: v,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.15),
                onChanged: (x) => setState(() => _scale[f.id] = x),
              ),
            ),
          ],
        ),
      );
    }
    if (f.type == 'time') {
      final t = _time[f.id];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(f),
          SizedBox(height: getVerticalSize(10)),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => _pickTime(f),
              child: Container(
                padding: getPadding(left: 18, right: 18, top: 11, bottom: 11),
                decoration: BoxDecoration(
                  color: t == null ? Colors.transparent : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.primary.withOpacity(0.45)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule_rounded, size: getSize(18), color: AppColors.primary),
                    SizedBox(width: getHorizontalSize(8)),
                    Text(t == null ? 'course_pick_time'.tr() : t.format(context),
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
          if (f.notifyBefore != null)
            Padding(
              padding: getPadding(top: 6),
              child: Text('course_time_reminder_note'.tr(namedArgs: {'min': '${f.notifyBefore}'}),
                  style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary)),
            ),
        ],
      );
    }
    final ctrl = _text[f.id]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(f),
        SizedBox(height: getVerticalSize(10)),
        TextField(
          controller: ctrl,
          minLines: 1,
          maxLines: 5,
          style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textPrimary, height: 1.4),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
          ),
        ),
        if (f.chips.isNotEmpty)
          Padding(
            padding: getPadding(top: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in f.chips)
                  GestureDetector(
                    onTap: () {
                      final cur = ctrl.text.trim();
                      ctrl.text = cur.isEmpty ? c : '$cur, $c';
                      ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
                      setState(() {});
                    },
                    child: Container(
                      padding: getPadding(left: 12, right: 12, top: 7, bottom: 7),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(c,
                          style: AppStyle.txtSFProDisplayRegular11
                              .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => CourseTextScale(child: _buildBody(context));

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: getPadding(left: 20, right: 20, top: 10, bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoundIconButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.pop(context),
                        tooltip: 'back'.tr(),
                        onImage: false),
                    SizedBox(height: getVerticalSize(20)),
                    Text(widget.task.title,
                        style: AppStyle.txtH1
                            .copyWith(color: AppColors.textPrimary, fontSize: getFontSize(27), height: 1.15)),
                    SizedBox(height: getVerticalSize(10)),
                    Text(widget.task.intro,
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: AppColors.textPrimary.withOpacity(0.75), height: 1.55)),
                    SizedBox(height: getVerticalSize(24)),
                    for (final f in widget.task.fields)
                      Padding(padding: getPadding(bottom: 22), child: _field(f)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: getPadding(left: 20, right: 20, top: 6, bottom: 16),
              child: CapsuleButton(label: 'course_save'.tr(), onTap: _saving ? null : _save),
            ),
          ],
        ),
      ),
    );
  }
}
