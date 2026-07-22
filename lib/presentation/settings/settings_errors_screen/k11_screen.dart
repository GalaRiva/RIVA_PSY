import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/custom_pop_button.dart';
import 'controller.dart';

class K11Screen extends GetWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K11Controller());
    return Scaffold(
        backgroundColor: ColorConstant.gray300,
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
                            CustomAppBar(widget: CustomPopButton(text: 'Настройки',),),
                            Padding(
                                padding: getPadding(top: 25),
                                child: Text("Сообщить об ошибке",
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1)),
                            Padding(
                                padding: getPadding(top: 20),
                                child: Text(
                                    "Пожалуйста, опишите, что пошло не так",
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
                                      hintText: 'Ваши предложения',

                                      hintStyle: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w300, fontSize: 14, color: ColorConstant.fromHex('#3B3B4A'),)
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                                padding: getPadding(top: 34, right: 45),
                                child: Text(
                                    "Приложите скриншот экрана приложения, где возникла ошибка",
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
                                          child: Text(controller.model.value.fileName == null ? "Загрузить изображение" : controller.model.value.fileName!,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.left,
                                              style: AppStyle
                                                  .txtSFProDisplayLight14Cyan700),
                                        )),
                              ),
                            ),
                            CustomButton(
                                width: getHorizontalSize(172),
                                text: "отправить".toUpperCase(),
                                onTap: () async {
                                  if(controller
                                      .model.value.controller.text.isEmpty) return null;
                                  else {
                                    try {
                                      await controller.createOffer().then((value) =>                                         showDialog(context: context, builder: (context) => CustomMessageBox(title: 'Сообщение об ошибке', content: 'Предложение было отправлено')));
                                    } catch(_) {
                                      print(_);
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка, попробуйте позже или проверьте подключение к интернету')));
                                    }
                                  }

                                },
                                    margin: getMargin(top: 83),
                                alignment: Alignment.center),
                            CustomButton(
                                width: getHorizontalSize(146),
                                text: "настройки".toUpperCase(),
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
