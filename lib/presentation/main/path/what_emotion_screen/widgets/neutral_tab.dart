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
                          children: List.generate(list.where((element) => element.isNeutralPositive).length, (index)=> Padding(
                            padding:  EdgeInsets.only(bottom: index == list.where((element) => element.isNeutralPositive).length - 1 ? 40 : 20),
                            child: EventCard(
                              cardWidth: (MediaQuery.of(context).size.width - 32) / 2 - 30,
                              iconSizeOverride: 108,
                              fontSizeOverride: 18,
                              emotionMood: EmotionMood.positive,
                              isSelect: controller.contain(list.where((element) => element.isNeutralPositive).toList()[index]),
                              model: list.where((element) => element.isNeutralPositive).toList()[index], onTap: () {
                              controller.emotion = list.where((element) => element.isNeutralPositive).toList()[index];
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
                          children: List.generate(list.where((element) => element.isNeutralNegative).length, (index)=> Padding(
                            padding:  EdgeInsets.only(bottom: index == list.where((element) => element.isNeutralNegative).length - 1 ? 40 : 20),
                            child: EventCard(
                              cardWidth: (MediaQuery.of(context).size.width - 32) / 2 - 30,
                              iconSizeOverride: 108,
                              fontSizeOverride: 18,
                              emotionMood: EmotionMood.negative,
                              isSelect: controller.contain(list.where((element) => element.isNeutralNegative).toList()[index]),
                              model: list.where((element) => element.isNeutralNegative).toList()[index], onTap: () {
                              controller.emotion =list.where((element) => element.isNeutralNegative).toList()[index];
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
