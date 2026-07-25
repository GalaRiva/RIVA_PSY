import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/presentation/records/record_edit_screen/widgets/voice_button.dart';
import '../calendar_add_screen/controller.dart';
import '../calendar_search_screen/controller.dart';
import '../../charts/charts_screen/controller.dart';
import 'controller.dart';
import 'widgets/event_change_widget.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../core/models/body_parts_model.dart';
import '../../../core/models/day_event_model.dart';
import '../../../core/models/event_model.dart';
import '../../../widgets/circular_slider_widget.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_pop_button.dart';
import '../../../widgets/second_variant_event_card.dart';

import 'widgets/event_change_text_field_widget.dart';

class K52Screen extends GetWidget {

  @override
  Widget build(BuildContext context) {
    final _changeToParts = 'change_to'.tr().split('{}');
    final _changeToBefore = _changeToParts[0];
    final _changeToAfter = _changeToParts.length > 1 ? _changeToParts[1].trimLeft() : '';
    final _color = ColorConstant.fromHex('#5B4FA9');
    final _style = TextStyle(
      color: ColorConstant.deepPurple600,
      fontSize: getFontSize(
        9,
      ),
      fontFamily: 'SF Pro Display',
      fontWeight: FontWeight.w400,
    );
    DayEventModel dayEventModel = (ModalRoute.of(context)?.settings.arguments ??
        DayEventModel.defaultModel) as DayEventModel;
    final lastValue = dayEventModel.howDoYouFeel ?? 5;
    final controller = Get.put(K52Controller(dayEventModel));
    controller.selectedBodyParts = dayEventModel.whatBodyParts ?? [];
    controller.initDate(dayEventModel.date!);
    return Scaffold(
      backgroundColor: ColorConstant.gray300,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding: getPadding(
                left: 10,
                right: 10,
              ),
              child: GetBuilder(
                builder: (K52Controller _c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                          height: getVerticalSize(12),
                          width: getHorizontalSize(328),
                          margin: getMargin(top: 39),
                          child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      children: [
                                        CustomPopButton(text: 'records_title'.tr()),
                                        Text(
                                          ' | ${'record_editing'.tr()} ',
                                          style: AppStyle
                                              .txtSFProDisplayLight10Gray800,
                                        ),
                                      ],
                                    )),
                                Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                        padding: getPadding(bottom: 2, top: 22),
                                        child: SizedBox(
                                            width: getHorizontalSize(
                                                MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    32),
                                            child: Divider(
                                                height: getVerticalSize(1),
                                                thickness: getVerticalSize(1),
                                                color: ColorConstant.gray50))))
                              ])),
                      Padding(
                        padding: getPadding(
                          left: 6,
                          top: 14,
                        ),
                        child: Text(
                          dayEventModel.date!.day.toString() +
                              ' ' +
                              dayEventModel.date!.month.monthInText() +
                              ' ' +
                              dayEventModel.date!.year.toString(),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtH1,
                        ),
                      ),
                      Container(
                        margin: getMargin(
                          top: 28,
                        ),
                        padding: getPadding(
                          left: 6,
                          top: 7,
                          right: 6,
                          bottom: 7,
                        ),
                        decoration: AppDecoration.accent.copyWith(
                          borderRadius: BorderRadiusStyle.customBorderTL3,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              'record_editing'.tr(),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtSFProDisplayLight11.copyWith(
                                letterSpacing: getHorizontalSize(
                                  0.44,
                                ),
                              ),
                            ),
                            Padding(
                              padding: getPadding(
                                left: 82,
                                right: 3,
                              ),
                              child: Text(
                                dayEventModel.date!.weekday.dayInText() +
                                    ' ' +
                                    dayEventModel.date!.day.toString() +
                                    ' ' +
                                    dayEventModel.date!.month.monthInText() +
                                    ' ' +
                                    dayEventModel.date!.year.toString(),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight11.copyWith(
                                  letterSpacing: getHorizontalSize(
                                    0.44,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          left: 6,
                          top: 23,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: getPadding(
                                top: 2,
                                bottom: 11,
                              ),
                              child: Text(
                                _changeToBefore,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight11Gray800
                                    .copyWith(
                                  letterSpacing: getHorizontalSize(
                                    0.44,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: getSize(
                                28,
                              ),
                              width: getSize(
                                28,
                              ),
                              margin: getMargin(
                                left: 9,
                              ),
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  IgnorePointer(
                                    child: SleekCircularSlider(
                                      appearance: CircularSliderAppearance(
                                          animationEnabled: false,
                                          infoProperties: InfoProperties(
                                              topLabelText: '',
                                              mainLabelStyle: TextStyle(
                                                  color: Colors.transparent)),
                                          startAngle: 105,
                                          angleRange: 330,
                                          size: getSize(28),
                                          customColors: CustomSliderColors(
                                            trackColor: Colors.transparent,
                                            dotColor: Colors.transparent,
                                            progressBarColors: [
                                              ColorConstant.fromHex('#3B3B4A')
                                                  .withOpacity(0.55),
                                              ColorConstant.fromHex('#3B3B4A')
                                                  .withOpacity(0.55),
                                            ],
                                          ),
                                          customWidths: CustomSliderWidths(
                                              progressBarWidth: 3,
                                              trackWidth: 3)),
                                      min: 0,
                                      max: 10,
                                      initialValue: lastValue.toDouble(),
                                    ),
                                  ),
                                  Center(
                                    child: Text(
                                      dayEventModel.howDoYouFeel.toString(),
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle
                                          .txtSFProDisplayLight14Gray8008c
                                          .copyWith(
                                        letterSpacing: getHorizontalSize(
                                          0.56,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: getPadding(
                                left: 12,
                                top: 3,
                                bottom: 10,
                              ),
                              child: Text(
                                _changeToAfter,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight11Gray800
                                    .copyWith(
                                  letterSpacing: getHorizontalSize(
                                    0.44,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Center(
                          child: CircularSliderWidget(
                        onChange: (value) =>
                            dayEventModel.howDoYouFeel = value.toInt(),
                        value: (dayEventModel.howDoYouFeel ?? 5).toDouble() ,
                      )),
                      EventChangeWidget(
                        findHint: 'find_event'.tr(),
                        addHint: 'add_event'.tr(),
                        title: 'what_happened'.tr(),
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion, arguments: {
                            'title': 'add_event'.tr(),
                            'initialValue': controller.eventAddController.text
                          })) as EventModel;
                          if (result != null) {
                            await controller.eventAdd(result);
                            controller.update();
                          }
                        },
                        onSearch: (text, context) async {
                          await controller.eventSearch(text);
                          controller.update();
                          controller.openEventBottomSheet(
                              onChangeSearchText: (text) async {
                                await controller.eventSearch(text);
                                controller.update();
                              },
                              context: context,
                              initialText: text,
                              hintText: 'find_event'.tr(),
                              events: controller.eventList,
                              onChangeEventModel: (model) {
                                dayEventModel.whatHappened = model;
                                Navigator.pop(context);
                                controller.update();
                              });
                        },
                        searchController: controller.eventSearchController,
                        addController: controller.eventAddController,
                        contents: [
                          [
                            CustomImageView(
                              alignment: Alignment.center,
                              svgPath: dayEventModel.whatHappened!.svgPath,
                              color: _color,
                              fit: BoxFit.scaleDown,
                              height: getVerticalSize(
                                18,
                              ),
                              width: getHorizontalSize(18),
                              radius: BorderRadius.circular(
                                getHorizontalSize(
                                  3,
                                ),
                              ),
                            ),
                            Text(
                              dayEventModel.whatHappened!.name,
                              style: _style,
                            )
                          ]
                        ],
                      ),
                      EventChangeWidget(
                        findHint: 'find_place'.tr(),
                        addHint: 'add_place'.tr(),
                        title: 'where_it_happened'.tr(),
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion, arguments: {
                            'title': 'add_place'.tr(),
                            'initialValue': controller.placeAddController.text
                          })) as EventModel;
                          if (result != null) {
                            await controller.placeAdd(result);
                            controller.update();
                          }
                        },
                        onSearch: (text, context) async {
                          await controller.placeSearch(text);
                          controller.update();
                          controller.openEventBottomSheet(
                              onChangeSearchText: (text) async {
                                await controller.placeSearch(text);
                                controller.update();
                              },
                              context: context,
                              initialText: text,
                              hintText: 'find_place'.tr(),
                              events: controller.eventList,
                              onChangeEventModel: (model) {
                                dayEventModel.whereHappened = model;
                                Navigator.pop(context);
                                controller.update();
                              });
                        },
                        searchController: controller.placeSearchController,
                        addController: controller.placeAddController,
                        contents: [
                          [
                            Text(
                              dayEventModel.whereHappened!.name,
                              style: _style,
                            )
                          ]
                        ],
                      ),
                      EventChangeWidget(
                        findHint: 'find_person'.tr(),
                        addHint: 'add_person'.tr(),
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion,
                              arguments: {
                                'title': 'add_person'.tr(),
                                'initialValue':
                                    controller.personaAddController.text
                              })) as EventModel;
                          if (result != null) {
                            await controller.personaAdd(result);
                            controller.update();
                          }
                        },
                        title: 'with_whom_it_happened'.tr(),
                        onSearch: (text, context) async {
                          await controller.personaSearch(text);
                          controller.update();
                          controller.openEventBottomSheet(
                              onChangeSearchText: (text) async {
                                await controller.personaSearch(text);
                                controller.update();
                              },
                              context: context,
                              initialText: text,
                              hintText: 'find_person'.tr(),
                              events: controller.eventList,
                              onChangeEventModel: (model) {
                                dayEventModel.whoDidItHappen = model;
                                Navigator.pop(context);
                                controller.update();
                              });
                        },
                        searchController: controller.personaSearchController,
                        addController: controller.personaAddController,
                        contents: [
                          [
                            Text(
                              dayEventModel.whoDidItHappen!.name,
                              style: _style,
                            )
                          ]
                        ],
                      ),
                      EventChangeWidget(
                        findHint: 'find_emotion'.tr(),
                        addHint: 'add_emotion'.tr(),
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion, arguments: {
                            'title': 'add_emotion'.tr(),
                            'initialValue': controller.emotionAddController.text
                          })) as EventModel;
                          if (result != null) {
                            await controller.emotionAdd(result);
                            controller.update();
                          }
                        },
                        title: 'which_emotion_felt'.tr(),
                        onSearch: (text, context) async {
                          await controller.emotionSearch(text);
                          controller.update();
                          controller.openEventBottomSheet(
                              onChangeSearchText: (text) async {
                                await controller.emotionSearch(text);
                                controller.update();
                              },
                              context: context,
                              initialText: text,
                              hintText: 'find_emotion'.tr(),
                              events: controller.eventList,
                              onChangeEventModel: (model) {
                                dayEventModel.whatEmotion = [model];
                                Navigator.pop(context);
                                controller.update();
                              });
                        },
                        searchController: controller.emotionSearchController,
                        addController: controller.eventAddController,
                        contents: [
                          dayEventModel.whatEmotion!
                              .map((e) => Text(
                                    e.name,
                                    style: _style,
                                  ))
                              .toList()
                        ],
                      ),
                      Padding(
                        padding: getPadding(
                          left: 6,
                          top: 23,
                        ),
                        child: SizedBox(
                          height: getVerticalSize(17),
                          width: getHorizontalSize(size.width - 100),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: getPadding(
                                  top: 2,
                                ),
                                child: Text(
                                  _changeToBefore,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtSFProDisplayLight11Gray800
                                      .copyWith(
                                    letterSpacing: getHorizontalSize(
                                      0.44,
                                    ),
                                  ),
                                ),
                              ),
                              SecondVariantEventCard(
                                content: [
                                  IgnorePointer(
                                    child: SleekCircularSlider(
                                      appearance: CircularSliderAppearance(
                                          animationEnabled: false,
                                          infoProperties: InfoProperties(
                                              topLabelText: '',
                                              mainLabelStyle: TextStyle(
                                                  fontSize: 1,
                                                  color: Colors.transparent)),
                                          startAngle: 105,
                                          angleRange: 330,
                                          size: 11,
                                          customColors: CustomSliderColors(
                                            trackColor: Colors.transparent,
                                            dotColor: Colors.transparent,
                                            progressBarColors: [
                                              ColorConstant.fromHex('#403875'),
                                              ColorConstant.fromHex('#7FBDBA'),
                                            ],
                                          ),
                                          customWidths: CustomSliderWidths(
                                              progressBarWidth: 2,
                                              trackWidth: 2)),
                                      min: 0,
                                      max: 10,
                                      initialValue: dayEventModel
                                          .emotionIntensity
                                          .toDouble(),
                                    ),
                                  ),
                                  Text(
                                    '(' +
                                        dayEventModel.emotionIntensity
                                            .toString() +
                                        ')',
                                    style: _style,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: getPadding(
                                  left: 12,
                                  top: 3,
                                ),
                                child: Text(
                                  _changeToAfter,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtSFProDisplayLight11Gray800
                                      .copyWith(
                                    letterSpacing: getHorizontalSize(
                                      0.44,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Center(
                          child: CircularSliderWidget(
                        value: dayEventModel.emotionIntensity!.toDouble(),
                        onChange: (value) =>
                            dayEventModel.emotionIntensity = value.toInt(),
                      )),
                      EventChangeWidget(
                        findHint: 'find_body_part'.tr(),
                        addHint: 'add_body_part'.tr(),
                        onAdd: (text) async {
                          if (controller
                              .bodyPartsAddController.text.isNotEmpty) {
                            await controller.bodyPartAdd(BodyPartsModel(
                                bodyPart:
                                    controller.bodyPartsAddController.text,
                                whatHurts: []));
                            controller.update();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('enter_body_part_name'.tr())));
                          }
                        },
                        title: 'what_was_happening_with_body'.tr(),
                        onSearch: (text, context) async {
                          await controller.bodyPartsSearch(text);
                          controller.update();
                          controller.openEventBottomSheet(
                            onChangeSearchText: (text) async {
                              await controller.bodyPartsSearch(text);
                              controller.update();
                            },
                            context: context,
                            initialText: text,
                            hintText: 'find_body_part'.tr(),
                            bodyParts: controller.bodyParts,
                          );
                        },
                        searchController: controller.bodyPartsSearchController,
                        addController: controller.bodyPartsAddController,
                        contents: controller.selectedBodyParts
                            .map((e) => [
                                  Text(
                                    e.bodyPartsModel.bodyPart,
                                    style: _style,
                                  )
                                ])
                            .toList(),
                      ),
                      EventChangeTextFieldWidget(
                        title: 'what_did_I_do'.tr(),
                        hintText: dayEventModel.whatIDo ?? '',
                        textEditingController: controller.whatIDoController,
                        onChange: (text) {
                          dayEventModel.whatIDo = text;
                        },
                      ),
                      EventChangeTextFieldWidget(
                        title: 'first_thoughts_in_situation'.tr(),
                        hintText: dayEventModel.firstThoughts?? '',
                        textEditingController:
                            controller.firstThoughtsController,
                        onChange: (text) {
                          dayEventModel.firstThoughts = text;
                        },
                      ),
                      Padding(
                        padding: getPadding(top: 27),
                        child: Stack(
                          children: [
                            Visibility(
                              visible: dayEventModel.pathToAudio != null && controller.currentState ==
                                  ButtonState.BeforeRecording,
                              child: SizedBox(
                                height: getVerticalSize(17),
                                width: size.width - 100,
                                child: Row(
                                  children: [
                                    SecondVariantEventCard(
                                      content: [
                                        Container(
                                          margin: getMargin(
                                            right: 4,
                                          ),
                                          child: CustomImageView(
                                            svgPath:
                                                ImageConstant.imgMicrophone,
                                          ),
                                        ),
                                        Text(
                                          'voice_record'.tr(),
                                          style: _style,
                                        )
                                      ],
                                    ),
                                    Padding(
                                      padding: getPadding(
                                        left: 31,
                                      ),
                                      child: InkWell(
                                        onTap: () => controller
                                            .voiceButtonOnTap(context),
                                        child: Text(
                                          'replace'.tr(),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: AppStyle
                                              .txtSFProDisplayLight11Cyan700
                                              .copyWith(
                                            letterSpacing: getHorizontalSize(
                                              0.44,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: getPadding(
                                        left: 35,
                                      ),
                                      child: InkWell(
                                        onTap: () => dayEventModel.pathToAudio = null,
                                        child: Text(
                                          'delete'.tr(),
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: AppStyle
                                              .txtSFProDisplayLight11Deeppurple600
                                              .copyWith(
                                            letterSpacing: getHorizontalSize(
                                              0.44,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Visibility(
                              visible: controller.currentState ==
                                  ButtonState.Recording || controller.currentState ==
                                  ButtonState.AfterRecording,
                              child: VoiceButton(
                                controller: controller,
                                currentState: controller.currentState,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomButton(
                        height: getVerticalSize(
                          32,
                        ),
                        width: getHorizontalSize(
                          174,
                        ),
                        onTap: () async {
                          if(controller.selectedBodyParts.isNotEmpty)
                          dayEventModel.whatBodyParts =
                              controller.selectedBodyParts;
                          await controller.dayEventUpdate(dayEventModel);

                          showDialog(
                            context: context,
                            builder: (BuildContext context) => WillPopScope(
                              onWillPop: () async {
                                Navigator.pushNamedAndRemoveUntil(context,
                                    AppRoutes.records, (route) => false);
                                return true;
                              },
                              child: CustomMessageBox(
                                onPop: () {
                                  Navigator.pushNamedAndRemoveUntil(context,
                                      AppRoutes.records, (route) => false);
                                },
                                title: 'record_edited'.tr(),
                                content: 'save_record'.tr(args: [
                                  '${dayEventModel.date!.day} ${dayEventModel.date!.month.monthInText()} ${dayEventModel.date!.year} г ${dayEventModel.date!.hour.timeFormatted()}:${dayEventModel.date!.minute.timeFormatted()}'
                                ]),
                              ),
                            ),
                          );
                          Get.delete<K51Controller>();
                          Get.delete<K50Controller>();
                          Get.delete<K61Controller>();
                        },
                        text: 'save'.tr().toUpperCase(),
                        margin: getMargin(
                          top: 27,
                        ),
                        alignment: Alignment.center,
                      ),
                      SizedBox(
                        height: getVerticalSize(27),
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}
