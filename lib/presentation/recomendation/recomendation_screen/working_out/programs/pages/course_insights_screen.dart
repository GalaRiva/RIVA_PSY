import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_pop_button.dart';

import '../data/course_progress_store.dart';
import '../data/course_records.dart';
import '../models/course.dart';

// "Моя динамика": three quiet, purely descriptive views of the person's own
// entries — a weekly check-in with a small chart, the things that repeat in
// their chains, and how the strength of an urge changed during a pause. No
// goals, no thresholds, no scores; everything stays on the phone.
class CourseInsightsScreen extends StatefulWidget {
  final Course course;
  const CourseInsightsScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseInsightsScreen> createState() => _CourseInsightsScreenState();
}

class _CourseInsightsScreenState extends State<CourseInsightsScreen> {
  List<CourseCard> _cards = [];
  final Map<String, double> _weekly = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    for (final q in widget.course.weekly) {
      _weekly[q.id] = 5;
    }
    _reload();
  }

  Future<void> _reload() async {
    final c = await CourseProgressStore.cards(widget.course.id);
    if (mounted) setState(() => _cards = c);
  }

  List<CourseCard> _of(String type) => _cards.where((c) => c.cardType == type).toList();

  Future<void> _saveWeekly() async {
    setState(() => _saving = true);
    await CourseProgressStore.addCard(
      widget.course.id,
      CourseCard(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        cardType: 'weekly',
        round: 0,
        createdAt: DateTime.now(),
        values: {for (final q in widget.course.weekly) q.id: (_weekly[q.id] ?? 5).round().toString()},
      ),
    );
    for (final q in widget.course.weekly) {
      final rec = q.record;
      if (rec == null) continue;
      await CourseRecords.scale(
        course: widget.course,
        context: 'course_dynamics'.tr(),
        record: rec,
        value: (_weekly[q.id] ?? 5).round(),
        note: 'раз в неделю',
      );
    }
    await _reload();
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('course_saved'.tr())));
    }
  }

  static const _seriesColors = [Color(0xFF1499A1), Color(0xFFC9A227), Color(0xFF7B6FA8), Color(0xFFC46B5A)];

  Widget _title(String key) => Padding(
        padding: getPadding(top: 22, bottom: 8),
        child: Text(key.tr().toUpperCase(),
            style: AppStyle.txtSFProDisplayRegular11
                .copyWith(color: ColorConstant.cyan700, letterSpacing: 0.5)),
      );

  Widget _weeklySection() {
    final qs = widget.course.weekly;
    if (qs.isEmpty) return const SizedBox.shrink();
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500);
    final history = _of('weekly').reversed.toList(); // oldest first
    final last = history.length > 12 ? history.sublist(history.length - 12) : history;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('course_dyn_week'),
        for (final q in qs) ...[
          Text('${q.label}  ${(_weekly[q.id] ?? 5).round()}',
              style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
          Slider(
            value: _weekly[q.id] ?? 5,
            min: 0,
            max: 10,
            divisions: 10,
            activeColor: ColorConstant.cyan700,
            inactiveColor: ColorConstant.cyan700.withOpacity(0.2),
            onChanged: (v) => setState(() => _weekly[q.id] = v),
          ),
        ],
        CustomButton(
          height: getVerticalSize(44),
          width: double.infinity,
          text: 'course_save'.tr().toUpperCase(),
          variant: ButtonVariant.Cyan,
          fontStyle: ButtonFontStyle.White16,
          onTap: _saving ? null : _saveWeekly,
        ),
        SizedBox(height: getVerticalSize(12)),
        if (last.length < 2)
          Text('course_dyn_chart_hint'.tr(), style: small)
        else ...[
          SizedBox(
            height: getVerticalSize(150),
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 10,
                gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: ColorConstant.gray50, strokeWidth: 1)),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineTouchData: const LineTouchData(enabled: false),
                lineBarsData: [
                  for (var qi = 0; qi < qs.length; qi++)
                    LineChartBarData(
                      spots: [
                        for (var i = 0; i < last.length; i++)
                          FlSpot(i.toDouble(), double.tryParse(last[i].values[qs[qi].id] ?? '') ?? 0),
                      ],
                      isCurved: true,
                      color: _seriesColors[qi % _seriesColors.length],
                      barWidth: 2.5,
                      dotData: const FlDotData(show: true),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: getVerticalSize(8)),
          for (var qi = 0; qi < qs.length; qi++)
            Padding(
              padding: getPadding(bottom: 4),
              child: Row(
                children: [
                  Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle, color: _seriesColors[qi % _seriesColors.length])),
                  SizedBox(width: getHorizontalSize(8)),
                  Expanded(child: Text(qs[qi].label, style: small)),
                ],
              ),
            ),
          Text('course_dyn_not_score'.tr(), style: small),
        ],
      ],
    );
  }

  // Counts how many saved chains mention each word/phrase (split on commas),
  // per field, and lists what repeats.
  Widget _triggersSection() {
    final chains = _of('chain');
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500);
    if (chains.length < 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('course_dyn_triggers'),
          Text('course_dyn_triggers_hint'.tr(), style: small),
        ],
      );
    }
    CourseTask? task;
    for (final s in widget.course.steps) {
      if (s.task.cardType == 'chain') task = s.task;
    }
    final fields = [
      for (final f in (task?.fields ?? <CourseField>[]))
        if (['situation', 'emotions', 'body'].contains(f.id)) f
    ];
    final blocks = <Widget>[];
    for (final f in fields) {
      final counts = <String, int>{};
      final display = <String, String>{};
      for (final c in chains) {
        final seen = <String>{};
        for (final raw in (c.values[f.id] ?? '').split(RegExp(r'[,;]'))) {
          final t = raw.trim();
          if (t.isEmpty) continue;
          final k = t.toLowerCase();
          if (seen.add(k)) {
            counts[k] = (counts[k] ?? 0) + 1;
            display.putIfAbsent(k, () => t);
          }
        }
      }
      final top = counts.entries.where((e) => e.value >= 2).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (top.isEmpty) continue;
      blocks.add(Padding(
        padding: getPadding(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(f.label, style: small),
            for (final e in top.take(3))
              Padding(
                padding: getPadding(top: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: getHorizontalSize(140),
                      child: Text(display[e.key]!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Container(height: 8, decoration: BoxDecoration(color: ColorConstant.gray50, borderRadius: BorderRadius.circular(4))),
                          FractionallySizedBox(
                            widthFactor: (e.value / chains.length).clamp(0.05, 1.0),
                            child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                    color: ColorConstant.cyan700.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4))),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: getHorizontalSize(8)),
                    Text('${e.value}/${chains.length}', style: small),
                  ],
                ),
              ),
          ],
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('course_dyn_triggers'),
        if (blocks.isEmpty) Text('course_dyn_nothing_repeats'.tr(), style: small) else ...blocks,
        Text('course_dyn_descr_only'.tr(), style: small),
      ],
    );
  }

  Widget _waveSection() {
    final waves = _of('wave');
    final small = AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500);
    if (waves.length < 3) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('course_dyn_wave'),
          Text('course_dyn_wave_hint'.tr(), style: small),
        ],
      );
    }
    double avg(String k) =>
        waves.map((w) => double.tryParse(w.values[k] ?? '') ?? 0).reduce((a, b) => a + b) / waves.length;
    final b = avg('before');
    final a = avg('after');
    final lower = waves.where((w) => (double.tryParse(w.values['after'] ?? '') ?? 0) < (double.tryParse(w.values['before'] ?? '') ?? 0)).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('course_dyn_wave'),
        Text(
            'course_dyn_wave_text'.tr(namedArgs: {
              'before': b.toStringAsFixed(1),
              'after': a.toStringAsFixed(1),
              'n': '${waves.length}',
              'lower': '$lower',
            }),
            style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5)),
        SizedBox(height: getVerticalSize(6)),
        Text('course_dyn_wave_note'.tr(), style: small),
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
              Text('course_dynamics'.tr(), style: AppStyle.txtH1),
              SizedBox(height: getVerticalSize(6)),
              Text('course_dyn_intro'.tr(),
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5)),
              _weeklySection(),
              _triggersSection(),
              _waveSection(),
            ],
          ),
        ),
      ),
    );
  }
}
