import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/utils/date_extension.dart';

import '../../../core/models/day_event_model.dart';
import '../../../widgets/calendar/calendar_days_row_widget.dart';
import '../../../widgets/calendar/calendar_text_button_widget.dart';
import '../../../widgets/calendar/calendar_widget.dart';
import '../../../widgets/custom_pop_button.dart';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../calendar_add_screen/controller.dart';
import '../../../theme/app_colors.dart';

class K51Screen extends GetWidget {

  final String? title;
  final Function(DateTime val)? onTap;
  final Widget? widget;

   K51Screen({ required this.title, required this.widget,this.onTap, });

  @override
  Widget build(BuildContext context) {
    List<DayEventModel>? list = (ModalRoute.of(context)?.settings.arguments ?? <DayEventModel>[]) as List<DayEventModel>;
    final controller = Get.put(K51Controller(list,context));
    try {
      controller.getDaysForRows = controller.initializeDaysList(onTap);

    } catch (_) {
      print(_);
    }
    return WillPopScope(
      onWillPop: () async {
        await Get.delete<K51Controller>();
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: getPadding(
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: getPadding(
                      top: 39,
                    ),
                    child: CustomPopButton(text: 'records_title'.tr(),)
                  ),
                  Row(children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Padding(
                          padding: getPadding(
                            top: 20,
                          ),
                          child: Text(
                            title ?? "calendar".tr(),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtH1,
                          ),
                        ),
                        Padding(
                          padding: getPadding(
                            left: 31,
                            top: 26,
                          ),
                          child: Text(
                            title == null ? "add_record".tr() : '',
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style:
                            AppStyle.txtSFProDisplayLight14Gray800.copyWith(

                              letterSpacing: getHorizontalSize(
                                0.56,
                              ),
                            ),
                          ),
                        ),
                          Padding(
                            padding: getPadding(
                              left: 14,
                              top: 26,
                            ),
                            child: GetBuilder(
                              builder: (K51Controller _c) => ListView.separated(

                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    height: getVerticalSize(
                                      35,
                                    ),
                                  );
                                },
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return CalendarTextButtonWidget(controller.year.toString(), controller.onYearMinus, controller.onYearPlus, 20);
                                },
                              ),
                            ),
                          ),

                          Padding(
                            padding: getPadding(
                              left: 14,
                              top: 26,
                            ),
                            child: GetBuilder(
                              builder: (K51Controller _c) => ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    height: getVerticalSize(
                                      35,
                                    ),
                                  );
                                },
                                itemCount: 1,
                                itemBuilder: (context, index) {
                                  return CalendarTextButtonWidget(controller.month.monthInText(), controller.onMonthMinus, controller.onMonthPlus, 14);
                                },
                              ),
                            ),
                          ),
                      ],),
                    ),
                    if(widget != null)
                    widget!
                  ],),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: getPadding(
                        left: 29,
                        top: 33,
                        right: 29,
                      ),
                      child: ListView.separated(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        separatorBuilder: (context, index) {
                          return SizedBox(
                            height: getVerticalSize(
                              21,
                            ),
                          );
                        },
                        itemCount: 1,
                        itemBuilder: (context, index) {
                          return CalendarDaysRowWidget();
                        },
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: getPadding(
                        left: 29,
                        top: 33,
                        right: 29,
                      ),
                      child: GetBuilder(
                        builder: (K51Controller _c) => ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            return SizedBox(
                              height: getVerticalSize(
                                21,
                              ),
                            );
                          },
                          itemCount: controller.getDaysForRows.length,
                          itemBuilder: (context, index) {
                            return CalendarWidget(controller.getDaysForRows[index]);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
