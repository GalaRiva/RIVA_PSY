import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import '../../charts/charts_screen/controller.dart';
import 'widgets/event_change_widget.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import '../../../core/models/body_parts_model.dart';
import '../../../core/models/day_event_model.dart';
import '../../../core/models/event_model.dart';
import '../../../widgets/circular_slider_widget.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_pop_button.dart';
import '../calendar_add_screen/controller.dart';
import '../calendar_search_screen/controller.dart';
import 'controller.dart';
import '../records_screen/controller.dart';
import 'widgets/event_change_text_field_widget.dart';
import 'widgets/voice_button.dart';

class K54Screen extends GetWidget {

  final _color = ColorConstant.fromHex('#5B4FA9');
  final _style = TextStyle(
    color: ColorConstant.deepPurple600,
    fontSize: getFontSize(
      9,
    ),
    fontFamily: 'SF Pro Display',
    fontWeight: FontWeight.w400,
  );
  DayEventModel dayEventModel = DayEventModel(emotionIntensity: 5, howDoYouFeel: 5);
  @override
  Widget build(BuildContext context) {
    final date = (ModalRoute.of(context)?.settings.arguments ??
        DateTime.now()) as DateTime;
    dayEventModel.date = date;
    var controller = Get.put(K54Controller(dayEventModel));
    controller.initDate(date);
    return Scaffold(

      backgroundColor: ColorConstant.gray300,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: getPadding(
              left: 10,
              right: 10,
            ),
            child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                        height: getVerticalSize(12),
                        width: getHorizontalSize(328),
                        margin: getMargin(top: 39),
                        child:
                            Stack(alignment: Alignment.bottomCenter, children: [
                          Align(
                              alignment: Alignment.centerLeft,
                              child: Row(
                                children: [
                                  CustomPopButton(text: 'Записи'),
                                  Text(
                                    ' | Создание записи ',
                                    style:
                                        AppStyle.txtSFProDisplayLight10Gray800,
                                  ),
                                ],
                              )),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                  padding: getPadding(bottom: 2, top: 22),
                                  child: SizedBox(
                                      width: getHorizontalSize(
                                          MediaQuery.of(context).size.width -
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
                            "Создание записи",
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
                      child: Text(
                        "Как ты себя чувствовал? ",
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
                    Center(
                        child: CircularSliderWidget(
                          onChange: (value) => dayEventModel.howDoYouFeel = value.toInt(),
                      value: dayEventModel.howDoYouFeel?.toDouble() ?? 5,
                    )),
                    GetBuilder(
                      builder: (K54Controller _c) => EventChangeWidget(
                        event: 'событие',
                        title: 'Что произошло',
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                          context, AppRoutes.addEmotion,
                          arguments: {
                          'title': 'Добавить Событие',
                          'initialValue': controller.eventAddController.text
                          }))
                          as EventModel;
                          if (result != null) {
                          await controller
                              .eventAdd(result);
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
                              hintText: 'Найти событие',
                              events: controller.eventList,
                              onChangeEventModel: (model)
                              {
                                dayEventModel.whatHappened = model;
                                Navigator.pop(context);
                                FocusNode().unfocus();
                                controller.update();
                              });
                        },
                        searchController: controller.eventSearchController,
                        addController: controller.eventAddController,
                        contents: dayEventModel.whatHappened == null ? null : [
                          [ CustomImageView(
                            alignment: Alignment.center,
                            svgPath: dayEventModel.whatHappened?.svgPath,
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
                            dayEventModel.whatHappened?.name ?? ' ',
                            style: _style,
                          )]
                        ], fFocus: controller.eventSNode, sFocus: controller.eventANode,
                      ),
                    ),
                    GetBuilder(
                      builder: (K54Controller _c) => EventChangeWidget(
                        event: 'место',
                        title: 'Где произошло',
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion,
                              arguments: {
                                'title': 'Добавить Место',
                                'initialValue': controller.placeAddController.text
                              }))
                          as EventModel;
                          if (result != null) {
                            await controller
                                .placeAdd(result);
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
                              hintText: 'Найти событие',
                              events: controller.eventList,
                              onChangeEventModel: (model)
                              {
                                dayEventModel.whereHappened = model;
                                Navigator.pop(context);
                                controller.update();
                              });
                        },
                        searchController: controller.placeSearchController,
                        addController: controller.placeAddController,
                        contents: dayEventModel.whereHappened == null ? null :[
                          [Text(
                            dayEventModel.whereHappened!.name,
                            style: _style,
                          )]
                        ],fFocus: controller.placeSNode, sFocus: controller.placeANode,
                      ),
                    ),
                    GetBuilder(
                      builder: (K54Controller _c) => EventChangeWidget(
                        event: 'персону',
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion,
                              arguments: {
                                'title': 'Добавить Персону',
                                'initialValue': controller.personaAddController.text
                              }))
                          as EventModel;
                          if (result != null) {
                            await controller
                                .personaAdd(result);
                            controller.update();
                          }
                        },
                        title: 'С кем произошло',
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

