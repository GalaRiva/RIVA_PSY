import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../../core/models/day_event_model.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/event_card.dart';
import '../../../../../widgets/emotion_color_blob.dart';
import '../controller.dart';

class NeutralTab extends StatelessWidget {
  final DayEventModel dayEventModel;
  final int number;
  final K27Controller controller;
  final List<EventModel> list;

  const NeutralTab(
      {Key? key, required this.controller, required this.number, required this.dayEventModel, required this.list})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.currentTab = 3;
    // 2026-08-10: each +/- pair gets its own concept order (see
    // neutralConceptSortKey) so both columns read in the same thematic
    // order as each other instead of the original list order.
    final positiveList = list.where((e) => e.isNeutralPositive).toList()
      ..sort((a, b) => neutralConceptSortKey(a.identity)
          .compareTo(neutralConceptSortKey(b.identity)));
    final negativeList = list.where((e) => e.isNeutralNegative).toList()
      ..sort((a, b) => neutralConceptSortKey(a.identity)
          .compareTo(neutralConceptSortKey(b.identity)));
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: getPadding(left: 38, right: 38, top: 44),
              child: GetBuilder(
                  builder: (K27Controller _c) => Visibility(
                    visible: controller.currentEventList.isNotEmpty,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          width: getHorizontalSize(109),
                          child: Text('neutral_positive'.tr(),
                              maxLines: null,
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight12Gray800a0)),
                      Container(
                          width: getHorizontalSize(108),
                          child: Text('neutral_negative'.tr(),
                              maxLines: null,
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight12Gray800a0))
                    ])),
              )),
          Padding(
            padding: getPadding(top: 18),
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 32,
                child: GetBuilder(
                  builder: (K27Controller _c) => Row(
                    children: [
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 32) / 2,

                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          runAlignment: WrapAlignment.center,
                          children: List.generate(positiveList.length, (index)=> Padding(
                            padding:  EdgeInsets.only(bottom: index == positiveList.length - 1 ? 40 : 20),
                            child: EventCard(
                              cardWidth: (MediaQuery.of(context).size.width - 32) / 2 - 30,
                              iconSizeOverride: 108,
                              fontSizeOverride: 18,
                              emotionMood: EmotionMood.positive,
                              isSelect: controller.contain(positiveList[index]),
                              model: positiveList[index], onTap: () {
                              controller.emotion = positiveList[index];
                              controller.update();
                            },),
                          ))
                              .toList(),
                        ),
                      ),
                      SizedBox(
                        width: (MediaQuery.of(context).size.width - 32) / 2,

                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          runAlignment: WrapAlignment.center,
                          children: List.generate(negativeList.length, (index)=> Padding(
                            padding:  EdgeInsets.only(bottom: index == negativeList.length - 1 ? 40 : 20),
                            child: EventCard(
                              cardWidth: (MediaQuery.of(context).size.width - 32) / 2 - 30,
                              iconSizeOverride: 108,
                              fontSizeOverride: 18,
                              emotionMood: EmotionMood.negative,
                              isSelect: controller.contain(negativeList[index]),
                              model: negativeList[index], onTap: () {
                              controller.emotion = negativeList[index];
                              controller.update();
                            },),
                          ))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          GetBuilder(
            builder: (K27Controller _c) => Visibility(
              visible: list.isEmpty,
              child: Center(
                child: Container(
                  width: getHorizontalSize(
                    144,
                  ),
                  margin: getMargin(
                    top: 37,
                  ),
                  child: Text(
                    'emotion_not_found_add_your_own'.tr(),
                    maxLines: null,
                    textAlign: TextAlign.center,
                    style: AppStyle.txtSFProDisplayLight14Gray800a01,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: getVerticalSize(40),
          )
        ],
      ),
    );
  }
}
