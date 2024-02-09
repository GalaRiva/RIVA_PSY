import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';

import '../../../core/models/day_event_model.dart';
import '../../../widgets/custom_pop_button.dart';
import '../../../widgets/calendar/calendar_days_row_widget.dart';
import '../../../widgets/calendar/calendar_text_button_widget.dart';
import '../../../widgets/calendar/calendar_widget.dart';
import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

import '../calendar_search_screen/controller.dart';


class K50Screen extends GetWidget {

  @override
  Widget build(BuildContext context) {
    List<DayEventModel>? list = (ModalRoute.of(context)?.settings.arguments ?? <DayEventModel>[]) as List<DayEventModel>;
    final controller = Get.put(K50Controller(list, context));
    try {
      controller.getDaysForRows = controller.initializeDaysList();

    } catch (_) {
      print(_);
    }
    return WillPopScope(
      onWillPop: () async {
        await Get.delete<K50Controller>();
        return true;
      },
      child: Scaffold(
        backgroundColor: ColorConstant.gray30002,
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
                              top: 39,
                            ),
                            child: CustomPopButton(text: 'Записи',)
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
                            child: Text(
                              "Архив записей",
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
                              right: 231,
                            ),
                            child: GetBuilder(
                              builder: (K50Controller _c) => ListView.separated(
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
                              right: 231,
                            ),
                            child: GetBuilder(
                              builder: (K50Controller _c) => ListView.separated(
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
                                builder: (K50Controller _c) => ListView.separated(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
