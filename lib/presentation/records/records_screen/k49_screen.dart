import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/utils/date_extension.dart';
import 'widgets/day_event_widget.dart';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import 'controller.dart';
import '../../../theme/app_colors.dart';

class K49Screen extends GetWidget {
  @override
  Widget build(BuildContext context) {
    bool loading = true;
    final controller = Get.put(K49Controller());
    controller.events = [];
    controller.init().then((value) {
      controller.events = value;
        loading = false;
        controller.update();
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          child: SingleChildScrollView(
            child: Padding(
              padding: getPadding(
                left: 10,
                right: 4,
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
                      'records_title'.tr(),
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
                      left: 6,
                      top: 14,
                    ),
                    child: Text(
                      (DateTime.now().day.toString() +
                              ' ' +
                              DateTime.now().month.monthInText() +
                              ' ') +
                          DateTime.now().year.toString(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtH1,
                    ),
                  ),
                  CustomButton(
                    height: getVerticalSize(
                      32,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.calendar_search, arguments: controller.list);
                    },
                    text: 'find_record'.tr().toUpperCase(),
                    margin: getMargin(
                      left: 68,
                      top: 27,
                      right: 68,
                    ),
                    variant: ButtonVariant.OutlineBluegray60014,
                    fontStyle: ButtonFontStyle.SFProDisplayRegular12Cyan700,
                    suffixWidget: CustomImageView(
                      svgPath: ImageConstant.imgSearch,
                      height: getSize(
                        23,
                      ),
                      width: getSize(
                        23,
                      ),
                      margin: getMargin(
                        left: 10,
                      ),
                    ),
                  ),
                  CustomButton(
                    height: getVerticalSize(
                      32,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.calendar_add, arguments: controller.list);

                    },
                    text: 'add_record'.tr().toUpperCase(),
                    margin: getMargin(
                      left: 68,
                      top: 10,
                      right: 68,
                    ),
                    variant: ButtonVariant.OutlineBluegray60014,
                    fontStyle: ButtonFontStyle.SFProDisplayRegular12Cyan700,
                    suffixWidget: CustomImageView(
                      svgPath: ImageConstant.imgCalendarBlueGray400,
                      height: getSize(
                        23,
                      ),
                      width: getSize(
                        23,
                      ),
                      margin: getMargin(
                        left: 10,
                      ),
                    ),
                  ),

                  GetBuilder(
                    builder: (K49Controller _c) =>Padding(
                    padding: getPadding(top: 28),
                    child: loading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: ColorConstant.cyan700,
                            ),
                          )
                        : controller.isEmpty ? Container(
                    ) :   Wrap(
                      children: controller.events.map((e) => Padding(padding: getPadding(bottom: 16),
                      child: DayEventWidget(
                        onTap: () => Navigator.pushNamed(context, AppRoutes.record_edit, arguments: e.first).then((value) => controller.update()),
                        dayEventModels: e,
                      ),
                      )).toList(),
                    ),
                        ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}

