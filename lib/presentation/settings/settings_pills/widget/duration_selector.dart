import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/widgets/chip_selector.dart';

class DurationSelector extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;

  const DurationSelector({Key? key, required this.selected, required this.onSelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChipSelector<String>(
      selected: selected,
      onSelected: onSelected,
      options: [
        ChipOption(value: '7_days', label: 'duration_7_days'.tr()),
        ChipOption(value: '14_days', label: 'duration_14_days'.tr()),
        ChipOption(value: '1_month', label: 'duration_1_month'.tr()),
        ChipOption(value: 'unlimited', label: 'duration_unlimited'.tr()),
        ChipOption(value: 'custom', label: 'duration_custom'.tr()),
      ],
    );
  }
}

/// Computes the end date for a duration preset given a start date.
/// Returns null for 'custom', which is resolved via the full calendar screen instead.
DateTime? durationEndDate(String durationType, DateTime start) {
  switch (durationType) {
    case '7_days':
      return start.add(const Duration(days: 7));
    case '14_days':
      return start.add(const Duration(days: 14));
    case '1_month':
      return DateTime(start.year, start.month + 1, start.day, start.hour, start.minute, start.second);
    case 'unlimited':
      return DateTime(start.year + 100, start.month, start.day);
    default:
      return null;
  }
}
