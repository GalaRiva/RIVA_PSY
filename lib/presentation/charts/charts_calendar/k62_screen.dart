import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/utils/date_extension.dart';

import '../../../core/models/calendar/month_model.dart';
import '../../../widgets/calendar/calendar_days_row_widget.dart';
import '../../../widgets/calendar/calendar_text_button_widget.dart';
import '../../../widgets/calendar/calendar_widget.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_pop_button.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import '../../../widgets/period_confirm_bar.dart';

import 'controller.dart';
import '../../../theme/app_colors.dart';

class K62Screen extends GetWidget {

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K62Controller(context));
    controller.state = PeriodState.Start;
    controller.periodStart = null;
    controller.periodEnd = null;
    controller.state = PeriodState.Start;
    controller.getDaysForRows = [];
    controller.getDaysForRows = controller.initializeDaysList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
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
                              top: 14,
                            ),
                            child: CustomPopButton(text: 'charts'.tr(),)
                        ),
                        Padding(
                          padding: getPadding(
                            top: 6,
                          ),
                          child: Text(
                            'calendar'.tr(),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtH1,
                          ),
                        ),
                        Padding(
                          padding: getPadding(
                            left: 31,
                            top: 12,
                          ),
                          child: GetBuilder(
                            builder: (K62Controller _c) => Text(
                              controller.periodStart == null ? 'select_start_period'.tr() : 'select_end_period'.tr(),
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
                        ),
                        Padding(
                          padding: getPadding(left: 31, top: 6, right: 12),
                          child: GetBuilder(
                            builder: (K62Controller _c) {
                              String d(DateTime? x) => x == null
                                  ? '...'
                                  : '${x.day.toString().padLeft(2, '0')}.${x.month.toString().padLeft(2, '0')}.${x.year}';
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${d(controller.periodStart)}  →  ${d(controller.periodEnd)}',
                                      style: AppStyle.txtSFProDisplayLight16
                                          .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                  SizedBox(height: getVerticalSize(4)),
                                  Text('period_hint_months'.tr(),
                                      style: AppStyle.txtSFProDisplayLight14
                                          .copyWith(color: const Color(0xFF4A545A), height: 1.4)),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: getPadding(
                            left: 14,
                            top: 8,
                          ),
                          child: GetBuilder(
                            builder: (K62Controller _c) => ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: getVerticalSize(
                                    4,
                                  ),
                                );
                              },
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return CalendarTextButtonWidget(controller.year.toString(), controller.onYearMinus, controller.onYearPlus, 26);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: getPadding(
                            left: 14,
                            top: 8,
                          ),
                          child: GetBuilder(
                            builder: (K62Controller _c) => ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: getVerticalSize(
                                    4,
                                  ),
                                );
                              },
                              itemCount: 1,
                              itemBuilder: (context, index) {
                                return CalendarTextButtonWidget(controller.month.monthInText(), controller.onMonthMinus, controller.onMonthPlus, 22);
                              },
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: getPadding(
                              left: 29,
                              top: 12,
                              right: 29,
                            ),
                            child: ListView.separated(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              separatorBuilder: (context, index) {
                                return SizedBox(
                                  height: getVerticalSize(
                                    10,
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
                              top: 12,
                              right: 29,
                            ),
                            child: GetBuilder(
                              builder: (K62Controller _c) => ListView.separated(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return SizedBox(
                                    height: getVerticalSize(
                                      10,
                                    ),
                                  );
                                },
                                itemCount: controller.getDaysForRows.length,
                                itemBuilder: (context, index) {
                                  return CalendarWidget(controller.getDaysForRows[index],);
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
              PeriodConfirmBar(
                onSave: () async {
                  controller.popWithData(context);
                },
                onCancel: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
