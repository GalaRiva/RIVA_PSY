import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_style.dart';

import '../controller.dart';

const _weekdayShortKeys = [
  'monday_short',
  'tuesday_short',
  'wednesday_short',
  'thursday_short',
  'friday_short',
  'saturday_short',
  'sunday_short',
];

bool _sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

class CalendarRibbon extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onSelected;
  final DoseStatus? Function(DateTime) indicatorFor;

  const CalendarRibbon({
    Key? key,
    required this.selectedDate,
    required this.onSelected,
    required this.indicatorFor,
  }) : super(key: key);

  @override
  State<CalendarRibbon> createState() => _CalendarRibbonState();
}

class _CalendarRibbonState extends State<CalendarRibbon> {
  static const _daysBefore = 14;
  static const _daysAfter = 7;
  static const _itemWidth = 54.0;

  late final List<DateTime> _days;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day - _daysBefore);
    _days = List.generate(_daysBefore + _daysAfter + 1, (i) => start.add(Duration(days: i)));
    final targetOffset = getHorizontalSize(_itemWidth) * (_daysBefore - 2);
    _scrollController = ScrollController(
      initialScrollOffset: targetOffset < 0 ? 0 : targetOffset,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Color _dotColor(DoseStatus? status) {
    if (status == DoseStatus.taken) return Colors.green;
    if (status == DoseStatus.skipped) return Colors.orange;
    if (status == DoseStatus.pending) return ColorConstant.gray500;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: getVerticalSize(76),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final day = _days[index];
          final isSelected = _sameDay(day, widget.selectedDate);
          final isToday = _sameDay(day, DateTime.now());
          final status = widget.indicatorFor(day);
          return GestureDetector(
            onTap: () => widget.onSelected(day),
            child: Container(
              width: getHorizontalSize(_itemWidth - 6),
              margin: getMargin(right: 6),
              decoration: BoxDecoration(
                color: isSelected ? ColorConstant.cyan700 : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(getHorizontalSize(12)),
                border: isToday && !isSelected
                    ? Border.all(color: ColorConstant.cyan700, width: 1)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _weekdayShortKeys[day.weekday - 1].tr(),
                    style: AppStyle.txtSFProDisplayLight11.copyWith(
                        color: isSelected ? Colors.white : ColorConstant.gray800),
                  ),
                  SizedBox(height: getVerticalSize(4)),
                  Text(
                    '${day.day}',
                    style: AppStyle.txtSFProDisplayLight16.copyWith(
                        color: isSelected ? Colors.white : ColorConstant.gray800,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: getVerticalSize(6)),
                  Container(
                    width: getHorizontalSize(6),
                    height: getHorizontalSize(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _dotColor(status),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
