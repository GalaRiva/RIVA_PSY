import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/insight_model.dart';
import 'package:riva_psy/core/services/insights/insight_engine.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/adoption_model.dart';
import 'package:riva_psy/presentation/settings/settings_pills/models/pill_model.dart';

import '../../../../../widgets/custom_button.dart';
import '../../../settings/settings_pills/repository.dart';

class MessageBoxWithCentralIcon {
  final String pillName;
  final String time;
  final BuildContext context;
  final DateTime currentDate;

  MessageBoxWithCentralIcon(this.pillName, this.time, this.context, this.currentDate);

  Future _onConfirmTap () async {
    var list  = <PillModel>[];
    list += await PillsRepo().getEvent();
    for(var item in list) {
      if(item.name == pillName) {
        bool needAddDate = true;
        int index = 0;
        for(int i = 0; i < item.adoptions.length; i++) {
          if(item.adoptions[i].adoptionDate == currentDate ) {
            needAddDate = false;
            index = i;
            break;
          }
        }
        if(needAddDate) item.adoptions.add(AdoptionModel(adoptionDate: currentDate, adoptionTimes: [time]));
        else {
          item.adoptions[index].adoptionTimes.add(time);
        }
        break;
      }
    }
    await PillsRepo().updateEvent(list);
    InsightEngine().run().catchError((_) => <InsightModel>[]);
    if(AppRoutes.notificationScreenIsInitial == false) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splashScreen, (route) => false);
    }
  }

  Future _onCancelTap () async {
    var list  = <PillModel>[];
    list += await PillsRepo().getEvent();
    for(var item in list) {
      if(item.name == pillName) {
        bool needAddDate = true;
        for(int i = 0; i < item.adoptions.length; i++) {
          if(item.adoptions[i].adoptionDate == DateTime.now() ) {
            needAddDate = false;
            break;
          }
        }
        if(needAddDate) item.adoptions.add(AdoptionModel(adoptionDate: DateTime.now(), adoptionTimes: [time]));
        break;
      }
    }
    await PillsRepo().updateEvent(list);
    if(AppRoutes.notificationScreenIsInitial == false) {
      Navigator.pop(context);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splashScreen, (route) => false);
    }
  }

  Widget widget() {
    final _width = size.width > getHorizontalSize(290)
        ? getHorizontalSize(290)
        : size.width - 40;
    return SizedBox(
      width: _width,
      child: Card(
        color: ColorConstant.gray200,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(3))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  height: getVerticalSize(30),
                  width: _width,
                  alignment: Alignment.topCenter,
                  color: ColorConstant.cyan700,
                ),
                Container(
                  height: getVerticalSize(53),
                  width: getVerticalSize(53),
                  decoration: BoxDecoration(
                      color: ColorConstant.cyan700, shape: BoxShape.circle),
                  child: CustomImageView(
                    svgPath: ImageConstant.imgSmallLogo,
                    alignment: Alignment.center,
                    width: getVerticalSize(31),
                    height: getVerticalSize(31),
                  ),
                )
              ],
            ),
            Padding(
              padding: getPadding(top: 8),
              child:

            FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                children: [
                  Text('${time} | Что принимаем: ${pillName}'),
                  CustomImageView(
                    height: getHorizontalSize(129),
                    width: getVerticalSize(82),
                    fit: BoxFit.contain,
                    svgPath: ImageConstant.imgHandWithPill,
                    margin: getMargin(top: 0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButton(
                          text: 'ПРИНЯТО',
                          onTap: () async => await _onConfirmTap(),
                          width: getHorizontalSize(127),
                          height: getVerticalSize(32)),
                      SizedBox(width: getHorizontalSize(16),),
                      CustomButton(
                          text: 'ПОЗЖЕ',
                          onTap: () async => await _onCancelTap(),
                          width: getHorizontalSize(127),
                          height: getVerticalSize(32)),
                    ],
                  ),
                  SizedBox(height: 10,)
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
