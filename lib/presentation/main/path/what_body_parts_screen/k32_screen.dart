import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'widgets/selected_body_parts_widget.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_search_view.dart';
import '../../../../../core/utils/size_utils.dart';

import '../../../../core/models/body_parts_model.dart';
import '../../../../core/models/day_event_model.dart';
import '../../../../widgets/body_widget.dart';
import 'controller.dart';
import 'widgets/body_parts_widget.dart';

class K32Screen extends GetWidget {

  final DayEventModel? dayEvent;
  final Function(DayEventModel dayEvent)? onSave;

  K32Screen({  this.dayEvent,  this.onSave});

  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel =
        (ModalRoute.of(context)?.settings.arguments ?? this.dayEvent ?? DayEventModel())
            as DayEventModel;

    final controller = Get.put(K32Controller());
    final _focus = FocusNode();
    final _focus2 = FocusNode();

    return Scaffold(
      backgroundColor: ColorConstant.gray300,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          child: Stack(            alignment: Alignment.bottomCenter,

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
                              "Что происходило с телом?",
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
                                hintText: "Найти часть тела",
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
                                onSubmit: (t) async{
                                  _focus2.unfocus();
                                  if (controller
                                      .addEventController.text.isNotEmpty) {
                                    await controller.updateCurrentEventList(
                                        BodyPartsModel(
                                            bodyPart: controller
                                                .addEventController.text,
                                            whatHurts: []));
                                    controller.changeCurrentEventList(
                                        controller.searchController.text);
                                    controller.update();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите название части тела')));
                                  }
                                },
                                controller: controller.addEventController,
                                hintText: "Добавить часть тела",
                                margin: getMargin(
                                  top: 25,
                                  right: 16,
                                ),
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
                                          if (controller
                                              .addEventController.text.isNotEmpty) {
                                            await controller.updateCurrentEventList(
                                                BodyPartsModel(
                                                    bodyPart: controller
                                                        .addEventController.text,
                                                    whatHurts: []));
                                            controller.changeCurrentEventList(
                                                controller.searchController.text);
                                            controller.update();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Введите название части тела')));
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
                              padding: getPadding(top: 34),
                              child: GetBuilder(
                                builder: (K32Controller _c) => Visibility(
                                    visible:
                                        controller.selectedEventList.isNotEmpty,
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: getVerticalSize(50),
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            shrinkWrap: false,
                                              itemCount: controller
                                                  .selectedEventList.length,
                                              itemBuilder: (context, index) =>
                                                  SelectedBodyPartsWidget(
                                                    model: controller
                                                        .selectedEventList[index],
                                                    list: controller
                                                        .selectedEventList,
                                                    controller: controller,
                                                  )),
                                        ),
                                        SizedBox(
                                          height: getVerticalSize(29),
                                        ),
                                        Text(
                                          'Хотите добавить части тела?',
                                          style: AppStyle
                                              .txtSFProDisplayLight14Gray800a0,
                                        ),
                                        SizedBox(
                                          height: getVerticalSize(14),
                                        )
                                      ],
                                    )),
                              ),
                            ),
                            GetBuilder(
                                builder: (K32Controller _c) => Wrap(
                                      children: controller.currentEventList
                                          .map((e) => Padding(
                                                padding: getPadding(
                                                    right: 12, bottom: 18),
                                                child: BodyPartWidget(
                                                  cwidth: size.width / 2 - 30,
                                                  model: e,
                                                  title: e.bodyPart,

                                                  controller: controller,
                                                  color: ColorConstant.whiteA700,
                                                ),
                                              ))
                                          .toList(),
                                    )),
                            Padding(
                              padding: getPadding(top: 36),
                              child:  GetBuilder(
                                  builder: (K32Controller _c) => SizedBox(
                                    height: getVerticalSize(380),
                                    width: (size.width - 32),
                                    child: Row(
                                      children: [
                                        BodyWidget(list: controller.selectedEventList.map((e) => e.bodyPartsModel).toList(),),
                                        BodyWidget(list: controller.selectedEventList.map((e) => e.bodyPartsModel).toList(), index: 2,),
                                      ],
                                    ),
                                  ))
                            ),
                            SizedBox(
                              height: getVerticalSize(100),
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
        alignment: Alignment.bottomCenter,

        color: ColorConstant.gray300,
        child: Center(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: GetBuilder(
                    builder: (K32Controller _c) => Container(
                      width: double.maxFinite,

                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,

                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomButton(
                            height: getVerticalSize(
                              32,
                            ),
                            width: getHorizontalSize(
                              177,
                            ),
                            onTap: () => Navigator.pop(context),
                            text: "выбор эмоции'".toUpperCase(),
                            margin: getMargin(
                              bottom: 10,
                            ),
                            variant: ButtonVariant.Base,
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
                            variant: ButtonVariant.Base,
                            width: getHorizontalSize(
                              140,
                            ),
                            onTap: controller
                                .currentEventList.isNotEmpty
                                ? () {
                              if (controller.selectedEventList.isEmpty) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                    content: Text(
                                        'Выберете часть тела или создайте новую')));
                              } else {
                                if(onSave != null)
                                  onSave!(dayEventModel.copyWith(whatBodyParts: controller.selectedEventList));
                                  else

                                Navigator.pushNamed(
                                    context, AppRoutes.what_i_do,
                                    arguments: dayEventModel.copyWith(whatBodyParts: controller.selectedEventList));
                              }
                            }
                                : () {
                              controller.searchController.text =
                              '';
                              controller.changeCurrentEventList(
                                  controller
                                      .searchController.text);
                              controller.update();
                            },
                            text: controller.currentEventList.isNotEmpty
                                ? "далее".toUpperCase()
                                : 'ОТМЕНА',
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
    )
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
