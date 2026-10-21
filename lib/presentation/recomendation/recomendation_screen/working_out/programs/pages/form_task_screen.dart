import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_pop_button.dart';

import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';

import '../data/course_progress_store.dart';
import '../data/course_records.dart';
import '../models/course.dart';

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

  Widget _field(CourseField f) {
    final label = AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w600);
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500);
    if (f.type == 'check') {
      return CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: ColorConstant.cyan700,
        value: _check[f.id] ?? false,
        onChanged: (v) => setState(() => _check[f.id] = v ?? false),
        title: Text(f.label, style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
      );
    }
    if (f.type == 'scale') {
      final v = _scale[f.id] ?? 5;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${f.label}  ${v.round()}', style: label),
          if (f.hint.isNotEmpty) Text(f.hint, style: small),
          Slider(
            value: v,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: ColorConstant.cyan700,
            inactiveColor: ColorConstant.cyan700.withOpacity(0.2),
            onChanged: (x) => setState(() => _scale[f.id] = x),
          ),
        ],
      );
    }
    if (f.type == 'time') {
      final t = _time[f.id];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(f.label, style: label),
          if (f.hint.isNotEmpty) Text(f.hint, style: small),
          SizedBox(height: getVerticalSize(6)),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => _pickTime(f),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: BorderSide(color: ColorConstant.cyan700.withOpacity(0.5)),
              ),
              child: Text(t == null ? 'course_pick_time'.tr() : t.format(context),
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.cyan700)),
            ),
          ),
          if (f.notifyBefore != null)
            Padding(
              padding: getPadding(top: 4),
              child: Text('course_time_reminder_note'.tr(namedArgs: {'min': '${f.notifyBefore}'}), style: small),
            ),
        ],
      );
    }
    final ctrl = _text[f.id]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(f.label + (f.optional ? '' : ''), style: label),
        if (f.hint.isNotEmpty) Text(f.hint, style: small),
        SizedBox(height: getVerticalSize(6)),
        TextField(
          controller: ctrl,
          minLines: 1,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: ColorConstant.grayLight,
            contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          ),
        ),
        if (f.chips.isNotEmpty)
          Padding(
            padding: getPadding(top: 6),
            child: Wrap(
              spacing: 6,
              runSpacing: 0,
              children: [
                for (final c in f.chips)
                  ActionChip(
                    label: Text(c, style: AppStyle.txtSFProDisplayRegular11),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: ColorConstant.cyan700.withOpacity(0.25)),
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      final cur = ctrl.text.trim();
                      ctrl.text = cur.isEmpty ? c : '$cur, $c';
                      ctrl.selection = TextSelection.collapsed(offset: ctrl.text.length);
                      setState(() {});
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: getPadding(left: 16, right: 16, top: 12, bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPopButton(text: 'back'.tr()),
              SizedBox(height: getVerticalSize(18)),
              Text(widget.task.title, style: AppStyle.txtH1),
              SizedBox(height: getVerticalSize(8)),
              Text(widget.task.intro,
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5)),
              SizedBox(height: getVerticalSize(18)),
              for (final f in widget.task.fields)
                Padding(padding: getPadding(bottom: 16), child: _field(f)),
              SizedBox(height: getVerticalSize(6)),
              CustomButton(
                height: getVerticalSize(48),
                width: double.infinity,
                text: 'course_save'.tr().toUpperCase(),
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
