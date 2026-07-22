import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_search_view.dart';
import '../../../../widgets/event_card.dart';
import '../../../main/path/what_body_parts_screen/controller.dart';
import '../../../main/path/what_body_parts_screen/k32_model.dart';
import '../../../main/path/what_body_parts_screen/widgets/selected_body_parts_widget.dart';
import '../controller.dart';
import 'body_parts_widget.dart';

class BottomSheetWidget extends StatelessWidget {
  final Function(EventModel model)? onChangeEventModel;
  final Function(K32Model model)? onChangeBodyPartsModel;
  final Function(String text)? onChangeSearchText;
  final String hintText;
  final String initialText;
  final K52Controller controller;
  final List<EventModel>? events;
  final List<K32Model>? bodyParts;

  const BottomSheetWidget(
      {Key? key,
      this.events,
      required this.bodyParts,
      required this.initialText,
      required this.hintText,
      required this.controller,
      this.onChangeEventModel,
      this.onChangeBodyPartsModel,this.onChangeSearchText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(text: initialText);
    var list = events == null ? bodyParts : events;
    return Container(
      height: size.height * 0.75,
      width: size.width,
      child: Padding(
        padding: getPadding(all: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CustomSearchView(
                onChange: (text) async {
                  await onChangeSearchText!(textController.text);
                  list = list is List<K32Model> ? controller.bodyParts : controller.eventList;
                  controller.update();
                },
                focusNode: FocusNode(),
                controller: textController,
                hintText: hintText,
                margin: getMargin(
                  top: 29,
                ),
                suffix: Container(
                  margin: getMargin(
                    left: 30,
                    top: 1,
                    right: 9,
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
              Padding(
                padding: getPadding(top: 34),
                child: Visibility(
                      visible: controller.selectedBodyParts.isNotEmpty && list is List<K32Model>,
                      child: GetBuilder(
                        builder: (K52Controller _c) => Column(
                          children: [
                            SizedBox(
                              height: getVerticalSize(50),
                              child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: false,
                                  itemCount: controller.selectedBodyParts.length,
                                  itemBuilder: (context, index) =>
                                      InkWell(
                                        onTap: () {
                                          controller.selectedBodyParts.remove(controller.selectedBodyParts[index]);
                                          controller.update();
                                        },
                                        child: IgnorePointer(
                                          child: SelectedBodyPartsWidget(
                                            model: controller.selectedBodyParts[index],
                                            list: controller.selectedBodyParts,
                                            controller: K32Controller(),
                                          ),
                                        ),
                                      )),
                            ),
                            SizedBox(
                              height: getVerticalSize(29),
                            ),
                            Text(
                              'Хотите добавить части тела?',
                              style: AppStyle.txtSFProDisplayLight14Gray800a0,
                            ),
                            SizedBox(
                              height: getVerticalSize(14),
                            )
                          ],
                        ),
                      )),
                ),

              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 10,
                  child: GetBuilder(
                    builder: (K52Controller _c) => Padding(
                      padding: getPadding(left: 6),
                      child: Wrap(
                          spacing: 12,

                          children: list is List<EventModel>
                              ? list!.map((el) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: EventCard(
                                cardWidth: size.width / 2 - 30,
                                  model: el as EventModel,
                                  onTap: () => onChangeEventModel!(el), isSelect: false,
                                ),
                              ))
                                  .toList()
                              : list is List<K32Model> ? list!.map((e) => Padding(
                                          padding:
                                              getPadding( bottom: 18),
                                          child: BodyPartWidget(
                                            cwidth: size.width / 2 - 40,
                                            model: (e as K32Model).bodyPartsModel,
                                            controller: controller,
                                            title: (e.bodyPartsModel).bodyPart,
                                            color: Colors.white,
                                          ),
                                        ),
                                      )
                                      .toList()
                                  : []),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
