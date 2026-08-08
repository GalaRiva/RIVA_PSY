import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills/widgets/pill_card_widget.dart';

import '../../models/pill_model.dart';

class PillListWidget extends StatelessWidget {
  final bool isSelected;
  final List<PillModel> pills;
  final Function update;
  final String title;

  const PillListWidget(
      {Key? key,
      required this.pills,
      required this.isSelected,
      required this.update,
      required this.title})
      : super(key: key);

  // Carousel cards can each need a different height (varies with
  // hoursOfTakingPills.length, see pill_card_widget.dart's _bodyHeight) —
  // PageView gives every page the same height, so the carousel uses the
  // tallest card among the current pills rather than each card's own.
  double _cardHeight(PillModel pill) {
    final hours = pill.hoursOfTakingPills.length;
    final bodyHeight = getVerticalSize(hours > 2 ? 47 + ((hours % 2) * 21) : 47);
    return getVerticalSize(30) + bodyHeight;
  }

  @override
  Widget build(BuildContext context) {
    final carouselHeight = pills.isEmpty
        ? 0.0
        : pills.map(_cardHeight).reduce((a, b) => a > b ? a : b);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: !isSelected && pills.isNotEmpty,
            child: Text(
          title,
          style: AppStyle.txtSFProDisplayLight11
              .copyWith(color: ColorConstant.gray800),
        )),
        Visibility(
          visible: pills.isNotEmpty,
          child: SizedBox(
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
        ),
      ],
    );
  }
}
