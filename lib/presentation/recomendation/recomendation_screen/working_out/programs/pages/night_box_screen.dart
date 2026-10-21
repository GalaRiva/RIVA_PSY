import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/notifications/awesome_notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/course_progress_store.dart';
import '../data/course_records.dart';
import '../models/course.dart';

const _bg = Color(0xFF0B1917);
const _accent = Color(0xFF7FBDBA);
const _cardType = 'night_thought';

// "Ящик" for the night-thoughts exercise: at night a thought is named in a
// word or two and put in the box (nothing is solved at night). The next
// morning, at the chosen time, a quiet notification says the box is waiting;
// opening it gives 15 minutes and three choices per thought — one next step,
// "это история" (a thought-story from exercise 2) or let it go. Everything
// stays on the phone. Pops true once at least one thought was sorted.
class NightBoxScreen extends StatefulWidget {
  final Course course;
  const NightBoxScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<NightBoxScreen> createState() => _NightBoxScreenState();
}

class _NightBoxScreenState extends State<NightBoxScreen> {
  static const _timeKey = 'night_box_time_v1';
  final _input = TextEditingController();
  List<CourseCard> _open = [];
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _review = false;
  bool _resolvedAny = false;
  Timer? _timer;
  int _secondsLeft = 15 * 60;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _input.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_timeKey);
    if (raw != null && raw.contains(':')) {
      final p = raw.split(':');
      _time = TimeOfDay(hour: int.tryParse(p[0]) ?? 9, minute: int.tryParse(p[1]) ?? 0);
    }
    await _reload();
  }

  Future<void> _reload() async {
    final all = await CourseProgressStore.cards(widget.course.id);
    final open = all.where((c) => c.cardType == _cardType && c.values['status'] == 'open').toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (mounted) setState(() => _open = open);
  }

  DateTime _nextMorning() {
    final now = DateTime.now();
    var t = DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    if (!t.isAfter(now)) t = t.add(const Duration(days: 1));
    return t;
  }

  Future<void> _scheduleMorning() async {
    try {
      await AwesomeNotificationService().scheduleOneOff(
        idKey: 'night_box_${widget.course.id}',
        at: _nextMorning(),
        title: 'course_night_notif_title'.tr(),
        body: 'course_night_notif_body'.tr(),
      );
    } catch (_) {}
  }

  Future<void> _add() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    await CourseProgressStore.addCard(
      widget.course.id,
      CourseCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        cardType: _cardType,
        round: 0,
        createdAt: DateTime.now(),
        values: {'text': text, 'status': 'open'},
      ),
    );
    _input.clear();
    FocusScope.of(context).unfocus();
    await _reload();
    await _scheduleMorning();
  }

  Future<void> _setStatus(CourseCard c, String status, {String? next}) async {
    await CourseProgressStore.deleteCard(widget.course.id, c.id);
    await CourseProgressStore.addCard(
      widget.course.id,
      CourseCard(
        id: c.id,
        cardType: _cardType,
        round: 0,
        createdAt: c.createdAt,
        values: {'text': c.values['text'] ?? '', 'status': status, if (next != null) 'next': next},
      ),
    );
    _resolvedAny = true;
    await _reload();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: _time);
    if (t == null) return;
    setState(() => _time = t);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeKey, '${t.hour}:${t.minute}');
    if (_open.isNotEmpty) await _scheduleMorning();
  }

  Future<void> _nextStep(CourseCard c) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('course_night_step_title'.tr(), style: AppStyle.txtH2),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(hintText: 'course_night_step_hint'.tr()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('cancel'.tr())),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('course_save'.tr())),
        ],
      ),
    );
    final step = ctrl.text.trim();
    if (ok != true || step.isEmpty) return;
    await _setStatus(c, 'step', next: step);
    await CourseRecords.note(
      course: widget.course,
      title: 'course_night_record_title'.tr(),
      text: '${c.values['text']}\n→ $step',
    );
  }

  void _toggleTimer() {
    if (_timerRunning) {
      _timer?.cancel();
      setState(() => _timerRunning = false);
      return;
    }
    setState(() => _timerRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() {
          _secondsLeft = 0;
          _timerRunning = false;
        });
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String _mmss(int s) => '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Widget _pill(String label, VoidCallback onTap, {bool filled = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: getPadding(left: 14, right: 14, top: 9, bottom: 9),
        decoration: BoxDecoration(
          color: filled ? _accent.withOpacity(0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _accent.withOpacity(0.5)),
        ),
        child: Text(label, style: AppStyle.txtSFProDisplayLight14.copyWith(color: Colors.white)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white70, height: 1.5);
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: Colors.white54, height: 1.4);
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _resolvedAny);
        return false;
      },
      child: Scaffold(
        backgroundColor: _bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: getPadding(left: 16, right: 16, top: 6, bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  tooltip: 'back'.tr(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context, _resolvedAny),
                ),
                Text('course_night_title'.tr(), style: AppStyle.txtH1.copyWith(color: Colors.white)),
                SizedBox(height: getVerticalSize(10)),
                Text(_review ? 'course_night_review_intro'.tr() : 'course_night_intro'.tr(), style: body),
                SizedBox(height: getVerticalSize(18)),
                if (!_review) ...[
                  TextField(
                    controller: _input,
                    style: const TextStyle(color: Colors.white),
                    cursorColor: _accent,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _add(),
                    decoration: InputDecoration(
                      hintText: 'course_night_hint'.tr(),
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.07),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                  ),
                  SizedBox(height: getVerticalSize(10)),
                  _pill('course_night_put'.tr(), _add, filled: true),
                  SizedBox(height: getVerticalSize(18)),
                  for (final c in _open)
                    Container(
                      width: double.infinity,
                      margin: getMargin(bottom: 8),
                      padding: getPadding(left: 14, top: 10, right: 4, bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(child: Text(c.values['text'] ?? '', style: body.copyWith(color: Colors.white))),
                          IconButton(
                            tooltip: 'course_delete'.tr(),
                            icon: const Icon(Icons.close_rounded, color: Colors.white38, size: 18),
                            onPressed: () async {
                              await CourseProgressStore.deleteCard(widget.course.id, c.id);
                              _reload();
                            },
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: getVerticalSize(8)),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Text(
                        'course_night_morning'.tr(namedArgs: {'time': _time.format(context)}),
                        style: small.copyWith(color: _accent, decoration: TextDecoration.underline)),
                  ),
                  SizedBox(height: getVerticalSize(24)),
                  _pill('course_night_open'.tr(), () => setState(() => _review = true)),
                ] else ...[
                  Row(
                    children: [
                      Text(_mmss(_secondsLeft),
                          style: AppStyle.txtH1.copyWith(color: Colors.white, fontSize: getFontSize(28))),
                      SizedBox(width: getHorizontalSize(14)),
                      _pill((_timerRunning ? 'course_night_pause' : 'course_night_start').tr(), _toggleTimer),
                    ],
                  ),
                  SizedBox(height: getVerticalSize(18)),
                  if (_open.isEmpty)
                    Text('course_night_empty'.tr(), style: body)
                  else
                    for (final c in _open)
                      Container(
                        width: double.infinity,
                        margin: getMargin(bottom: 12),
                        padding: getPadding(left: 14, top: 14, right: 14, bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.values['text'] ?? '',
                                style: body.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                            SizedBox(height: getVerticalSize(10)),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _pill('course_night_one_step'.tr(), () => _nextStep(c)),
                                _pill('course_night_story'.tr(), () => _setStatus(c, 'story')),
                                _pill('course_night_release'.tr(), () => _setStatus(c, 'closed')),
                              ],
                            ),
                          ],
                        ),
                      ),
                  SizedBox(height: getVerticalSize(10)),
                  _pill('course_night_back_to_box'.tr(), () => setState(() => _review = false)),
                ],
                SizedBox(height: getVerticalSize(24)),
                Text('course_night_sleep_hint'.tr(), style: small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
