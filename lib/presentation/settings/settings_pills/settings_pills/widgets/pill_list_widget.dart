import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills/widgets/pill_card_widget.dart';

import '../../models/pill_model.dart';

class PillListWidget extends StatelessWidget {
  final bool isSelected;
  final List<PillModel> pills;
  final Function update;
  final String title;
  final String emptyText;

  const PillListWidget(
      {Key? key,
      required this.pills,
      required this.isSelected,
      required this.update,
      required this.title,
      required this.emptyText})
      : super(key: key);

  // Carousel cards can each need a different height (the progress bar only
  // shows for in-progress courses under a year long, see pill_card_widget.dart's
  // showProgress) — PageView gives every page the same height, so the carousel
  // uses the tallest card among the current pills rather than each card's own.
  double _cardHeight(PillModel pill) {
    final totalDays = pill.endDate.difference(pill.startDate).inDays;
    final showProgress = isSelected && totalDays > 0 && totalDays <= 366;
    return getVerticalSize(showProgress ? 118 : 86);
  }

  @override
  Widget build(BuildContext context) {
    final carouselHeight = pills.isEmpty
        ? 0.0
        : pills.map(_cardHeight).reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyle.txtSFProDisplayLight11
              .copyWith(color: ColorConstant.gray800),
        ),
        SizedBox(height: getVerticalSize(10)),
        pills.isEmpty
            ? Padding(
                padding: getPadding(top: 10, bottom: 10),
                child: Text(
                  emptyText,
                  style: AppStyle.txtSFProDisplayLight14
                      .copyWith(color: ColorConstant.gray800),
                ),
              )
            : SizedBox(
                height: carouselHeight,
                width: size.width - 32,
                child: PageView.builder(
                  controller: PageController(viewportFraction: 0.92),
                  itemCount: pills.length,
                  itemBuilder: (context, index) => Padding(
                    padding: getPadding(right: 12),
                    child: PillCardWidget(context,
                        pillModel: pills[index],
                        isSelected: isSelected,
                        update: update),
                  ),
                ),
              ),
      ],
    );
  }
}
