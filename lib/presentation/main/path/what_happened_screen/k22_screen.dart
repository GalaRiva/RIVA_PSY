import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_search_view.dart';
import 'package:get/get.dart';
import '../../../../core/models/day_event_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../widgets/event_card.dart';
import 'controller.dart';

class K22Screen extends GetWidget {
  final DayEventModel? dayEvent;
  final Function(DayEventModel dayEvent)? onSave;
  K22Screen({this.onSave,  this.dayEvent});

  @override
  Widget build(BuildContext context) {
    final dayEventModel = dayEvent ?? (ModalRoute.of(context)?.settings.arguments ?? DayEventModel()) as DayEventModel;
    final controller = Get.put(K22Controller());
    if( controller.currentEventList != controller.eventListAfterInit)
    controller.initCurrentEventList().then((value) {
      controller.currentEventList = value;
      controller.eventListAfterInit = value;
      controller.update();
    });
    final _focus = FocusNode();
    final _focus2 = FocusNode();

    return Scaffold(
      backgroundColor: ColorConstant.gray300,
      body: SafeArea(
        child: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: getPadding(
                    left: 16,
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
                          top: 14,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Что произошло?",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtH1,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 32,
                              child: CustomSearchView(
                                focusNode: _focus,
                                onChange: (text) {
                                  controller.changeCurrentEventList(text);
                                  controller.update();
                                },
                                onSubmit: (text) => _focus.unfocus(),
                                controller: controller.searchController,
                                hintText: "Найти событие",
                                margin: getMargin(
                                  top: 28,
                                  right: 16,
                                ),
                                suffix: Container(
                                  margin: getMargin(
                                    left: 30,
                                    top: 1,
                                    right: 10,
                                    bottom: 9,
                                  ),
                                  child: CustomImageView(
                                    svgPath: ImageConstant.imgSearch,
                                  ),
                                ),
                                suffixConstraints: BoxConstraints(
                                  maxHeight: getVerticalSize(
                                    26,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 32,
                              child: CustomSearchView(
                                focusNode: _focus2,
                                controller: controller.addEventController,
                                hintText: "Добавить Событие",
                                margin: getMargin(
                                  top: 25,
                                  right: 16,
                                ),
                                onSubmit: (text) async{
                                  _focus2.unfocus();
                                  var result = (await Navigator.pushNamed(
                                      context, AppRoutes.addEmotion,
                                      arguments: {
                                        'title': 'Добавить Событие',
                                        'initialValue': controller.addEventController.text
                                      }))
                                  as EventModel;
                                  if (result != null) {
                                    controller.currentEventList =
                                    await controller
                                        .updateCurrentEventList(result);
                                    controller.changeCurrentEventList(
                                        controller.searchController.text);
                                    controller.update();
                                  }
                                },
                                suffix: Container(
                                    margin: getMargin(
                                      left: 30,
                                      top: 1,
                                      right: 10,
                                      bottom: 9,
                                    ),
                                    child: SizedBox(
                                      width: getHorizontalSize(20),
                                      height: getVerticalSize(20),
                                      child: IconButton(
                                        iconSize: 14,
                                        icon: Icon(
                                          Icons.add,
                                          size: getSize(20),
                                        ),
                                        onPressed: () async {
                                          var result = (await Navigator.pushNamed(
                                                  context, AppRoutes.addEmotion,
                                                  arguments: {
                                                    'title': 'Добавить Событие',
                                                    'initialValue': controller.addEventController.text
                                                  }))
                                              as EventModel;
                                          if (result != null) {
                                            controller.currentEventList =
                                                await controller
                                                    .updateCurrentEventList(result);
                                            controller.changeCurrentEventList(
                                                controller.searchController.text);
                                            controller.update();
                                          }
                                        },
                                      ),
                                    )),
                                suffixConstraints: BoxConstraints(
                                  maxHeight: getVerticalSize(
                                    26,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: getPadding(
                                  top: 42,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 32,
                                    child: GetBuilder(
                                      builder: (K22Controller _c) => Wrap(
                                        spacing: 12,

                                        children: controller.currentEventList
                                            .map((el) => EventCard(model: el, onTap: () {
                                              controller.whatHappened = el;
                                              controller.update();
                                            }, isSelect: controller.contain(el),))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                )),
                            GetBuilder(
                              builder: (K22Controller _c) => Visibility(
                                visible: controller.currentEventList.isEmpty,
                                child: Center(
                                  child: Container(
                                    width: getHorizontalSize(
                                      144,
                                    ),
                                    margin: getMargin(
                                      top: 37,
                                    ),
                                    child: Text(
                                      "Событие не найдено\nДобавьте свое событие",
                                      maxLines: null,
                                      textAlign: TextAlign.center,
                                      style:
                                          AppStyle.txtSFProDisplayLight14Gray800a01,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: getVerticalSize(40),)
                    ],
                  ),
                ),
              ),
              Container(
                width: size.width,
                height: getVerticalSize(60),
                margin: getMargin(
                  bottom: 0,
                ),
                color: ColorConstant.gray300,
                child: Center(
                  child: GetBuilder(
                    builder: (K22Controller _c) => CustomButton(
                      height: getVerticalSize(
                        32,
                      ),
                      width: getHorizontalSize(
                        178,
                      ),
                      variant: ButtonVariant.Base,
                      onTap: controller.currentEventList.isNotEmpty
                          ? () {
                        if(controller.whatHappened == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберете событие или создайте новое')));
                        } else {
                          if(onSave != null)
                            onSave!(dayEventModel.copyWith(whatHappened: controller.whatHappened));
                            else
                                Navigator.pushNamed(
                                    context, AppRoutes.whereHappened,
                                    arguments: dayEventModel.copyWith(whatHappened: controller.whatHappened));
                              }
                            }
                          : () {
                        controller.searchController.text = '';
                        controller.changeCurrentEventList(
                            controller.searchController.text);
                        controller.update();
                      },
                      text: controller.currentEventList.isNotEmpty
                          ? "далее".toUpperCase()
                          : "отмена".toUpperCase(),
                      margin: getMargin(
                        bottom: 10,
                      ),
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}
