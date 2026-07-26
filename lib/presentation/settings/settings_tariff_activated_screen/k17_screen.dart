import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../core/models/tariff_model.dart';
import '../../../core/user_data/user.dart';
import 'controller.dart';
import 'repository.dart';

class K17Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(seconds: 3), () async {
      try{
      AppRoutes.currentRoute = AppRoutes.main;
      Navigator.pushReplacementNamed(context, AppRoutes.main);
      } catch(_) {
        print(_);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('network_error_try_later'.tr())));
      }
    });
    return Scaffold(
      backgroundColor: ColorConstant.teal200,
      body: SafeArea(
        child: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: getMargin(
                      bottom: 5,
                    ),
                    padding: getPadding(
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: getHorizontalSize(
                            182,
                          ),
                          margin: getMargin(
                            top: 90,
                          ),
                          child: Text(
                            'tariff_activated_congrats'.tr(),
                            maxLines: null,
                            textAlign: TextAlign.center,
                            style: AppStyle.txtH1WhiteA700,
                          ),
                        ),
                        CustomImageView(
                          svgPath: ImageConstant.imgGroup76,
                          height: getVerticalSize(
                            125,
                          ),
                          width: getHorizontalSize(
                            109,
                          ),
                          margin: getMargin(
                            top: 56,
                          ),
                        ),
                        Container(
                          height: getVerticalSize(
                            446,
                          ),
                          width: getHorizontalSize(
                            136,
                          ),
                          margin: getMargin(
                            top: 56,
                          ),
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              CustomImageView(
                                svgPath: ImageConstant.imgGroup75,
                                height: getVerticalSize(
                                  443,
                                ),
                                width: getHorizontalSize(
                                  136,
                                ),
                                alignment: Alignment.center,
                              ),
                              CustomImageView(
                                svgPath: ImageConstant.imgAirplane,
                                height: getVerticalSize(
                                  32,
                                ),
                                width: getHorizontalSize(
                                  16,
                                ),
                                alignment: Alignment.topRight,
                                margin: getMargin(
                                  right: 14,
                                ),
                              ),
                            ],
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
    );
  }
}
