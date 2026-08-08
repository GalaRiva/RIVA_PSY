import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';
import '../../../theme/app_colors.dart';

class K11Screen extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K11Controller());
    return Scaffold(
        backgroundColor: AppColors.background,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                  child: Padding(
                      padding: getPadding(left: 16, right: 16, bottom: 5),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CustomAppBar(widget: CustomPopButton(text: 'settings'.tr(),),),
                            Padding(
                                padding: getPadding(top: 25),
                                child: Text('report_an_error'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Padding(
                                padding: getPadding(top: 20),
                                child: Text(
                                    'describe_issue'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle
                                        .txtSFProDisplayLight14Gray800)),
                            Padding(
                              padding:
                              getPadding(top: 18, right: 16),
                              child: SizedBox(
                                height: 57,
                                width: MediaQuery.of(context).size.width - 32,
                                child: TextFormField(
                                  controller: controller.model.value.controller,
                                  maxLines: 30,
                                  decoration: InputDecoration(

                                      contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.zero,
                                          borderSide: BorderSide.none
                                      ),
                                      fillColor: ColorConstant.grayLight,
                                      filled: true,
                                      hintText: 'your_suggestions'.tr(),

                                      hintStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w300, fontSize: 14, color: ColorConstant.fromHex('#3B3B4A'),)
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: getPadding(top: 34, right: 45),
                                child: Text(
                                    'error_screenshot'.tr(),
                                    maxLines: null,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtSFProDisplayLight14)),
                            Center(
                              child: GetBuilder(
                                builder: (K11Controller _controller) =>
                                    Padding(
                                        padding: getPadding(top: 12),
                                        child: InkWell(
                                          onTap: () async {
                                            await controller.getImage();
                                          },
                                          child: Text(controller.model.value.fileName == null ? 'upload_image'.tr() : controller.model.value.fileName!,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left,
                                              style: AppStyle
                                                  .txtSFProDisplayLight14Cyan700),
                                        )),
                              ),
                            ),
                            CustomButton(
                                width: getHorizontalSize(172),
                                text: 'send'.tr().toUpperCase(),
                                onTap: () async {
                                  if(controller
                                      .model.value.controller.text.isEmpty) return null;
                                  else {
                                    try {
                                      await controller.createOffer().then((value) =>                                         showDialog(context: context, builder: (context) => CustomMessageBox(title: 'error_message_title'.tr(), content: 'suggestion_sent'.tr())));
                                    } catch(_) {
                                      print(_);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('network_error_try_later'.tr())));
                                    }
                                  }

                                },
                                    margin: getMargin(top: 83),
                                alignment: Alignment.center),
                            CustomButton(
                                width: getHorizontalSize(146),
                                text: 'settings'.tr().toUpperCase(),
                                margin: getMargin(top: 29),
                                padding: ButtonPadding.PaddingT8,
                                prefixWidget: CustomImageView(
                                  margin: getMargin(right: 12),
                                  svgPath: ImageConstant.leftArrow,
                                ),
                                onTap: () => onTaptf(context),
                                alignment: Alignment.center)
                          ])))),
        ),
        bottomNavigationBar:
            CustomBottomBar(onChanged: (BottomBarEnum type) {}));
  }

  onTaptf(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.settings);
  }
}
