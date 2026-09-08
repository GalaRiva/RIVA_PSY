import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

import '../../../../../../core/models/day_event_model.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../theme/app_decoration.dart';
import '../../../../../../theme/app_style.dart';
import '../../../../../../widgets/event_card.dart';
import '../../../../../../widgets/emotion_color_blob.dart';
import '../audio_container/audio_containers.dart';
import '../audio_container/hero_audio_carousel.dart';
import 'controller.dart';

class ExerciseContentWidget extends StatelessWidget {
  final DayEventModel dayEvent;
  const ExerciseContentWidget({Key? key, required this.dayEvent, }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ExerciseContentController());
    controller.dayEvent = dayEvent;
    controller.update();
    // Premium redesign: color blobs instead of icons on this screen too.
    final categoryMood = dayEvent.emotionInDayEvent == EmotionInDayEvent.NEGATIVE
        ? EmotionMood.negative
        : EmotionMood.positive;
    // Hero Carousel concept, "Вариант А": tint the section with the same
    // accent color already used for the emotion chip above (emotionBlobColor)
    // instead of sampling the artwork's dominant color — no new dependency,
    // still ties the background to the specific emotion the user picked.
    final accentColor =
        emotionBlobColor(dayEvent.whatEmotion![0].identity, categoryMood);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [accentColor.withOpacity(0.22), accentColor.withOpacity(0.05)],
        ),
      ),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Вы испытываете:" + the raw category label ("Негативные") were
        // removed here — the emotion pill right below already names the
        // specific emotion directly, and a preceding "you are feeling" /
        // category-name pair was redundant with it, just extra text before
        // getting to the actual content.
        Padding(
          padding: getPadding(top: 34,
            left: 10,
            right: 10,),
          // Same size/shape as the "Выговориться" card above (glassCard,
          // left icon + text row) instead of the tall centered-column
          // layout EventCard uses elsewhere — explicit request to make the
          // two cards read as a matched pair.
          child: Container(
            padding: getPadding(all: 10),
            decoration: AppDecoration.glassCard,
            child: Row(
              children: [
                EmotionBlob(
                  color: emotionBlobColor(dayEvent.whatEmotion![0].identity, categoryMood),
                  size: 43,
                ),
                Padding(
                  padding: getPadding(left: 16),
                  child: Text(
                    dayEvent.whatEmotion![0].localizedName,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.left,
                    style: AppStyle.txtSFProDisplayLight14Cyan700,
                  ),
                ),
              ],
            ),
          ),
        ),
        // "Practices" section — was a bare header + carousel + dropdown
        // floating loose on the page background, one of several
        // same-weight blocks stacked with no visual grouping. One enclosing
        // glass panel (same family as the emotion-pill card above it) gives
        // it a defined boundary, so the page reads as "input card" then
        // "practices card" instead of six unrelated pieces in a row.
        Padding(
          padding: getPadding(top: 19, left: 10, right: 10),
          child: Container(
            width: double.infinity,
            padding: getPadding(all: 14),
            decoration: AppDecoration.glassCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'how_to_live_through'.tr(args: [dayEvent.whatEmotion![0].localizedName.toLowerCase()]),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                  style: AppStyle
                      .txtSFProDisplayLight14Gray800a0.copyWith(fontWeight: FontWeight.bold),
                ),
                FutureBuilder(
                  future: controller.ensureAudiosLoaded(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: getPadding(top: 20, bottom: 20),
                        child: Center(
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: CircularProgressIndicator(color: ColorConstant.cyan700,)),
                        ),
                      );
                    }
                    return Column(children: [
                      if (controller.mainAudios.isNotEmpty)
                        Padding(
                          padding: getPadding(top: 12, bottom: 8),
                          child: HeroAudioCarousel(
                            audios: controller.mainAudios,
                            accentColor: accentColor,
                          ),
                        ),
                      Visibility(
                          visible: dayEvent.whatEmotion!.length > 1,
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              tilePadding: getPadding(top: 8, left: 0, right: 0),
                              childrenPadding: EdgeInsets.zero,
                              expandedAlignment: Alignment.centerLeft,
                              expandedCrossAxisAlignment: CrossAxisAlignment.start,
                              iconColor: ColorConstant.cyan700,
                              collapsedIconColor: ColorConstant.cyan700,
                              title: Text(
                                'additional_emotions_short'.tr(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle
                                    .txtSFProDisplayLight14Gray800a0.copyWith(fontWeight: FontWeight.bold),
                              ),
                        children: [
                          Padding(
                              padding: getPadding(
                                top: 18,
                                left: 0,
                                right: 0,
                              ),
                              child: SizedBox(
                                height: getVerticalSize(90),
                                width: size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: PageScrollPhysics(),
                                    itemCount: controller.additionalEmotions?.length ?? 0, itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: getPadding(right: 12),
                                    child: EventCard(
                                      emotionMood: moodForKey(
                                          controller.additionalEmotions![index].identity,
                                          categoryMood),
                                      model: controller.additionalEmotions![index],
                                      cardHeight: 44, isSelect: false,
                                      cardWidth: size.width / 2.4,
                                      useShadowStyle: true,
                                    ),
                                  );

                                }
                                ),
                              )
                          ),
                          Padding(
                            padding: getPadding(
                              top: 18,
                              left: 0,
                              right: 0,
                            ),
                            child: Text(
                              'how_to_live_through_additional_emotions'.tr(),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle
                                  .txtSFProDisplayLight14Gray800a0,
                            ),
                          ),
                          Padding(
                            padding: getPadding(top: 12),
                            child: AudioContainers(audios: controller.additionalAudios, startIndex: controller.mainAudios.length,),
                          ),
                        ],
                            ),
                          ))

                    ],);
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    );
  }
}
