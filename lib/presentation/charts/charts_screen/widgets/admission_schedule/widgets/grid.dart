import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';

import '../../../../../settings/settings_pills/models/pill_model.dart';

Widget scheduleGrid(BuildContext context,
    {required List<PillModel> pills,
    required DateTime startPeriod,
    required DateTime endPeriod,
      required VoidCallback update,
      bool showText = false,
    double standardCellSize = 15}) {
  List<DateTime> _getDatesBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> dates = [];
    DateTime currentDate = startDate;

    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(Duration(days: 1));
    }

    return dates;
  }

  final days = _getDatesBetween(startPeriod, endPeriod);

  List<Widget> _cells(PillModel pill, String currentTime, bool first) {
    final list = _getDatesBetween(pill.startDate, pill.endDate);
    return List<Widget>.generate(days.length, (index) {
      Widget child() {
        if (list.contains(days[index])) {
          print('contains');
        for (var item in pill.adoptions) {
          print(item.adoptionDate);

            if (item.adoptionTimes.contains(currentTime) && item.adoptionDate.dateInText() == days[index].dateInText()) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: getHorizontalSize(standardCellSize / 2),
                    height: getHorizontalSize(standardCellSize / 2),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: ColorConstant.cyan700),
                  ),
                  Visibility(
                    visible: showText,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        currentTime,
                        style: AppStyle.txtSFProDisplayRegular9Deeppurple600,
                      ),
                    ),
                  )
                ],
              );
            }
          }
          return GestureDetector(
            onTap: () {
              if(DateTime.now().difference(days[index]).inDays == 0)
              Navigator.pushNamed(context, AppRoutes.concrete_pill, arguments: {
                'pill':pill.name,
                'time':currentTime,
                'date': days[index]
              }).then((value) => update());
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: getHorizontalSize(standardCellSize / 2),
                  height: getHorizontalSize(standardCellSize / 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: Colors.white),
                ),
                Visibility(
                  visible: showText,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      currentTime,
                      style: AppStyle.txtSFProDisplayRegular9Deeppurple600,
                    ),
                  ),
                )
              ],
            ),
          );
        }
        return Container(
        );
      }

      return _oneCell(
          width: standardCellSize, height: standardCellSize, child: child(), first: first);
    });
  }

  return Scrollbar(
      controller: ScrollController(),
      scrollbarOrientation: ScrollbarOrientation.bottom,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: getVerticalSize(20),
      radius: Radius.circular(10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: getHorizontalSize(100),

                        height: getHorizontalSize(standardCellSize),
                        child: Align(
                          alignment: Alignment.center,
                            child: Text(
                          '${startPeriod.month.monthInText()}-${endPeriod.month.monthInText()} ${endPeriod.year}',
                          style: AppStyle.txtSFProDisplayLight8blueGray,
                        ))),
                    Wrap(
                      direction: Axis.horizontal,
                      children: days
                          .map((e) => SizedBox(
                                width: getHorizontalSize(standardCellSize),
                                height: getHorizontalSize(standardCellSize),
                                child: Center(
                                  child: Text(
                                    e.day.toString(),
                                    style: AppStyle.txtSFProDisplayLight8blueGray,
                                  ),
                                ),
                              ))
                          .toList(),
                    )
                  ],
                ),
                Divider(
                  color: ColorConstant.gray500,
                  thickness: 1,
                  height: 1,
                  indent: 0,
                  endIndent: 0,
                ),
                Wrap(
                  direction: Axis.vertical,
                  children: List<Widget>.generate(pills.length, (index) {
                    final pill = pills[index];
                    return Row(
                      children: [
                        _oneCell(
                          width: 100,
                          height: (standardCellSize * pill.hoursOfTakingPills.length)
                              .toDouble(),
                          first: index == 0 ? true : false,
                          child: Text(
                            pill.name,
                            style: AppStyle.txtSFProDisplayLight8blueGray,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: pill.hoursOfTakingPills
                              .map((e) => Wrap(
                                    direction: Axis.horizontal,
                                    children: _cells(pill, e,index == 0 ? true : false,),
                                  ))
                              .toList(),
                        )
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: getVerticalSize(30),),
              ],
            ),

          ],
        ),
      ));
}

Widget _oneCell(
    {double height = 15, double width = 15, required Widget child, bool first  = false}) {
  return Container(
    width: getHorizontalSize(width),
    height: getHorizontalSize(height),
    decoration: BoxDecoration(
        border: Border(
            right: BorderSide(color: ColorConstant.gray500),
            bottom: BorderSide(color: ColorConstant.gray500),
        top: first ? BorderSide(color: ColorConstant.gray500) : BorderSide(color: Colors.transparent))),
    child: Padding(
      padding: getPadding(all: 2),
      child: child,
    ),
  );
}
