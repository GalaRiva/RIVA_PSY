import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/settings/help_now_screen/help_now_screen.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/helpline_link.dart';

import '../data/course_progress_store.dart';
import '../data/course_records.dart';
import '../models/course.dart';
import '../widgets/breath_circle.dart';
import '../widgets/course_ui.dart';

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
  // Inline "write your own" editors, per page index.
  final Map<int, TextEditingController> _inlineCtrl = {};
  final Set<int> _editing = {};
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
    for (final c in _inlineCtrl.values) {
      c.dispose();
    }
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

  // Writes the one-field card straight from the tool page.
  Future<void> _saveInline(ToolPage page, int index) async {
    final inline = page.inline;
    final spec = page.showCard;
    final text = _inlineCtrl[index]?.text.trim() ?? '';
    if (inline == null || spec == null || text.isEmpty) return;
    final type = spec.split(':').first;
    final progress = await CourseProgressStore.load(widget.course.id);
    await CourseProgressStore.addCard(
      widget.course.id,
      CourseCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        cardType: type,
        round: progress.round,
        createdAt: DateTime.now(),
        values: {inline.field: text},
      ),
    );
    final latest = await CourseProgressStore.latest(widget.course.id, type);
    if (!mounted) return;
    setState(() {
      _cards[type] = latest;
      _editing.remove(index);
    });
    FocusScope.of(context).unfocus();
  }

  Widget _inlineEditor(ToolPage page, int index, String? current) {
    final inline = page.inline!;
    final ctrl = _inlineCtrl.putIfAbsent(index, () => TextEditingController(text: current ?? ''));
    return Padding(
      padding: getPadding(top: 20),
      child: SoftCard(
        padding: getPadding(left: 16, top: 16, right: 16, bottom: 16),
        radius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(inline.label,
                style: AppStyle.txtSFProDisplayLight16
                    .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            SizedBox(height: getVerticalSize(4)),
            Text('course_inline_hint'.tr(),
                style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary, height: 1.4)),
            SizedBox(height: getVerticalSize(12)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in inline.chips)
                  GestureDetector(
                    onTap: () {
                      ctrl.text = c;
                      ctrl.selection = TextSelection.collapsed(offset: c.length);
                      setState(() {});
                    },
                    child: Container(
                      padding: getPadding(left: 12, right: 12, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: ctrl.text == c ? AppColors.primary : AppColors.primaryLight.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(c,
                          style: AppStyle.txtSFProDisplayLight14.copyWith(
                              color: ctrl.text == c ? Colors.white : AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
              ],
            ),
            SizedBox(height: getVerticalSize(12)),
            TextField(
              controller: ctrl,
              minLines: 1,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textPrimary),
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'course_inline_own'.tr(),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.4)),
              ),
            ),
            SizedBox(height: getVerticalSize(12)),
            CapsuleButton(
                label: 'course_inline_save'.tr(),
                onTap: ctrl.text.trim().isEmpty ? null : () => _saveInline(page, index)),
          ],
        ),
      ),
    );
  }

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
    final hasOwn = values.isNotEmpty;
    if (page.inline != null) {
      // No own phrase yet (or "change"): pick a ready one or write your own,
      // right here — the example text alone is not enough.
      if (!hasOwn || _editing.contains(_index)) {
        return _inlineEditor(page, _index, hasOwn ? values.first : null);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: getPadding(top: 20),
            child: SoftCard(
              color: AppColors.primaryLight,
              padding: getPadding(left: 18, top: 16, right: 18, bottom: 16),
              radius: 22,
              child: Text(values.first,
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textPrimary, height: 1.55)),
            ),
          ),
          TextButton(
            onPressed: () => setState(() => _editing.add(_index)),
            style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 36)),
            child: Text('course_inline_change'.tr(),
                style: AppStyle.txtSFProDisplayLight14.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      );
    }
    final text = !hasOwn
        ? page.cardFallback
        : (values.length == 1 ? values.first : values.map((v) => '• $v').join('\n'));
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: getPadding(top: 20),
      child: SoftCard(
        color: hasOwn ? AppColors.primaryLight : null,
        padding: getPadding(left: 18, top: 16, right: 18, bottom: 16),
        radius: 22,
        child: Text(text,
            style: AppStyle.txtSFProDisplayLight16.copyWith(
                color: hasOwn ? AppColors.textPrimary : AppColors.textSecondary,
                height: 1.55,
                fontStyle: hasOwn ? FontStyle.normal : FontStyle.italic)),
      ),
    );
  }

  Widget _scale(ToolPage page) {
    final id = page.scaleId;
    if (id == null) return const SizedBox.shrink();
    final v = _scales[id] ?? 5;
    final set = _scales.containsKey(id);
    return Padding(
      padding: getPadding(top: 22),
      child: SoftCard(
        padding: getPadding(left: 18, top: 16, right: 14, bottom: 8),
        radius: 22,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(page.scaleLabel,
                      style: AppStyle.txtSFProDisplayLight14.copyWith(color: AppColors.textSecondary, height: 1.3)),
                ),
                SizedBox(width: getHorizontalSize(12)),
                Text(set ? '${v.round()}' : '–',
                    style: AppStyle.txtH1.copyWith(color: AppColors.primary, fontSize: getFontSize(34))),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
              ),
              child: Slider(
                value: v,
                min: 0,
                max: 10,
                divisions: 10,
                activeColor: AppColors.primary,
                inactiveColor: AppColors.primary.withOpacity(0.15),
                onChanged: (x) => setState(() => _scales[id] = x),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timerBlock(ToolPage page) {
    final total = page.timerMinutes! * 60;
    final left = _timerRunning ? _secondsLeft : total;
    final progress = _timerRunning ? _secondsLeft / total : 1.0;
    return Padding(
      padding: getPadding(top: 26),
      child: Column(
        children: [
          SizedBox(
            width: getSize(168),
            height: getSize(168),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: getSize(168),
                  height: getSize(168),
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 6,
                    strokeCap: StrokeCap.round,
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                Text(_mmss(left),
                    style: AppStyle.txtH1.copyWith(color: AppColors.textPrimary, fontSize: getFontSize(36))),
              ],
            ),
          ),
          SizedBox(height: getVerticalSize(16)),
          SizedBox(
            width: getHorizontalSize(190),
            child: CapsuleButton(
              outlined: true,
              label: (_timerRunning ? 'course_timer_stop' : 'course_timer_start').tr(),
              onTap: _timerRunning
                  ? () {
                      _timer?.cancel();
                      setState(() => _timerRunning = false);
                    }
                  : () => _startTimer(page.timerMinutes!),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CourseTextScale(child: _buildBody(context));

  Widget _buildBody(BuildContext context) {
    final page = widget.tool.pages[_index];
    final isLast = _index == widget.tool.pages.length - 1;
    final total = widget.tool.pages.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: getPadding(left: 20, right: 8, top: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.tool.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayRegular11
                            .copyWith(color: AppColors.textSecondary, letterSpacing: 0.4)),
                  ),
                  IconButton(
                    tooltip: 'close'.tr(),
                    icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Progress as a row of capsules: where I am in this short tool.
            if (total > 1)
              Padding(
                padding: getPadding(left: 20, right: 20, top: 2),
                child: Row(
                  children: [
                    for (var i = 0; i < total; i++)
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          height: 4,
                          margin: EdgeInsets.only(right: i == total - 1 ? 0 : 6),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i <= _index ? AppColors.primary : AppColors.primary.withOpacity(0.15),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOut,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.04, 0), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
                child: SingleChildScrollView(
                  key: ValueKey(_index),
                  padding: getPadding(left: 22, right: 22, top: 26, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(page.title,
                          style: AppStyle.txtH1.copyWith(
                              color: AppColors.textPrimary, fontSize: getFontSize(28), height: 1.15)),
                      SizedBox(height: getVerticalSize(14)),
                      Text(page.body,
                          style: AppStyle.txtSFProDisplayLight16.copyWith(
                              color: AppColors.textPrimary.withOpacity(0.8), height: 1.6, fontSize: getFontSize(17))),
                      _card(page),
                      _scale(page),
                      if (page.breathCycles != null)
                        BreathCircle(
                            inhale: page.breathIn ?? 4, exhale: page.breathOut ?? 6, cycles: page.breathCycles!),
                      if (page.timerMinutes != null) _timerBlock(page),
                      if (page.helpline) ...[
                        SizedBox(height: getVerticalSize(18)),
                        const HelplineLink(),
                        TextButton(
                          onPressed: () => Navigator.push(
                              context, MaterialPageRoute(builder: (_) => const HelpNowScreen())),
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                          child: Text('helpline_settings'.tr(),
                              style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: getPadding(left: 20, right: 20, top: 4, bottom: 18),
              child: Column(
                children: [
                  if (page.buttons.isEmpty)
                    CapsuleButton(label: (isLast ? 'close' : 'course_next').tr(), onTap: _next)
                  else
                    for (var i = 0; i < page.buttons.length; i++)
                      Padding(
                        padding: getPadding(top: i == 0 ? 0 : 10),
                        child: CapsuleButton(
                          label: page.buttons[i].label,
                          outlined: i > 0,
                          onTap: () => _action(page.buttons[i].action),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
