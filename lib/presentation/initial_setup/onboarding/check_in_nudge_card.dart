import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/models/day_event_model.dart';
import '../../../core/db/hive_db.dart';
import '../../../theme/app_colors.dart';

// For someone who used to note their state but hasn't for a few days while
// still opening the app: a quiet, text-free invitation to a one-tap check-in
// instead of asking for a full entry. Dismissing it hides it for a week.
class CheckInNudgeCard extends StatefulWidget {
  const CheckInNudgeCard({Key? key}) : super(key: key);

  @override
  State<CheckInNudgeCard> createState() => _CheckInNudgeCardState();
}

class _CheckInNudgeCardState extends State<CheckInNudgeCard> {
  static const _dismissedUntilKey = 'checkin_nudge_dismissed_until_v1';
  static const _quietDays = 5;
  bool _show = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final until = DateTime.tryParse(prefs.getString(_dismissedUntilKey) ?? '');
      if (until != null && DateTime.now().isBefore(until)) return;
      final raw = await HiveDB.getBox(HiveDBTags.dayEvents);
      if (raw.isEmpty) return; // never started — onboarding handles that
      DateTime? newest;
      for (final item in raw) {
        final d = DayEventModel.fromJson(jsonDecode(item)).date;
        if (d != null && (newest == null || d.isAfter(newest))) newest = d;
      }
      if (newest == null) return;
      if (DateTime.now().difference(newest) < const Duration(days: _quietDays)) return;
      if (mounted) setState(() => _show = true);
    } catch (_) {}
  }

  Future<void> _dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _dismissedUntilKey, DateTime.now().add(const Duration(days: 7)).toIso8601String());
    if (mounted) setState(() => _show = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return Padding(
      padding: getPadding(top: 12, bottom: 4),
      child: Container(
        width: double.infinity,
        padding: getPadding(left: 16, top: 12, right: 6, bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColorConstant.cyan700.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text('onb_checkin_nudge'.tr(),
                  style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
            ),
            IconButton(
              tooltip: 'close'.tr(),
              icon: Icon(Icons.close_rounded, size: getSize(18), color: ColorConstant.gray500),
              onPressed: _dismiss,
            ),
          ],
        ),
      ),
    );
  }
}
