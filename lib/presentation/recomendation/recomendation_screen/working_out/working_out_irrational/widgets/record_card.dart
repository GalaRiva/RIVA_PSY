import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/models/spent_record_model.dart';

import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/image_constant.dart';
import '../../../../../../theme/app_style.dart';
import '../../../../../../widgets/custom_button.dart';
import '../../../../../../widgets/expandeble_text_widget.dart';
import '../../ui/record_text_button.dart';

class RecordCard extends StatelessWidget {
  final VoidCallback? onButtonTap;
  final RecordCardMode mode;
  final bool showShadow;
  final Widget? image;
  final RecordCardDataType dataType;

  const RecordCard(
      {Key? key,
      this.onButtonTap,
      required this.mode,
      required this.dataType,
      this.showShadow = true,
      this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return mode is StandardRecordCardMode
        ? standardMode(mode as StandardRecordCardMode)
        : alternativeMode(mode as AlternativeRecordCardMode);
  }

  Widget standardMode(StandardRecordCardMode mode) {
    final dayEventModel = mode.dayEventModel;
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
          color: ColorConstant.gray200,
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: showShadow
              ? [
                  BoxShadow(
                      color: ColorConstant.cardShadow, offset: Offset(0, -0.2))
                ]
              : null),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Was crashing into RecordTextButton with no gap once both
                // texts' combined width reached the row's own width —
                // spaceBetween only spaces children apart when there's
                // leftover room, neither child shrinks on its own.
                Flexible(
                  child: Text(
                    dataType == RecordCardDataType.Thought
                        ? 'auto_thought'.tr()
                        : 'auto_do'.tr(),
                    style: AppStyle.txtSFProDisplayLight16,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 8),
                RecordTextButton(dayEventModel: dayEventModel)
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 1,
                  width: 26,
                  color: Colors.white,
                ),
                Container(
                  height: 1,
                  width: 26,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            ExpandableTextWidget(
              text:
                  '${dataType == RecordCardDataType.Thought ? dayEventModel.firstThoughts! : dayEventModel.whatIDo!}',
              maxLines: 3,
            ),
            SizedBox(
              height: 15,
            ),
            image ??
                AspectRatio(
                  aspectRatio: dataType == RecordCardDataType.Thought
                      ? 320 / 200 : 300 / 220.7,
                  child: Container(
                    decoration: BoxDecoration(
                        color: ColorConstant.darkWhite,
                        borderRadius: BorderRadius.circular(3)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.asset(
                            dataType == RecordCardDataType.Thought
                                ? ImageConstant.humanThoughtImg
                                : ImageConstant.humanDoImg)),
                  ),
                ),
            SizedBox(
              height: 15,
            ),
            CustomButton(
              text: dataType == RecordCardDataType.Thought
                  ? 'challenge_thought'.tr().toUpperCase()
                  : 'challenge_do'.tr().toUpperCase(),
              variant: onButtonTap != null
                  ? ButtonVariant.Cyan
                  : ButtonVariant.OutlineGray,
              fontStyle: onButtonTap != null
                  ? ButtonFontStyle.White16
                  : ButtonFontStyle.Gray16,
              onTap: onButtonTap,
            )
          ],
        ),
      ),
    );
  }

  Widget alternativeMode(AlternativeRecordCardMode mode) {
    final spentRecordModel = mode.spentRecordModel;
    final dayEventModel = mode.dayEventModel;
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
              color: ColorConstant.cyan700,
              border: Border.all(color: Colors.white, width: 1),
              boxShadow: showShadow
                  ? [
                      BoxShadow(
                          color: ColorConstant.cardShadow,
                          offset: Offset(0, -0.2))
                    ]
                  : null),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    dataType == RecordCardDataType.Thought
                        ? 'alternative_thought'.tr().toUpperCase()
                        : 'alternative_do'.tr().toUpperCase(),
                    style: AppStyle.txtSFProDisplayLight16
                        .copyWith(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 1,
                      width: 26,
                      color: Colors.white,
                    ),
                    Text(
                      dayEventModel.date!.formatForRecord('dd.MM.yy'),
                      style: AppStyle.txtSFProDisplayLight16
                          .copyWith(color: Colors.white),
                    ),
                    TextButton(
                        onPressed: mode.onRedoTap,
                        child: Text('${'redo'.tr()} >',
                            style: AppStyle.txtSFProDisplayLight16
                                .copyWith(color: Colors.white))),
                    Container(
                      height: 1,
                      width: 26,
                      color: Colors.white,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                ExpandableTextWidget(
                  text:
                      '${dataType == RecordCardDataType.Thought ? spentRecordModel.alternativeThoughts : spentRecordModel.alternativeDo}',
                  maxLines: 3,
                  textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white),
                  textButtonStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white),
                ),
                SizedBox(
                  height: 15,
                ),
                AspectRatio(
                  aspectRatio: 320 / 200,
                  child: Container(
                    decoration: BoxDecoration(
                        color: ColorConstant.darkWhite,
                        borderRadius: BorderRadius.circular(3)),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: Image.asset(ImageConstant.humanAlternativeImg)),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Align(
            alignment: Alignment.topCenter,
            child: CustomButton(
              text: 'continue'.tr(),
              variant: ButtonVariant.Cyan,
              fontStyle: ButtonFontStyle.White16,
              onTap: onButtonTap,
            ),
          ),
        )
      ],
    );
  }
}

abstract class RecordCardMode {}

class StandardRecordCardMode extends RecordCardMode {
  final DayEventModel dayEventModel;

  StandardRecordCardMode(this.dayEventModel);
}

class AlternativeRecordCardMode extends RecordCardMode {
  final SpentRecordModel spentRecordModel;
  final DayEventModel dayEventModel;
  final VoidCallback? onRedoTap;

  AlternativeRecordCardMode(
      {this.onRedoTap,
      required this.dayEventModel,
      required this.spentRecordModel});
}

enum RecordCardDataType { Thought, Do }
