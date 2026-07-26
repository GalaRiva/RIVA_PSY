import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/utils/emotion_in_day_event_extension.dart';

import '../../../../../../core/models/day_event_model.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../theme/app_style.dart';
import '../../../../../../widgets/event_card.dart';
import '../audio_container/audio_containers.dart';
import 'controller.dart';

class ExerciseContentWidget extends StatelessWidget {
  final DayEventModel dayEvent;
  const ExerciseContentWidget({Key? key, required this.dayEvent, }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(ExerciseContentController());
    controller.dayEvent = dayEvent;
    controller.update();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
    Padding(
    padding: getPadding(
      top: 34,
      left: 10,
      right: 10,
    ),
    child: Text(
    'main_emotion'.tr(),
    overflow: TextOverflow.ellipsis,
    textAlign: TextAlign.left,
    style: AppStyle
        .txtSFProDisplayLight14Gray800a0,
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
            model: dayEvent.whatEmotion![0],
            cardHeight: 44, isSelect: false,
          ),
        ),
        Padding(
          padding: getPadding(
            top: 12,
          ),
          child: Padding(
            padding: getPadding(left: 10, right: 10),
            child: SizedBox(
              width: getHorizontalSize(135),
              child: Text(
                'clicking_to_see_related_emotions'.tr(),
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight10Gray800,
              ),
            ),
          ),
        ),
        Padding(
          padding: getPadding(
            top: 19,
            left: 10,
            right: 10,
          ),
          child: Text(
            'how_to_live_through'.tr(args: [dayEvent.whatEmotion![0].name.toLowerCase().tr()]),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle
                .txtSFProDisplayLight14Gray800a0,
          ),
        ),
        Padding(padding: getPadding(top: 12),
        child: FutureBuilder(
          future: controller.getAudios(),
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
              Padding(
                padding: getPadding(top: 12,),
                child: AudioContainers(audios: controller.mainAudios, controller: controller, startIndex: 0,),
              ),
              Visibility(
                  visible: dayEvent.whatEmotion!.length > 1,
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
                      'additional_emotions_short'.tr(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle
                          .txtSFProDisplayLight14Gray800a0,
                    ),
                  ),
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

                              model: controller.additionalEmotions![index],
                              cardHeight: 44, isSelect: false,
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
              ))

            ],);
          },
        ),
        )
      ],
    );
  }
}
