import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// ignore: must_be_immutable
class CalendarDaysRowWidget extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: getPadding(
              bottom: 1,
            ),
            child: Text(
              "Пн ",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              ),
            ),
          ),
          Padding(
            padding: getPadding(
              bottom: 1,
            ),
            child: Text(
              "Вт",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              ),
            ),
          ),
          Padding(
            padding: getPadding(
              top: 1,
            ),
            child: Text(
              "Ср",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              ),
            ),
          ),
          Padding(
            padding: getPadding(
              bottom: 1,
            ),
            child: Text(
              "Чт",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              ),
            ),
          ),
          Padding(
            padding: getPadding(
              bottom: 1,
            ),
            child: Text(
              "Пт",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              ),
            ),
          ),
          Padding(
            padding: getPadding(
              bottom: 1,
            ),
            child: Text(
              "Сб",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              ),
            ),
          ),
          Padding(
            padding: getPadding(
              bottom: 1,
            ),
            child: Text(
              "Вс",
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                letterSpacing: getHorizontalSize(
                  0.56,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
