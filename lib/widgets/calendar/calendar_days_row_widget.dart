import 'package:easy_localization/easy_localization.dart';
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
              'monday_short'.tr(),
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
              'tuesday_short'.tr(),
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
              'wednesday_short'.tr(),
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
              'thursday_short'.tr(),
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
              'friday_short'.tr(),
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
              'saturday_short'.tr(),
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
              'sunday_short'.tr(),
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
