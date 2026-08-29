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

// Rewritten from scratch (was a Stack/Align/nested-Padding layout that
// developed an unexplained large gap above "Эмоция сейчас" that survived
// a clean uninstall+reinstall and didn't match any padding value actually
// in the code) — this version is a plain Column: a scrollable content
// area on top, a fixed button row pinned to the bottom underneath it, no
// Stack/Positioned/Align involved in placing either.
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
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
                      child: Text(
                        'which_emotion_felt'.tr(),
                        overflow: TextOverflow.ellipsis,
                        style: AppStyle.txtH1,
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
                              cardWidth: size.width / 2 - 22,
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
            ),
            Padding(
              padding: getPadding(left: 16, top: 14, bottom: 10, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomButton(
                    height: getVerticalSize(32),
                    width: getHorizontalSize(177),
                    variant: ButtonVariant.Base,
                    textIsFitted: true,
                    onTap: () => Navigator.pop(context),
                    text: 'choosing_emotion'.tr().toUpperCase(),
                    padding: ButtonPadding.PaddingT8,
                    prefixWidget: CustomImageView(
                      margin: getMargin(right: 4),
                      svgPath: ImageConstant.leftArrow,
                    ),
                  ),
                  CustomButton(
                    height: getVerticalSize(32),
                    width: getHorizontalSize(140),
                    variant: ButtonVariant.Base,
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
                ],
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
