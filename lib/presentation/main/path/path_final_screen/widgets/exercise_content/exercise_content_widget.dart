import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/utils/emotion_in_day_event_extension.dart';

import '../../../../../../core/models/day_event_model.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';
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
    Padding(
    padding: getPadding(
      top: 34,
      left: 10,
      right: 10,
    ),
    child: Text(
    'you_are_feeling'.tr(),
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.left,
    style: AppStyle
        .txtSFProDisplayLight14Gray800a0.copyWith(fontWeight: FontWeight.bold),
    ),
    ),
        Padding(
          padding: getPadding(
            top: 34,
            left: 10,
            right: 10,
          ),
          child: Text(
            dayEvent.emotionInDayEvent!.getEmotionType().tr(),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle
                .txtSFProDisplayLight14Cyan700a0,
          ),
        ),
        Padding(
          padding: getPadding(top: 18,
            left: 10,
            right: 10,),
          child: EventCard(
            iconColor: dayEvent.whatEmotion!.length > 1 ? ColorConstant.fromHex('#5B4FA9') : ColorConstant.cyan700,
            emotionMood: moodForKey(dayEvent.whatEmotion![0].identity, categoryMood),
            model: dayEvent.whatEmotion![0],
            cardHeight: 44, isSelect: false,
            // Card itself stays 44 (unchanged layout footprint) — only the
            // blob grows, per explicit request that it read as too small.
            iconSizeOverride: 32,
            cardWidth: size.width - 20,
            useShadowStyle: true,
          ),
        ),
        Padding(
          padding: getPadding(
            top: 19,
            left: 10,
            right: 10,
          ),
          child: Text(
            'how_to_live_through'.tr(args: [dayEvent.whatEmotion![0].localizedName.toLowerCase()]),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle
                .txtSFProDisplayLight14Gray800a0.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(padding: getPadding(top: 12),
        child: FutureBuilder(
          future: controller.ensureAudiosLoaded(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: SizedBox(
                  width: 50,
                    height: 50,
                    child: CircularProgressIndicator(color: ColorConstant.cyan700,)),
              );
            }
            return Column(children: [
              if (controller.mainAudios.isNotEmpty)
                Padding(
                  padding: getPadding(top: 12,),
                  child: HeroAudioCarousel(
                    audios: controller.mainAudios,
                    controller: controller,
                    accentColor: accentColor,
                  ),
                ),
              Visibility(
                  visible: dayEvent.whatEmotion!.length > 1,
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: getPadding(top: 20, left: 10, right: 10),
                      childrenPadding: EdgeInsets.zero,
                      expandedAlignment: Alignment.centerLeft,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      iconColor: ColorConstant.cyan700,
                      collapsedIconColor: ColorConstant.cyan700,
                      title: Text(
                        'additional_emotions_short'.tr(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle
                            .txtSFProDisplayLight14Gray800a0.copyWith(fontWeight: FontWeight.bold),
                      ),
                children: [
                  Padding(
                      padding: getPadding(
                        top: 18,
                        left: 10,
                        right: 10,
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
                      left: 10,
                      right: 10,
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
                    child: AudioContainers(audios: controller.additionalAudios, controller: controller, startIndex: controller.mainAudios.length,),
                  ),
                ],
                    ),
                  ))

            ],);
          },
        ),
        )
      ],
    ),
    );
  }
}
