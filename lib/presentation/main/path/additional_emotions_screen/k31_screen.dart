import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../widgets/event_card.dart';
import 'controller.dart';

class K31Screen extends GetWidget {
  final DayEventModel? dayEvent;
  final String? category;
  final List<EventModel>? someEmotions;
  final Function(DayEventModel dayEvent)? onSave;

  K31Screen( {this.category, this.someEmotions, this.dayEvent,  this.onSave});
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K31Controller());
      final data =
      (ModalRoute.of(context)?.settings.arguments ?? {
      'emotionCategory' : category ?? 'Нейтральные',
      'dayEventModel' : dayEvent ?? [],
      'someEmotions' : someEmotions ?? []
      }) as Map<String, dynamic>;
    final dayEventModel = (data['dayEventModel'] as DayEventModel);
    controller.emotions = dayEventModel.whatEmotion!;
    controller.title = (data['emotionCategory'] as String);
    if(controller.title == 'Позитивные'){
      dayEventModel.emotionInDayEvent = EmotionInDayEvent.POSITIVE;
    }
    if(controller.title == 'Нейтральные'){
      dayEventModel.emotionInDayEvent = EmotionInDayEvent.NEUTRAL;
    }
    controller.additionalEmotions = (data['someEmotions'] as List<EventModel>);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.gray300,
        body: SizedBox(
          width: size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding: getPadding(
                left: 15,
                right: 4,
                bottom: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: getPadding(
                      top: 39,
                    ),
                    child: Text(
                      "Эмоция сейчас",
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtSFProDisplayLight10Gray800,
                    ),
                  ),
                  Padding(
                    padding: getPadding(
                      top: 12,
                    ),
                    child: Divider(
                      height: getVerticalSize(
                        1,
                      ),
                      thickness: getVerticalSize(
                        1,
                      ),
                      color: ColorConstant.gray50,
                    ),
                  ),
                  Padding(
                    padding: getPadding(
                      left: 1,
                      top: 15,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Какую эмоцию испытал?",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtH1,
                        ),
                        Padding(
                          padding: getPadding(
                            top: 144,
                          ),
                          child: Text(
                            controller.title,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight14Cyan700a0,
                          ),
                        ),
                        Padding(
                          padding: getPadding(
                            top: 18,
                          ),
                          child: GetBuilder(
                            builder: (K31Controller _c) => SizedBox(
                              height: getVerticalSize(90),
                              width: size.width,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                physics: PageScrollPhysics(),
                                itemCount: controller.emotions.length + 1, itemBuilder: (BuildContext context, int index) {
                                  if(index == controller.emotions.length) {
                                    return Padding(
                                      padding: getPadding(
                                        left: 12,
                                        top: 13,
                                        bottom: 13,
                                      ),
                                      child: Text(
                                        "Основная эмоция",
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: AppStyle
                                            .txtSFProDisplayLight14Gray800a0,
                                      ),
                                    );
                                  }

                                return Padding(
                                  padding: getPadding(right: 12),
                                  child: EventCard(
                                    iconColor: ColorConstant.fromHex('#5B4FA9'),
                                    onTap: () {
                                      if(index != 0 || index != controller.emotions.length) {
                                        controller.additionalEmotions.add(
                                            controller.emotions[index]);
                                        controller.emotions.removeAt(index);
                                        controller.update();
                                      }
                                    },
                                    model: controller.emotions[index],
                                    cardHeight: 44, isSelect: false,
                                  ),
                                );

                              }
                              ),
                            ),
                          )
                        ),
                        Padding(
                          padding: getPadding(
                            top: 10,
                          ),
                          child: Text(
                            "Хотите добавить дополнительные эмоции?",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight14Gray800a0,
                          ),
                        ),
                        Padding(
                            padding: getPadding(
                              top: 18,
                            ),
                            child: GetBuilder(
                                builder: (K31Controller _c) => SizedBox(
                                height: getVerticalSize(90),
                                width: size.width,
                                child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    physics: PageScrollPhysics(),
                                    itemCount: controller.additionalEmotions.length, itemBuilder: (BuildContext context, int index) {
                                  return Padding(
                                    padding: getPadding(right: 12),
                                    child: EventCard(

                                      model: controller.additionalEmotions[index],
                                      onTap: () {
                                        if (!controller.emotions.contains(controller.additionalEmotions[index])) {
                                              controller.emotions.add(controller
                                                  .additionalEmotions[index]);
                                              controller.additionalEmotions
                                                  .removeAt(index);
                                              controller.update();
                                            } else null;
                                          },
                                      cardHeight: 44, isSelect: false,
                                    ),
                                  );

                                }
                                ),
                              ),
                            )
                        ),
                        Padding(
                          padding: getPadding(
                            top: 100,
                          ),
                          child: Row(
                            children: [
                              CustomButton(
                                height: getVerticalSize(
                                  32,
                                ),
                                width: getHorizontalSize(
                                  177,
                                ),
                                onTap: () => Navigator.pop(context),
                                text: "выбор эмоции".toUpperCase(),
                                margin: getMargin(
                                  bottom: 73,
                                ),
                                padding: ButtonPadding.PaddingT8,
                                prefixWidget: CustomImageView(
                                  margin: getMargin(right: 12),
                                  svgPath: ImageConstant.leftArrow,
                                ),
                              ),
                              CustomButton(
                                height: getVerticalSize(
                                  32,
                                ),
                                width: getHorizontalSize(
                                  140,
                                ),
                                onTap: () {
                                  controller.showEmotionIntensityDialog(
                                      context, controller,
                                      controller.emotions.first.name,
                                      data['dayEventModel'], onSave: onSave);
                                },
                                text: "далее".toUpperCase(),
                                margin: getMargin(
                                  left: 13,
                                  bottom: 73,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          onChanged: (BottomBarEnum type) {},
        ),
      ),
    );
  }
}
