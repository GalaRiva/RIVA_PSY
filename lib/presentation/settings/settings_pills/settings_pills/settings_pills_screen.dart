import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/utils/size_utils.dart';
import 'package:listenmebaby71_s_application17/presentation/settings/settings_pills/settings_pills/controller.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_app_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_pop_button.dart';

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
                    CustomAppBar(widget: CustomPopButton(text: 'Настройки')),
                    Padding(
                      padding: getPadding(top: 25),
                      child: Text(
                        'Напоминания о приёме',
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
                        text: 'Добавить препарат'.toUpperCase(),
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
                                CustomButton(
                                  height: getVerticalSize(42),
                                  width: (size.width - 64 - 5) / 2,
                                  padding: ButtonPadding.PaddingT8,
                                  text: 'Актуальные назначения',
                                  onTap: () =>
                                      controller.changePillsListState(
                                          PillsList.actual),

                                  variant: controller.currentPillsList ==
                                      PillsList.actual
                                      ? ButtonVariant.White
                                      : ButtonVariant.OutlineBluegray60014_1,
                                ),
                                CustomButton(
                                  height: getVerticalSize(42),
                                  width: (size.width - 64 - 5) / 2,
                                  padding: ButtonPadding.PaddingT8,
                                  text: 'По дате внесения',
                                  onTap: () =>
                                      controller.changePillsListState(
                                          PillsList.onData),
                                  variant: controller.currentPillsList ==
                                      PillsList.onData
                                      ? ButtonVariant.White
                                      : ButtonVariant.OutlineBluegray60014_1,
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
                      ? "настройки".toUpperCase()
                      : "назад".toUpperCase(),
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


    