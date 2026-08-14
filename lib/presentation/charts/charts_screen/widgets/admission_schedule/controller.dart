import 'package:flutter/material.dart';

import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/models/insight_model.dart';
import 'package:riva_psy/core/services/insights/insight_engine.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/adoption_model.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/pill_model.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills_add_bottom_sheet/settings_pills_add_bottom_sheet.dart';

import '../../../../settings/settings_pills/repository.dart';
import '../../../../../theme/app_colors.dart';

enum TrackerView { daily, stats }

enum DoseStatus { taken, skipped, pending }

class ScheduledDose {
  final PillModel pill;
  final String time;

  ScheduledDose({required this.pill, required this.time});
}

class AdmissionScheduleController extends GetxController {
  bool scheduleWasCreated = false;
  var pills = <PillModel>[];

  DateTime _selectedDate = _dateOnly(DateTime.now());
  DateTime get selectedDate => _selectedDate;

  TrackerView view = TrackerView.daily;

  final _pillsRepo = PillsRepo();

  static DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Future initialize() async {
    pills = await _pillsRepo.getEvent();
    scheduleWasCreated = pills.isNotEmpty;
  }

  void setView(TrackerView v) {
    view = v;
    update();
  }

  void selectDate(DateTime date) {
    _selectedDate = _dateOnly(date);
    update();
  }

  Future createSchedule(BuildContext context) async {
    if (!scheduleWasCreated) {
      showModalBottomSheet(
        backgroundColor: AppColors.background,
          context: context,
          isScrollControlled: true,
          builder: (context) => PillsAddBottomSheet()).then((value) async {
        pills = await _pillsRepo.getEvent();
        scheduleWasCreated = pills.isNotEmpty;
        update();
      });
      update();
    }
  }

  bool _isScheduledOn(PillModel pill, DateTime date) {
    final d = _dateOnly(date);
    final start = _dateOnly(pill.startDate);
    final end = _dateOnly(pill.endDate);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  List<ScheduledDose> dosesOn(DateTime date) {
    final list = <ScheduledDose>[];
    for (final pill in pills) {
      if (_isScheduledOn(pill, date)) {
        for (final time in pill.hoursOfTakingPills) {
          list.add(ScheduledDose(pill: pill, time: time));
        }
      }
    }
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  DoseStatus statusOf(PillModel pill, DateTime date, String time) {
    for (final a in pill.adoptions) {
      if (_sameDay(a.adoptionDate, date)) {
        if (a.adoptionTimes.contains(time)) return DoseStatus.taken;
        if (a.skippedTimes.contains(time)) return DoseStatus.skipped;
      }
    }
    return DoseStatus.pending;
  }

  DateTime doseDateTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Future markTaken(PillModel pill, DateTime date, String time) => _setStatus(pill, date, time, status: DoseStatus.taken);

  Future markSkipped(PillModel pill, DateTime date, String time) => _setStatus(pill, date, time, status: DoseStatus.skipped);

  Future resetStatus(PillModel pill, DateTime date, String time) => _setStatus(pill, date, time, status: DoseStatus.pending);

  Future _setStatus(PillModel pill, DateTime date, String time, {required DoseStatus status}) async {
    final list = await _pillsRepo.getEvent();
    for (final item in list) {
      if (item.toJson().toString() == pill.toJson().toString()) {
        AdoptionModel? existing;
        for (final a in item.adoptions) {
          if (_sameDay(a.adoptionDate, date)) {
            existing = a;
            break;
          }
        }
        if (existing == null) {
          existing = AdoptionModel(adoptionDate: date, adoptionTimes: []);
          item.adoptions.add(existing);
        }
        existing.adoptionTimes.remove(time);
        existing.skippedTimes.remove(time);
        if (status == DoseStatus.taken) {
          existing.adoptionTimes.add(time);
        } else if (status == DoseStatus.skipped) {
          existing.skippedTimes.add(time);
        }
        break;
      }
    }
    await _pillsRepo.updateEvent(list);
    pills = list;
    InsightEngine().run().catchError((_) => <InsightModel>[]);
    update();
  }

  /// null = nothing scheduled that day (shown gray), taken = all doses taken,
  /// skipped = at least one dose skipped or missed (past due, still pending), pending = rest still upcoming.
  DoseStatus? dayIndicatorStatus(DateTime date) {
    final doses = dosesOn(date);
    if (doses.isEmpty) return null;
    final now = DateTime.now();
    bool allTaken = true;
    bool anyMissed = false;
    for (final d in doses) {
      final status = statusOf(d.pill, date, d.time);
      if (status == DoseStatus.taken) continue;
      allTaken = false;
      if (status == DoseStatus.skipped) {
        anyMissed = true;
      } else if (doseDateTime(date, d.time).isBefore(now)) {
        anyMissed = true;
      }
    }
    if (allTaken) return DoseStatus.taken;
    if (anyMissed) return DoseStatus.skipped;
    return DoseStatus.pending;
  }

  /// Share of already-due doses taken on time over the last 30 days, 0..1.
  /// null means no doses were due yet in that window (nothing to show).
  double? monthlyAdherence() {
    final now = DateTime.now();
    int total = 0;
    int taken = 0;
    for (int i = 0; i < 30; i++) {
      final date = _dateOnly(now).subtract(Duration(days: i));
      for (final d in dosesOn(date)) {
        final due = doseDateTime(date, d.time);
        if (due.isAfter(now)) continue;
        total++;
        if (statusOf(d.pill, date, d.time) == DoseStatus.taken) taken++;
      }
    }
    if (total == 0) return null;
    return taken / total;
  }
}
