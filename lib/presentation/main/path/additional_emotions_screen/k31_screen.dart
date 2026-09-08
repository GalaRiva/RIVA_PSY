import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/utils/emotion_in_day_event_extension.dart';
import '../../../../widgets/event_card.dart';
import '../../../../widgets/emotion_color_blob.dart';
import 'controller.dart';
import '../../../../theme/app_colors.dart';

// Back to Stack/Align (floating button row over the scrollable content) to
// match every other Path screen — an earlier version used a plain Column
// specifically to dodge an unexplained gap above "Эмоция сейчас" that
// showed up here, but the floating layout is the one actually wanted; if
// that old gap reappears, it needs its own real fix, not a different layout.
class K31Screen extends GetWidget {
  final DayEventModel? dayEvent;
  final EmotionInDayEvent? category;
  final List<EventModel>? someEmotions;
  final Function(DayEventModel dayEvent)? onSave;

  K31Screen({this.category, this.someEmotions, this.dayEvent, this.onSave});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K31Controller());
    final data = (ModalRoute.of(context)?.settings.arguments ??
        {
          'emotionCategory': category ?? EmotionInDayEvent.NEUTRAL,
          'dayEventModel': dayEvent ?? [],
          'someEmotions': someEmotions ?? []
        }) as Map<String, dynamic>;
    final dayEventModel = (data['dayEventModel'] as DayEventModel);
    controller.emotions = dayEventModel.whatEmotion!;
    controller.title =
        (data['emotionCategory'] as EmotionInDayEvent).getEmotionType().tr();
    controller.additionalEmotions = (data['someEmotions'] as List<EventModel>);
    final categoryMood =
        (data['emotionCategory'] as EmotionInDayEvent) == EmotionInDayEvent.NEGATIVE
            ? EmotionMood.negative
            : EmotionMood.positive;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
              SingleChildScrollView(
                padding: getPadding(left: 15, right: 16, top: 16, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'current_emotion'.tr(),
                      overflow: TextOverflow.ellipsis,
                      style: AppStyle.txtSFProDisplayLight10Gray800,
                    ),
                    Padding(
                      padding: getPadding(top: 12),
                      child: Divider(
                        height: getVerticalSize(1),
                        thickness: getVerticalSize(1),
                        color: ColorConstant.gray50,
                      ),
                    ),
                    Padding(
                      padding: getPadding(top: 18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: getPadding(right: 4),
                              child: Icon(Icons.chevron_left_rounded,
                                  size: getSize(32), color: ColorConstant.gray800),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'which_emotion_felt'.tr(),
                              overflow: TextOverflow.ellipsis,
                              style: AppStyle.txtH1.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: getPadding(top: 18),
                      child: Text(
                        controller.title,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayLight14Cyan700a0,
                      ),
                    ),
                    Padding(
                      padding: getPadding(top: 18),
                      child: GetBuilder(
                        builder: (K31Controller _c) => SizedBox(
                          height: getVerticalSize(90),
                          width: size.width,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const PageScrollPhysics(),
                            itemCount: controller.emotions.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == controller.emotions.length) {
                                return Padding(
                                  padding: getPadding(left: 12, top: 13, bottom: 13),
                                  child: Text(
                                    'main_emotion'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyle.txtSFProDisplayLight14Gray800a0,
                                  ),
                                );
                              }
                              return Padding(
                                padding: getPadding(right: 12),
                                child: EventCard(
                                  iconColor: ColorConstant.fromHex('#5B4FA9'),
                                  emotionMood: moodForKey(
                                      controller.emotions[index].identity,
                                      categoryMood),
                                  cardWidth: size.width / 2 - 30,
                                  cardHeight: 44,
                                  useShadowStyle: true,
                                  borderRadiusOverride: 16,
                                  onTap: () {
                                    controller.additionalEmotions
                                        .add(controller.emotions[index]);
                                    controller.emotions.removeAt(index);
                                    controller.update();
                                  },
                                  model: controller.emotions[index],
                                  isSelect: false,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: getPadding(top: 32),
                      child: Text(
                        'add_additional_emotions'.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtSFProDisplayLight14Gray800a0,
                      ),
                    ),
                    Padding(
                      padding: getPadding(top: 18),
                      child: GetBuilder(
                        builder: (K31Controller _c) => Wrap(
                          spacing: getHorizontalSize(12),
                          runSpacing: getVerticalSize(12),
                          children: controller.additionalEmotions
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final emotion = entry.value;
                            return EventCard(
                              emotionMood:
                                  moodForKey(emotion.identity, categoryMood),
                              model: emotion,
                              onTap: () {
                                if (!controller.emotions.contains(emotion)) {
                                  controller.emotions.add(emotion);
                                  controller.additionalEmotions
                                      .removeAt(index);
                                  controller.update();
                                }
                              },
                              // Was `size.width / 2 - 22` — with this
                              // screen's real left+right padding (getPadding
                              // 15+16, itself scaled up on wider-than-Figma
                              // screens) the two cards' declared widths plus
                              // the 12 of runSpacing came within ~1px of the
                              // actually available width. Any rounding this
                              // close and Wrap has no choice but to drop the
                              // second card to its own line — every card
                              // rendered full-width, one per row, instead of
                              // two side by side. Deriving cardWidth from the
                              // real available width (with this row's own
                              // padding+spacing subtracted first) instead of
                              // a flat screen-width fraction leaves real
                              // margin instead of a razor's edge.
                              cardWidth: (MediaQuery.of(context).size.width - 31 - 12) / 2 - 8,
                              cardHeight: 44,
                              useShadowStyle: true,
                              borderRadiusOverride: 16,
                              isSelect: false,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
              padding: getPadding(left: 16, top: 14, bottom: 10, right: 16),
              child: CustomButton(
                    height: getVerticalSize(40),
                    width: MediaQuery.of(context).size.width - 32,
                    bgColor: ColorConstant.cyan700,
                    showBorder: false,
                    borderRadius: 14,
                    glossy: true,
                    showShadow: false,
                    textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                    onTap: () {
                      controller.showEmotionIntensityDialog(
                          context,
                          controller,
                          controller.emotions.first.localizedName,
                          data['dayEventModel'],
                          onSave: onSave);
                    },
                    text: 'continue'.tr().toUpperCase(),
                  ),
            ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}
