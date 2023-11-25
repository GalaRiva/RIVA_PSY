import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../core/models/day_event_model.dart';
import 'controller.dart';

class K38Screen extends GetWidget {
  final fieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K38Controller());
    DayEventModel? dayEventModel =
    ((ModalRoute.of(context)?.settings.arguments ?? DayEventModel())
    as DayEventModel);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.gray300,
        body: SizedBox(
          width: size.width,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: getPadding(
                    left: 15,
                    bottom: 5,
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
                          left: 1,
                          top: 15,
                        ),
                        child: Text(
                          "Первые мысли в ситуации",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtH1,
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          left: 5,
                          top: 29,
                        ),
                        child: Text(
                          "Например: Вот бы и мне так!",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtSFProDisplayLight14Gray800,
                        ),
                      ),
                      Padding(
                        padding:
                        getPadding(left: 0, top: 18, right: 0),
                        child: SizedBox(
                          height: 57,
                          width: MediaQuery.of(context).size.width - 32,
                          child: TextFormField(
                            controller: fieldController,
                            maxLines: 30,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: BorderSide.none
                                ),
                                fillColor: ColorConstant.grayLight,
                                filled: true,
                                hintText: 'Ваши мысли',

                                hintStyle: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w300, fontSize: 14, color: ColorConstant.fromHex('#3B3B4A'),)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: getPadding(left: 16, bottom: 10, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        height: getVerticalSize(
                          32,
                        ),
                        width: getHorizontalSize(
                          159,
                        ),
                        onTap: ()=>Navigator.pop(context),
                        text: "Что я сделал".toUpperCase(),
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
                        onTap: () async {
                          dayEventModel.firstThoughts = fieldController.text;
                          dayEventModel.date = DateTime.now();
                          controller.createNewDayEvent(dayEventModel, context);
                        },
                        text: "Сохранить".toUpperCase(),
                      ),
                    ],
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
