import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../core/models/day_event_model.dart';
import 'controller.dart';
import '../../../../theme/app_colors.dart';

class K38Screen extends GetWidget {

  final fieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K38Controller());
    DayEventModel? dayEventModel =
    ((ModalRoute.of(context)?.settings.arguments ?? DayEventModel())
    as DayEventModel);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SizedBox(
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
                          'current_emotion'.tr(),
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
                          'first_thoughts_in_situation'.tr(),
                          maxLines: 2,
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
                          'for_example_wish_it_was_me'.tr(),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtSFProDisplayLight14Gray800,
                        ),
                      ),
                      Padding(
                        padding:
                        getPadding(left: 0, top: 18, right: 0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 32,
                          child: TextFormField(
                            controller: fieldController,
                            minLines: 5,
                            maxLines: 30,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: BorderSide.none
                                ),
                                fillColor: ColorConstant.grayLight,
                                filled: true,
                                hintText: 'your_thoughts'.tr(),

                                hintStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w300, fontSize: 14, color: ColorConstant.fromHex('#3B3B4A'),)
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
                  padding: getPadding(left: 16, top: 14, bottom: 10, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomButton(
                        height: getVerticalSize(
                          32,
                        ),
                        width: getHorizontalSize(
                          159,
                        ),
                        variant: ButtonVariant.Base,
                        onTap: ()=>Navigator.pop(context),
                        text: 'what_did_I_do'.tr().toUpperCase(),
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
                        onTap: () async {
                          dayEventModel.firstThoughts = fieldController.text;
                          dayEventModel.date = DateTime.now();
                          controller.createNewDayEvent(dayEventModel, context);
                        },
                        text: 'save'.tr().toUpperCase(),
                      ),
                    ],
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
