import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/settings_pills/widgets/pill_card_widget.dart';

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

  @override
  Widget build(BuildContext context) {
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
        Wrap(
          direction: Axis.vertical,
          spacing: getVerticalSize(16),
          children: pills
              .map((e) => SizedBox(
            width: size.width -32,
                child: PillCardWidget(context,
                    pillModel: e, isSelected: isSelected, update: update),
              ))
              .toList(),
        ),
      ],
    );
  }
}
