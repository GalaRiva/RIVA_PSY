import 'package:get/get.dart';
import 'package:riva_psy/core/utils/date_extension.dart';

import '../../../../../core/models/calendar/month_model.dart';
import '../../../../../widgets/calendar/calendar_days_row_widget.dart';
import '../../../../../widgets/calendar/calendar_text_button_widget.dart';
import '../../../../../widgets/calendar/calendar_widget.dart';
import '../../../../../widgets/custom_button.dart';
import '../../../../../widgets/custom_pop_button.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import 'controller.dart';
import '../../../../../theme/app_colors.dart';

class WorkingOutCalendarPage extends GetWidget {

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WorkingOutCalendarController(context));
    controller.state = PeriodState.Start;
    controller.periodStart = null;
    controller.periodEnd = null;
    controller.state = PeriodState.Start;
    controller.getDaysForRows = [];
    controller.getDaysForRows = controller.initializeDaysList();

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Container(
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
                              top: 39,
                            ),
                            child: CustomPopButton(text: 'Рекомендации',)
                        ),
                        Padding(
                          padding: getPadding(
                            top: 20,
                          ),
                          child: Text(
                            "Календарь",
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
                          child: GetBuilder(
                            builder: (WorkingOutCalendarController _c) => Text(
                              controller.periodStart == null ? 'Выберите начало периода' : 'Выберите конец периода',
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
                          padding: getPadding(
                            left: 14,
                            top: 26,
                          ),
                          child: GetBuilder(
                            builder: (WorkingOutCalendarController _c) => ListView.separated(
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
                            builder: (WorkingOutCalendarController _c) => ListView.separated(
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
                              builder: (WorkingOutCalendarController _c) => ListView.separated(
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
                                  return CalendarWidget(controller.getDaysForRows[index],);
                                },
                              ),
                            ),
                          ),
                        ),
                        CustomButton(
                            height: getVerticalSize(32),
                            width: getHorizontalSize(186),
                            onTap: () async {
                              controller.popWithData(context);
                            },
                            text: "сохранить".toUpperCase(),
                            padding: ButtonPadding.PaddingT8,
                            margin: getMargin(top: 90),
                            alignment: Alignment.center),
                        CustomButton(
                            height: getVerticalSize(32),
                            width: getHorizontalSize(186),
                            onTap: () => Navigator.pop(context),
                            text: "отмена".toUpperCase(),
                            padding: ButtonPadding.PaddingT8,
                            alignment: Alignment.center),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
