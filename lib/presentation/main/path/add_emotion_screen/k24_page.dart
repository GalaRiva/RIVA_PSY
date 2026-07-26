import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import '../../../../widgets/event_card.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

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
                                content['title'] ?? 'add_event'.tr(),
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
                              'people'.tr(),
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
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: EventCard(model: el, onTap: () {
                                          controller.customEvent.svgPath = el.svgPath;
                                          controller.update();
                                        },
                            cardWidth:  size.width / 2 - 30,

                            isSelect: controller.contain(el)),
                      ))).toList(),
                                ),


                          ),
                          Padding(
                            padding: getPadding(
                              left: 2,
                              top: 40,
                            ),
                            child: Text(
                              'animals_and_nature'.tr(),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: EventCard(model: el, onTap: () {
                                      controller.customEvent.svgPath = el.svgPath;
                                      controller.update();
                                    },
                                        cardWidth:  size.width / 2 - 30,
                                        isSelect: controller.contain(el)
                                    ),
                                  ))).toList(),
                            ),
                          ),

                          Padding(
                            padding: getPadding(
                              top: 39,
                            ),
                            child: Text(
                              'places_and_activities'.tr(),
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
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: EventCard(model: el, onTap: () {
                                      controller.customEvent.svgPath = el.svgPath;
                                      controller.update();
                                    },
                                      cardWidth:  size.width / 2 - 30, isSelect: controller.contain(el),),
                                  ))).toList(),
                            ),
                          ),
                          Padding(
                            padding: getPadding(right: 16),

                            child: CustomTextFormField(
                              focusNode: _focus,

                              controller: controller.eventNameController,
                              hintText: 'enter_name'.tr(),
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

                              width: getHorizontalSize(
                                204,
                              ),
                              onTap: () {
                                if (controller.customEvent.svgPath.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('choose_picture_for_event'.tr())));
                                }
                                controller.customEvent.name = controller.eventNameController.text;
                                if (controller.customEvent.name.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('choose_name_for_event'.tr())));
                                } else if(controller.customEvent.name.isNotEmpty && controller.customEvent.svgPath.isNotEmpty) {
                                  Navigator.pop(context, controller.customEvent);
                                  Get.delete<K24Controller>();
                                }
                              },
                              text: 'add'.tr().toUpperCase(),
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
