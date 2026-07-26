import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/presentation/settings/settings_pills/settings_pills/controller.dart';
import 'package:riva_psy/widgets/custom_app_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_pop_button.dart';

import '../../../../widgets/custom_bottom_bar.dart';
import '../settings_pills_add_bottom_sheet/settings_pills_add_bottom_sheet.dart';

class PillsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PillsController());

    return Scaffold(
      bottomNavigationBar: CustomBottomBar(),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Padding(
              padding: getPadding(left: 16, right: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomAppBar(widget: CustomPopButton(text: 'settings'.tr())),
                    Padding(
                      padding: getPadding(top: 25),
                      child: Text(
                        'apoinment_reminders'.tr(),
                        style: AppStyle.txtH1,
                      ),
                    ),
                    Padding(
                      padding: getPadding(left: 16, right: 16),
                      child: CustomButton(
                        height: getVerticalSize(42),
                        width: size.width - 64,
                        padding: ButtonPadding.PaddingT8,
                        onTap: () {
                          controller.addPill(context);
                        },
                        text: 'add_pill'.tr().toUpperCase(),
                        prefixWidget: CustomImageView(
                            margin: getMargin(right: 10),
                            svgPath: ImageConstant.imgPill,
                            width: getVerticalSize(24),
                            height: getVerticalSize(24)),
                        suffixWidget: CustomImageView(
                            margin: getMargin(left: 10),
                            svgPath: ImageConstant.imgAdd,
                            width: getVerticalSize(24),
                            height: getVerticalSize(24)),
                      ),
                    ),
                    Padding(padding: getPadding(top: 18, left: 16, right: 16),
                      child: GetBuilder(
                        builder: (PillsController _c) =>
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    padding: ButtonPadding.PaddingT8,
                                    text: 'current_appointments'.tr(),
                                    onTap: () =>
                                        controller.changePillsListState(
                                            PillsList.actual),
                                    textStyle: controller.currentPillsList ==
                                        PillsList.actual
                                        ?  AppStyle.txtSFProDisplayLight16 : AppStyle.txtSFProDisplayLight16Gray ,
                                    bgColor: controller.currentPillsList ==
                                        PillsList.actual
                                        ? Colors.white
                                        : ColorConstant.blueGray100,
                                    showBorder: false,
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: CustomButton(
                                    showBorder: false,
                                    padding: ButtonPadding.PaddingT8,
                                    text: 'date_added'.tr(),
                                    onTap: () =>
                                        controller.changePillsListState(
                                            PillsList.onData),
                                    textStyle: controller.currentPillsList ==
                                        PillsList.onData
                                        ?  AppStyle.txtSFProDisplayLight16 : AppStyle.txtSFProDisplayLight16Gray ,
                                    bgColor: controller.currentPillsList ==
                                        PillsList.onData
                                        ? Colors.white
                                        : ColorConstant.blueGray100,
                                  ),
                                ),
                              ],
                            ),
                      ),),
                    GetBuilder(
                      builder: (PillsController _c) => SizedBox(
                        width: size.width - 32,
                        child: FutureBuilder(
                            future: controller.getPills(),
                            builder: (context, snapshots) {
                              if (snapshots.connectionState ==
                                  ConnectionState.waiting) {
                                return Container(alignment: Alignment.center,
                                  width: 100,
                                  height: 100,
                                  child: CircularProgressIndicator(
                                    color: ColorConstant.cyan700,
                                  ),
                                );
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(padding: getPadding(top: 22),
                                    child: controller.getListOnListType(
                                        controller.currentPillsList ==
                                            PillsList.actual
                                            ? PillsList.actual
                                            : PillsList.onData),
                                  ),
                                  Padding(padding: getPadding(top: 28),
                                    child: controller.getListOnListType(
                                        controller.currentPillsList ==
                                            PillsList.actual
                                            ? PillsList.onData
                                            : PillsList.actual),
                                  )
                                ],
                              );
                            }),
                      ),
                    ),
                    SizedBox(height: getVerticalSize(90),)
                  ],
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: getVerticalSize(86),
              width: size.width,
              color: ColorConstant.gray300,
              child: CustomButton(
                  height: getVerticalSize(32),
                  width: getHorizontalSize(146),
                  text: AppRoutes.currentRoute == AppRoutes.settings
                      ? 'settings'.tr().toUpperCase()
                      : 'back'.tr().toUpperCase(),
                  margin: getMargin(top: 154),
                  padding: ButtonPadding.PaddingT8,
                  prefixWidget: CustomImageView(
                    margin: getMargin(right: 12),
                    svgPath: ImageConstant.leftArrow,
                  ),
                  onTap: () => Navigator.pop(context),
                  alignment: Alignment.center),
            )
          ],
        ),
      ),
    );
  }
}


    