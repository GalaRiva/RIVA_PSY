import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/settings/help_now_screen/help_now_screen.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/helpline_link.dart';

import '../data/course_progress_store.dart';
import '../data/course_records.dart';
import '../models/course.dart';

// A "situation tool" (e.g. "Сильный импульс", "Была ситуация"): a short,
// calm sequence of pages defined in the course JSON — one thing per screen,
// a close button always visible, the person's own saved cards shown where
// the page asks for them. Never gated, never needs any prior step.
class SituationToolScreen extends StatefulWidget {
  final Course course;
  final CourseTool tool;

  const SituationToolScreen({Key? key, required this.course, required this.tool}) : super(key: key);

  @override
  State<SituationToolScreen> createState() => _SituationToolScreenState();
}

class _SituationToolScreenState extends State<SituationToolScreen> {
  int _index = 0;
  // Latest saved card per card type, loaded once (see initState).
  final Map<String, CourseCard?> _cards = {};
  final Map<String, double> _scales = {};
  bool _waveSaved = false;
  Timer? _timer;
  int _secondsLeft = 0;
  bool _timerRunning = false;

  @override
  void initState() {
    super.initState();
    // Every card type some page of this tool wants to show.
    final types = <String>{};
    for (final p in widget.tool.pages) {
      if (p.showCard != null) types.add(p.showCard!.split(':').first);
    }
    for (final t in types) {
      CourseProgressStore.latest(widget.course.id, t).then((c) {
        if (mounted) setState(() => _cards[t] = c);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Saves one "wave" card (strength before/after) when both sliders of this
  // tool were set — used by the "my dynamics" summary, never shown as a score.
  Future<void> _maybeSaveWave() async {
    if (_waveSaved) return;
    final before = _scales['before'];
    final after = _scales['after'];
    if (before == null || after == null) return;
    _waveSaved = true;
    // Both scale values also go to "Записи" / analytics when the tool's pages
    // say how to record them.
    for (final page in widget.tool.pages) {
      final id = page.scaleId;
      final rec = page.scaleRecord;
      final v = id == null ? null : _scales[id];
      if (rec != null && v != null) {
        await CourseRecords.scale(
          course: widget.course,
          context: widget.tool.title,
          record: rec,
          value: v.round(),
          note: id == 'before' ? 'до паузы' : id == 'after' ? 'после паузы' : null,
        );
      }
    }
    await CourseProgressStore.addCard(
      widget.course.id,
      CourseCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        cardType: 'wave',
        round: 0,
        createdAt: DateTime.now(),
        values: {'tool': widget.tool.id, 'before': before.round().toString(), 'after': after.round().toString()},
      ),
    );
  }

  void _next() {
    _maybeSaveWave();
    _timer?.cancel();
    _timerRunning = false;
    if (_index + 1 >= widget.tool.pages.length) {
      Navigator.pop(context);
    } else {
      setState(() => _index++);
    }
  }

  // "log:<cardType>:<field>=<value>" saves a small card (e.g. how a
  // meeting went) without any judgement attached, then closes the tool.
  Future<void> _log(String action) async {
    final parts = action.split(':');
    if (parts.length >= 3) {
      final kv = parts[2].split('=');
      await CourseProgressStore.addCard(
        widget.course.id,
        CourseCard(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          cardType: parts[1],
          round: 0,
          createdAt: DateTime.now(),
          values: {kv[0]: kv.length > 1 ? kv[1] : ''},
        ),
      );
    }
    if (mounted) Navigator.pop(context);
  }

  void _action(String action) {
    _maybeSaveWave();
    if (action.startsWith('log:')) {
      _log(action);
    } else if (action == 'close') {
      Navigator.pop(context);
    } else if (action.startsWith('tool:')) {
      final id = action.substring(5);
      final other = widget.course.tools.where((t) => t.id == id).toList();
      if (other.isEmpty) {
        Navigator.pop(context);
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SituationToolScreen(course: widget.course, tool: other.first)),
      );
    } else {
      _next();
    }
  }

  void _startTimer(int minutes) {
    _timer?.cancel();
    setState(() {
      _secondsLeft = minutes * 60;
      _timerRunning = true;
    });
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

  String _mmss(int s) =>
      '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

  Widget _card(ToolPage page) {
    final spec = page.showCard;
    if (spec == null) return const SizedBox.shrink();
    final parts = spec.split(':');
    final card = _cards[parts.first];
    final fields = parts.length > 1 ? parts[1].split(',') : <String>[];
    final values = [
      for (final f in fields)
        if ((card?.values[f] ?? '').isNotEmpty) card!.values[f]!
    ];
    final text = values.isEmpty
        ? page.cardFallback
        : (values.length == 1 ? values.first : values.map((v) => '• $v').join('\n'));
    if (text.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: getMargin(top: 16),
      padding: getPadding(left: 16, top: 14, right: 16, bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorConstant.cyan700.withOpacity(0.25)),
      ),
      child: Text(text,
          style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5)),
    );
  }

  Widget _scale(ToolPage page) {
    final id = page.scaleId;
    if (id == null) return const SizedBox.shrink();
    final v = _scales[id] ?? 5;
    return Padding(
      padding: getPadding(top: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${page.scaleLabel}  ${_scales.containsKey(id) ? v.round() : '–'}',
              style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
          Slider(
            value: v,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: ColorConstant.cyan700,
            inactiveColor: ColorConstant.cyan700.withOpacity(0.2),
            onChanged: (x) => setState(() => _scales[id] = x),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.tool.pages[_index];
    final isLast = _index == widget.tool.pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: getPadding(left: 20, right: 20, top: 8, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(widget.tool.title,
                        style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
                  ),
                  IconButton(
                    tooltip: 'close'.tr(),
                    icon: Icon(Icons.close_rounded, color: ColorConstant.gray800),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: getVerticalSize(14)),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(page.title, style: AppStyle.txtH1),
                      SizedBox(height: getVerticalSize(12)),
                      Text(page.body,
                          style: AppStyle.txtSFProDisplayLight16
                              .copyWith(color: ColorConstant.gray800, height: 1.5)),
                      _card(page),
                      _scale(page),
                      if (page.timerMinutes != null) ...[
                        SizedBox(height: getVerticalSize(20)),
                        Center(
                          child: Text(
                            _timerRunning
                                ? _mmss(_secondsLeft)
                                : _mmss(page.timerMinutes! * 60),
                            style: AppStyle.txtH1.copyWith(fontSize: getFontSize(34)),
                          ),
                        ),
                        SizedBox(height: getVerticalSize(8)),
                        Center(
                          child: TextButton(
                            onPressed: _timerRunning
                                ? () {
                                    _timer?.cancel();
                                    setState(() => _timerRunning = false);
                                  }
                                : () => _startTimer(page.timerMinutes!),
                            child: Text(
                                (_timerRunning ? 'course_timer_stop' : 'course_timer_start').tr(),
                                style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.cyan700)),
                          ),
                        ),
                      ],
                      if (page.helpline) ...[
                        SizedBox(height: getVerticalSize(14)),
                        const HelplineLink(),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const HelpNowScreen())),
                          child: Text('helpline_settings'.tr(),
                              style: AppStyle.txtSFProDisplayRegular11
                                  .copyWith(color: ColorConstant.gray500)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (page.buttons.isEmpty)
                CustomButton(
                  height: getVerticalSize(48),
                  width: double.infinity,
                  text: (isLast ? 'close' : 'course_next').tr().toUpperCase(),
                  variant: ButtonVariant.Cyan,
                  fontStyle: ButtonFontStyle.White16,
                  onTap: _next,
                )
              else
                for (final b in page.buttons)
                  Padding(
                    padding: getPadding(top: 8),
                    child: CustomButton(
                      height: getVerticalSize(48),
                      width: double.infinity,
                      text: b.label.toUpperCase(),
                      textIsFitted: true,
                      variant: ButtonVariant.Cyan,
                      fontStyle: ButtonFontStyle.White16,
                      onTap: () => _action(b.action),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
