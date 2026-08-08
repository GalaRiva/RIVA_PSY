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
    // 2026-08-07: "сгруппировать негативные эмоции по цвету: коричневые
    // вместе, красные вместе, зеленые вместе и т.д." — only the negative
    // tab (number 1) has the user-specified family groupings at all
    // (_familyOverrides is built entirely from standardEventListOne);
    // sorting the positive tab by the same key would be a no-op grouping
    // nothing, so it's left in its original order.
    final displayList = number == 1
        ? (List<EventModel>.from(list)
          ..sort((a, b) => emotionFamilySortKey(a.identity)
              .compareTo(emotionFamilySortKey(b.identity))))
        : list;
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
                          iconSizeOverride: 108,
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
