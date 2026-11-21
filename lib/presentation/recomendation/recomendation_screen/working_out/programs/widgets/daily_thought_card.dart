import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riva_psy/core/db/hive_db.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/models/desire/desire.dart';
import 'package:riva_psy/theme/app_colors.dart';

import '../../data/repository.dart';
import 'course_ui.dart';

// "Одна мысль на каждый день": the core CBT habit of the course. Two small
// steps, both done in the existing tools: write one harmful thought into the
// Path (the diary), then work it through in "Проработать иррациональное".
// The ticks are read from today's real records, so they cannot get out of
// sync with what the person actually did. No streaks, no counters of days.
class DailyThoughtCard extends StatefulWidget {
  final bool dark;
  // Called after every reload with how many of the three are done today.
  final ValueChanged<int>? onChanged;
  const DailyThoughtCard({Key? key, this.dark = false, this.onChanged}) : super(key: key);

  @override
  State<DailyThoughtCard> createState() => _DailyThoughtCardState();
}

class _DailyThoughtCardState extends State<DailyThoughtCard> with WidgetsBindingObserver {
  int _recorded = 0;
  int _worked = 0;
  int _desires = 0;
  bool _loaded = false;
  // A short warm line after one of the three is done (or all three). Never a streak.
  String? _praiseKey;
  bool _praiseAll = false;
  Timer? _praiseTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    _praiseTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  static bool _isToday(DateTime? d) {
    if (d == null) return false;
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  Future<void> _load() async {
    try {
      final repo = WorkingOutRepo();
      final events = await repo.getDayEvent();
      final spent = await repo.getEvent();
      final rec = events
          .where((e) => e.emotionInDayEvent == EmotionInDayEvent.NEGATIVE && _isToday(e.date))
          .length;
      final wk = spent.where((e) => _isToday(e.date)).length;
      var ds = 0;
      try {
        ds = (await HiveDB.getBox(HiveDBTags.desires))
            .map((e) => Desire.fromJson(jsonDecode(e)))
            .where((d) => _isToday(d.createdAt))
            .length;
      } catch (_) {}
      if (mounted) {
        final wasLoaded = _loaded;
        final before = [_recorded > 0, _worked > 0, _desires > 0];
        final after = [rec > 0, wk > 0, ds > 0];
        String? praise;
        var all = false;
        if (wasLoaded) {
          const keys = ['course_daily_praise_record', 'course_daily_praise_work', 'course_daily_praise_desire'];
          for (var i = 0; i < 3; i++) {
            if (!before[i] && after[i]) praise = keys[i];
          }
          if (!before.every((e) => e) && after.every((e) => e)) {
            praise = 'course_daily_praise_all';
            all = true;
          }
        }
        setState(() {
          _recorded = rec;
          _worked = wk;
          _desires = ds;
          _loaded = true;
          if (praise != null) {
            _praiseKey = praise;
            _praiseAll = all;
          }
        });
        widget.onChanged?.call(after.where((e) => e).length);
        if (praise != null) {
          all ? HapticFeedback.mediumImpact() : HapticFeedback.lightImpact();
          _praiseTimer?.cancel();
          _praiseTimer = Timer(Duration(seconds: all ? 10 : 6), () {
            if (mounted) setState(() => _praiseKey = null);
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  // The first time a person is sent to another part of the app from here, say
  // briefly what will open and how to come back. Once per destination.
  Future<bool> _explainFirst(String key, String titleKey, String bodyKey) async {
    var seen = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      seen = prefs.getBool('course_first_$key') ?? false;
      if (!seen) await prefs.setBool('course_first_$key', true);
    } catch (_) {
      seen = true;
    }
    if (seen || !mounted) return true;
    final go = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => CourseTextScale(
        child: SafeArea(
          child: Padding(
            padding: getPadding(left: 24, right: 24, top: 14, bottom: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                SizedBox(height: getVerticalSize(16)),
                Text(titleKey.tr(),
                    style: AppStyle.txtH2.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700, height: 1.2)),
                SizedBox(height: getVerticalSize(10)),
                Text(bodyKey.tr(),
                    style: AppStyle.txtSFProDisplayLight16.copyWith(color: AppColors.textPrimary, height: 1.55)),
                SizedBox(height: getVerticalSize(8)),
                Row(
                  children: [
                    Icon(Icons.arrow_back_rounded, size: getSize(18), color: AppColors.primary),
                    SizedBox(width: getHorizontalSize(8)),
                    Expanded(
                      child: Text('course_first_back'.tr(),
                          style: courseBody().copyWith(color: courseSoft(false), height: 1.45)),
                    ),
                  ],
                ),
                SizedBox(height: getVerticalSize(20)),
                CapsuleButton(label: 'course_first_open'.tr(), onTap: () => Navigator.pop(ctx, true)),
              ],
            ),
          ),
        ),
      ),
    );
    return go == true;
  }

  Future<void> _openPath() async {
    if (!await _explainFirst('path', 'course_first_path_title', 'course_first_path_body')) return;
    await Navigator.pushNamed(context, AppRoutes.whatHappened,
        arguments: DayEventModel().copyWith(howDoYouFeel: 5, showInCharts: true));
    if (mounted) _load();
  }

  Future<void> _openWorkOut() async {
    if (!await _explainFirst('work', 'course_first_work_title', 'course_first_work_body')) return;
    AppRoutes.currentRoute = AppRoutes.recommendations;
    await Navigator.pushNamed(context, AppRoutes.recommendations, arguments: {'initialTab': 2});
    if (mounted) _load();
  }

  Future<void> _openDesires() async {
    if (!await _explainFirst('desires', 'course_first_desires_title', 'course_first_desires_body')) return;
    AppRoutes.currentRoute = AppRoutes.recommendations;
    await Navigator.pushNamed(context, AppRoutes.recommendations, arguments: {'workingOutTab': 2});
    if (mounted) _load();
  }

  Widget _row(String labelKey, bool done, VoidCallback onTap, {String? hint}) {
    final dark = widget.dark;
    final accent = courseAccent(dark);
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 52),
        child: Padding(
          padding: getPadding(top: 6, bottom: 6),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 380),
                switchInCurve: Curves.elasticOut,
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Icon(done ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                    key: ValueKey(done), size: getSize(24), color: done ? accent : courseMuted(dark)),
              ),
              SizedBox(width: getHorizontalSize(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(labelKey.tr(),
                        style: AppStyle.txtSFProDisplayLight16
                            .copyWith(color: courseText(dark), fontWeight: FontWeight.w600, height: 1.25)),
                    if (hint != null)
                      Text(hint, style: courseCaption().copyWith(color: courseMuted(dark))),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: courseMuted(dark)),
            ],
          ),
        ),
      ),
    );
  }

  // A warm line, not a trophy: fades in, stays a few seconds. For all three the
  // bubble is filled and carries the longer sentence.
  Widget _praiseBubble(bool dark) {
    final accent = courseAccent(dark);
    final filled = _praiseAll;
    return TweenAnimationBuilder<double>(
      key: ValueKey(_praiseKey),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(
          opacity: v.clamp(0.0, 1.0), child: Transform.scale(scale: 0.94 + 0.06 * v, alignment: Alignment.centerLeft, child: child)),
      child: Container(
        width: double.infinity,
        padding: getPadding(left: 14, top: 12, right: 14, bottom: 12),
        decoration: BoxDecoration(
          color: filled ? accent : accent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(filled ? Icons.favorite_rounded : Icons.auto_awesome_rounded,
                size: getSize(20), color: filled ? (dark ? kNightBg : Colors.white) : accent),
            SizedBox(width: getHorizontalSize(10)),
            Expanded(
              child: Text(
                filled ? 'course_daily_all'.tr() : _praiseKey!.tr(),
                style: courseBody().copyWith(
                    color: filled ? (dark ? kNightBg : Colors.white) : courseText(dark),
                    fontWeight: FontWeight.w600,
                    height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final all = _loaded && _recorded > 0 && _worked > 0;
    return SoftCard(
      dark: dark,
      color: dark ? null : AppColors.primaryLight,
      padding: getPadding(left: 16, top: 16, right: 12, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note_rounded, color: courseAccent(dark), size: getSize(24)),
              SizedBox(width: getHorizontalSize(10)),
              Expanded(
                child: Text('course_daily_title'.tr(),
                    style: AppStyle.txtH2.copyWith(color: courseText(dark), fontWeight: FontWeight.w600, height: 1.2)),
              ),
            ],
          ),
          SizedBox(height: getVerticalSize(8)),
          Padding(
            padding: getPadding(right: 4),
            child: Text('course_daily_body'.tr(),
                style: courseBody().copyWith(color: courseSoft(dark), height: 1.5)),
          ),
          SizedBox(height: getVerticalSize(8)),
          _row('course_daily_record', _recorded > 0, _openPath),
          _row('course_daily_work', _worked > 0, _openWorkOut),
          _row('course_daily_desire', _desires > 0, _openDesires),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _praiseKey != null
                ? Padding(
                    padding: getPadding(top: 6, bottom: 4, right: 4),
                    child: _praiseBubble(dark),
                  )
                : all
                    ? Padding(
                        padding: getPadding(top: 4, bottom: 4, right: 4),
                        child: Text('course_daily_all'.tr(),
                            style: courseCaption().copyWith(color: courseAccent(dark), fontWeight: FontWeight.w600)),
                      )
                    : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
