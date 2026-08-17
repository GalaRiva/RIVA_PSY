import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../core/models/day_event_model.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/event_card.dart';
import '../../../../../widgets/emotion_color_blob.dart';
import '../controller.dart';

class NegativePositiveTab extends StatelessWidget {
  final DayEventModel dayEventModel;
  final int number;
  final K27Controller controller;
  final List<EventModel> list;

  const NegativePositiveTab({Key? key, required this.controller, required this.number, required this.dayEventModel, required this.list}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    controller.currentTab = number;
    // 2026-08-07/2026-08-10: "сгруппировать эмоции по цвету" — negative
    // (tab 1) and positive (tab 2) each have their own 7-family grouping,
    // sorted by the order the user listed those families in.
    final displayList = List<EventModel>.from(list)
      ..sort((a, b) => (number == 1
              ? emotionFamilySortKey(a.identity)
                  .compareTo(emotionFamilySortKey(b.identity))
              : positiveEmotionFamilySortKey(a.identity)
                  .compareTo(positiveEmotionFamilySortKey(b.identity))));
    return SingleChildScrollView(
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
              padding: getPadding(
                top: 11,
                bottom: 50
              ),
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 32,
                  child:  Wrap(
                    spacing: 16,
                      runSpacing: 16,
                      runAlignment: WrapAlignment.center,
                      children: List.generate(displayList.length, (index)=> Padding(
                        padding:  EdgeInsets.only(bottom: index == displayList.length - 1 ? 40 : 20),
                        child: EventCard(
                          cardWidth: size.width / 2 - 30,
                          iconSizeOverride: 108, useShadowStyle: true, borderRadiusOverride: 16,
                          fontSizeOverride: 18,
                          // number 1 = the negative emotions tag, 2 = positive
                          // (see K27Repo.getTag) — same widget renders both.
                          emotionMood: number == 1
                              ? EmotionMood.negative
                              : EmotionMood.positive,
                              isSelect: controller.contain(displayList[index]),
                              model: displayList[index], onTap: () {
                              controller.emotion = displayList[index];
                              controller.update();
                            },),
                      ))
                          .toList(),
                    ),
                  ),
                ),
              ),
          Visibility(
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
                    style:
                    AppStyle.txtSFProDisplayLight14Gray800a01,
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
