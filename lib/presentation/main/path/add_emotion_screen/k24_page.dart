import 'package:get/get.dart';
import '../../../../widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_text_form_field.dart';

import 'controller.dart';

// ignore_for_file: must_be_immutable
class K24Page extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final _focus = FocusNode();

    final content = ModalRoute.of(context)?.settings.arguments as Map;
    final controller = Get.put(K24Controller());
    if(controller.eventNameController.text.isEmpty)
    content['initialValue'] == null ? null : controller.eventNameController.text = content['initialValue'];

    return Scaffold(
      backgroundColor: ColorConstant.gray300,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          decoration: AppDecoration.back,
          child: GetBuilder(
            builder:(K24Controller _) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: getPadding(
                        left: 16,
                        right: 0,
                      ),
                      decoration: AppDecoration.outlineBluegray600141.copyWith(
                        borderRadius: BorderRadiusStyle.customBorderBL3,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: getPadding(
                                top: 16,
                                right: 16
                              ),
                              child: Text(
                                content['title'] ?? "Добавить событие",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight14Gray800
                                    .copyWith(
                                  letterSpacing: getHorizontalSize(
                                    0.56,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: getPadding(
                                top: 22,
                                right: 19 + 16,
                                left: 19
                              ),
                              child: Divider(
                                height: getVerticalSize(
                                  1,
                                ),
                                thickness: getVerticalSize(
                                  1,
                                ),
                                color: ColorConstant.blueGray400,
                              ),
                            ),
                          ),
                          Padding(
                            padding: getPadding(
                              top: 48,
                            ),
                            child: Text(
                              "Люди",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtSFProDisplayLight14Gray800a0,
                            ),
                          ),
              Padding(
                padding: getPadding(
                  top: 15,
                ),
                child: Wrap(
                  children: controller.characterList.map((el) => Padding(
                      padding: getPadding(right:  MediaQuery.of(context).size.width / 30),
                      child: EventCard(model: el, onTap: () {
                                        controller.customEvent.svgPath = el.svgPath;
                                        controller.update();
                                      }, isSelect: controller.contain(el)))).toList(),
                                ),


                          ),
                          Padding(
                            padding: getPadding(
                              left: 2,
                              top: 40,
                            ),
                            child: Text(
                              "Животные и природа",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtSFProDisplayLight14Gray800a0,
                            ),
                          ),
                          Padding(
                            padding: getPadding(
                              top: 15,
                            ),
                            child: Wrap(
                              children: controller.animalList.map((el) => Padding(
                                  padding: getPadding(right:  MediaQuery.of(context).size.width / 30),
                                  child: InkWell(
                                      onTap: () {
                                        controller.customEvent.svgPath = el.svgPath;
                                        controller.update();
                                      },
                                      child: EventCard(model: el, isSelect: controller.contain(el)
                                      )))).toList(),
                            ),
                          ),

                          Padding(
                            padding: getPadding(
                              top: 39,
                            ),
                            child: Text(
                              "Места и занятия",
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtSFProDisplayLight14Gray800a0,
                            ),
                          ),
                          Padding(
                            padding: getPadding(
                              top: 15,
                            ),
                            child: Wrap(
                              children: controller.placeList.map((el) => Padding(
                                  padding: getPadding(right:  MediaQuery.of(context).size.width / 30),
                                  child: EventCard(onTap: () {
                                    controller.customEvent.svgPath = el.svgPath;
                                    controller.update();
                                  }
                                      ,model: el, isSelect: controller.contain(el),))).toList(),
                            ),
                          ),
                          Padding(
                            padding: getPadding(right: 16),

                            child: CustomTextFormField(
                              focusNode: _focus,

                              controller: controller.eventNameController,
                              hintText: "Введите название...",
                              margin: getMargin(
                                left: 26,
                                top: 40,
                                right: 25,
                              ),
                              variant: TextFormFieldVariant.Almost,
                              shape: TextFormFieldShape.RoundedBorder3,
                              padding: TextFormFieldPadding.PaddingAll6,
                              fontStyle: TextFormFieldFontStyle.SFProDisplayLight14,
                              textInputAction: TextInputAction.done,
                              alignment: Alignment.center,
                            ),
                          ),
                          Padding(
                            padding: getPadding(right: 16),
                            child: CustomButton(
                              height: getVerticalSize(
                                32,
                              ),
                              width: getHorizontalSize(
                                204,
                              ),
                              onTap: () {
                                if (controller.customEvent.svgPath.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите картинку для события')));
                                }
                                controller.customEvent.name = controller.eventNameController.text;
                                if (controller.customEvent.name.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Выберите название для события')));
                                } else if(controller.customEvent.name.isNotEmpty && controller.customEvent.svgPath.isNotEmpty) {
                                  Navigator.pop(context, controller.customEvent);
                                  Get.delete<K24Controller>();
                                }
                              },
                              text: "добавить".toUpperCase(),
                              margin: getMargin(
                                top: 24,
                                bottom: 73,
                              ),
                              alignment: Alignment.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