                              hintText: 'Найти Персону',
                              events: controller.eventList,
                              onChangeEventModel: (model)
                              {
                                dayEventModel.whoDidItHappen = model;
                                Navigator.pop(context);
                                controller.update();
                              });
                        },
                        searchController: controller.personaSearchController,
                        addController: controller.personaAddController,
                        contents: dayEventModel.whoDidItHappen == null ? null : [
                          [Text(
                            dayEventModel.whoDidItHappen!.name,
                            style: _style,
                          )]
                        ],fFocus: controller.personaSNode, sFocus: controller.personaANode,
                      ),
                    ),
                    GetBuilder(
                      builder: (K54Controller _c) => EventChangeWidget(
                        event: 'эмоцию',
                        onAdd: (text) async {
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion,
                              arguments: {
                                'title': 'Добавить Эмоцию',
                                'initialValue': controller.emotionAddController.text
                              }))
                          as EventModel;
                          if (result != null) {
                            await controller
                                .emotionAdd(result);
                            controller.update();
                          }
                        },
                        title: 'Какую эмоцию испытал?',
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

                              hintText: 'Найти Эмоцию',
                              events: controller.eventList,
                              onChangeEventModel: (model)
                              {
                                dayEventModel.whatEmotion = [model];
                                Navigator.pop(context);
                                controller.update();
                              });
                        },
                        searchController: controller.emotionSearchController,
                        addController: controller.emotionAddController,
                        contents: dayEventModel.whatEmotion == null ? null :[
                          dayEventModel.whatEmotion!.map((e) => Text(
                            e.name,
                            style: _style,
                          )).toList()
                        ],fFocus: controller.emotionSNode, sFocus: controller.emotionANode,
                      ),
                    ),
                    Padding(
                      padding: getPadding(
                        left: 6,
                        top: 23,
                      ),
                      child: SizedBox(
                        height: getVerticalSize(17),
                        width: getHorizontalSize(size.width - 100),
                        child: Text(
                          "Оцени интенсивность эмоции",
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
                    ),
                    Center(
                        child: CircularSliderWidget(
                          value: dayEventModel.emotionIntensity!.toDouble(),
                          onChange: (value) => dayEventModel.emotionIntensity = value.toInt(),

                        )),
                    GetBuilder(
                      builder: (K54Controller _c) => EventChangeWidget(
                        event: 'часть тела',
                        onAdd: (text) async {
                          if(controller.bodyPartsAddController.text.isNotEmpty) {
                            await controller.bodyPartAdd(BodyPartsModel(
                                bodyPart: controller.bodyPartsAddController.text,
                                whatHurts: []));
                            controller.update();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введи название части тела')));
                          }
                        },
                        title: 'Что происходило с телом?',
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
                              hintText: 'Найти часть тела',
                              bodyParts: controller.bodyParts,
                              );
                        },
                        searchController: controller.bodyPartsSearchController,
                        addController: controller.bodyPartsAddController,
                        contents:
                        controller.selectedBodyParts.isEmpty ? null : controller.selectedBodyParts.map((e) => [Text(
                            e.bodyPartsModel.bodyPart,
                            style: _style,
                          )]).toList()
                        ,fFocus: controller.bodyPartsSNode, sFocus: controller.bodyPartsANode,
                      ),
                    ),
                    EventChangeTextFieldWidget(title: 'Что я делал?', hintText: 'Например: Ушел, хлопнул дверью', textEditingController: controller.whatIDoController, onChange: (text){
                      dayEventModel.whatIDo = text;
                    },),
                    EventChangeTextFieldWidget(title: 'Первые мысли в ситуации', hintText: 'Например: Я тоже так хочу', textEditingController: controller.firstThoughtsController, onChange: (text){
                      dayEventModel.firstThoughts = text;
                    },),
                    GetBuilder(
                        builder: (K54Controller _c) =>  VoiceButton(controller: controller, currentState: controller.currentState,)),
                    CustomButton(
                      height: getVerticalSize(
                        32,
                      ),
                      width: getHorizontalSize(
                        174,
                      ),
                      onTap: () async {
                        dayEventModel.whatBodyParts = controller.selectedBodyParts;
                        if(dayEventModel.whatBodyParts == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите часть тела')));
                        }
                        else if(dayEventModel.whatEmotion == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите эмоцию')));
                        }
                        else if(dayEventModel.whoDidItHappen == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите персону')));
                        }
                        else if(dayEventModel.whereHappened == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите место')));
                        }
                        else if(dayEventModel.whatHappened == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите событие')));
                        }
                        else {
                          controller.clear();
                          await controller.dayEventUpdate(dayEventModel);
                          K49Controller().update();
                          showDialog(context: context, builder: (BuildContext context) => WillPopScope(
                            onWillPop: () async{
                              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.records, (route) => false);
                              return true;
                            },
                            child: CustomMessageBox(
                              onPop: () {
                                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.records, (route) => false);
                              },
                              title: 'Запись создана',
                              content:
                              'Запись ${dayEventModel.date!.day} ${dayEventModel.date!.month.monthInText()} ${dayEventModel.date!.year} г ${dayEventModel.date!.hour.timeFormatted()}:${dayEventModel.date!.minute.timeFormatted()} сохранена',
                            ),
                          ), );
                          Get.delete<K51Controller>();
                          Get.delete<K50Controller>();
                          Get.delete<K61Controller>();
                        }
                      },
                      text: "Сохранить".toUpperCase(),
                      margin: getMargin(
                        top: 27,
                      ),
                      alignment: Alignment.center,
                    ),
                    SizedBox(height: getVerticalSize(27),)
                  ]),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}
