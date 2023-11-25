import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_search_view.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../widgets/event_card.dart';
import 'controller.dart';

class K26Screen extends GetWidget {
  final DayEventModel? dayEvent;
  final Function(DayEventModel dayEvent)? onSave;

  K26Screen({  this.dayEvent, this.onSave});

  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel = dayEvent ?? (ModalRoute.of(context)?.settings.arguments ?? DayEventModel()) as DayEventModel;

    final controller = Get.put(K26Controller());
    if(controller.currentEventList != controller.eventListAfterInit)
      controller.initCurrentEventList().then((value) {
        controller.currentEventList = value;
        controller.eventListAfterInit = value;
        controller.update();
      });
    final _focus = FocusNode();
    final _focus2 = FocusNode();

    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.gray300,
        resizeToAvoidBottomInset: false,
        body: SizedBox(
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
                              "С кем произошло?",
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
                                onSubmit: (t) => _focus.unfocus(),
                                controller: controller.searchController,
                                hintText: "Найти персону",
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
                                hintText: "Добавить персону",
                                margin: getMargin(
                                  top: 25,
                                  right: 16,
                                ),
                                onSubmit: (t)async {
                                  _focus2.unfocus();
                                  var result = (await Navigator.pushNamed(
                                      context, AppRoutes.addEmotion,
                                      arguments: {
                                        'initialValue':
                                        controller.addEventController.text,
                                        'title': 'Добавить персону'
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
                                                'initialValue':
                                                controller.addEventController.text,
                                                'title': 'Добавить персону'
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
                                      builder: (K26Controller _c) => Wrap(
                                        spacing: 12,
                                        children: controller.currentEventList
                                            .map((el) => EventCard(model: el, onTap: () {
                                              controller.whoDidHappen = el;
                                              controller.update();
                                            }, isSelect: controller.contain(el),))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                )),
                            GetBuilder(
                              builder: (K26Controller _c) => Visibility(
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
                            SizedBox(
                              height: getVerticalSize(40),
                            )
                          ],
                        ),
                      ),
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
                alignment: Alignment.bottomCenter,

                child: Center(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: GetBuilder(
                      builder: (K26Controller _c) => Container(
                        width: double.maxFinite,

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomButton(
                              variant: ButtonVariant.Base,
                              height: getVerticalSize(
                                32,
                              ),
                              width: getHorizontalSize(
                                177,
                              ),
                              onTap: () => Navigator.pop(context),
                              text: "выбор места".toUpperCase(),
                              margin: getMargin(
                                bottom: 10,
                              ),
                              alignment: Alignment.topCenter,

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
                              variant: ButtonVariant.Base,

                              onTap: controller.currentEventList.isNotEmpty
                                  ? () {
                                if(controller.whoDidHappen == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберете персону или создайте новое')));
                                } else {
                                  if(onSave!=null)
                                    onSave!(dayEventModel
                                      ..whoDidItHappen =
                                          controller.whoDidHappen);
                                    else
                                        Navigator.pushNamed(
                                            context, AppRoutes.whatEmotion,
                                            arguments: dayEventModel
                                              ..whoDidItHappen =
                                                  controller.whoDidHappen);
                                      }
                                    }
                                  : () {
                                controller.searchController.text = '';
                                controller.changeCurrentEventList(
                                    controller.searchController.text);
                                controller.update();
                              },
                              text: "далее".toUpperCase(),
                              margin: getMargin(
                                bottom: 10,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          onChanged: (BottomBarEnum type) {},
        ),
      ),
    );
  }
}