import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../day_event_model.dart';


class DayModel extends StatelessWidget{
  final VoidCallback? onTap;
  final int year;
  final int month;
  final int day;
  final bool? isActive;
  final DayEventModel? dayEventModel;
  final bool? periodStart;
  final bool? periodEnd;
  final bool? inPeriod;
  final DayType type;
  DayModel( {required this.type,this.inPeriod, this.onTap,required this.day,this.dayEventModel, required this.isActive, this.periodStart, this.periodEnd, required this.year, required this.month,});

  Widget build (BuildContext context) => Container(
    width: getSize(33),
    height: getSize(33),
    alignment: Alignment.center,
    child: type == DayType.dayEvents  ? _childDayEvents() : _childPeriods() // Padding all 9
  );

  Widget _childPeriods () {

      return InkWell(
        onTap: onTap,
        child: Container(
          width: getSize(36),
          height: getSize(36),
          decoration: BoxDecoration(
              color: (inPeriod ?? false) ? Colors.white : (periodStart ?? false) ?  Colors.white : Colors.transparent,
              border: (periodStart ?? false) ? Border.all(color: ColorConstant.fromHex('#403875')) : (periodEnd?? false) ? Border.all(color: ColorConstant.cyan700) : null
          ),
          child: Center(
            child: Text(
              day.toString(),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: isActive!
                  ? AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              )
                  : AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                  letterSpacing: getHorizontalSize(
                    0.56,
                  ),
                  color: ColorConstant.fromHex('#3B3B4A')
                      .withOpacity(0.22)),
            ),
          ),
        ),
      );
  }

  Widget _childDayEvents () {
    if(dayEventModel != null) {
      return InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            IgnorePointer(
            child: SleekCircularSlider(
              appearance: CircularSliderAppearance(
                  animationEnabled: false,
                  infoProperties: InfoProperties(
                      topLabelText: '',
                      mainLabelStyle: TextStyle(color: Colors.transparent)
                  ),
                  startAngle: 105,
                  angleRange: 330,
                  size: getSize(33),
                  customColors: CustomSliderColors(
                    trackColor: Colors.transparent,
                    dotColor: Colors.transparent,
                    progressBarColors: [
                      ColorConstant.fromHex('#403875'),
                      ColorConstant.fromHex('#7FBDBA'),
                    ],
                  ),
                  customWidths: CustomSliderWidths(
                      progressBarWidth: 3,
                      trackWidth: 3)),
              min: 0,
              max: 10,
              initialValue: dayEventModel!.howDoYouFeel!.toDouble(),
            ),
          ),
          Container(
            width: getSize(22),
            height: getSize(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100)
            ),
            child: Center(
              child: Text(
                day.toString(),
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
          )
          ]
        ),
      );
    } else {
      return InkWell(
        onTap: onTap,
        child: Container(
          height: getSize(33),
          width: getSize(33),
          alignment: Alignment.center,
          child: Text(
            day.toString(),
            style: isActive!
                ? AppStyle.txtSFProDisplayLight14Gray800.copyWith(
              letterSpacing: getHorizontalSize(
                0.56,
              ),
            )
                : AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
                color: ColorConstant.fromHex('#3B3B4A')
                    .withOpacity(0.22)),
          ),
        ),
      );
    }
  }
}


enum DayType {
  dayEvents,
  periods
}