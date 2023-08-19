import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/user_data/user.dart';

import 'k1_controller.dart';

class K1Screen extends GetWidget {


  @override
  Widget build(BuildContext context) {


    final controller = Get.put(K1Controller());
    controller.initialization(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.gray300,
        body: Stack(
            alignment: Alignment.center,
            children:[ Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    height: getVerticalSize(
                      184,
                    ),
                    width: getHorizontalSize(
                      209,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            elevation: 0,
                            margin: getMargin(
                              bottom: 1,
                            ),
                            color: ColorConstant.teal200,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                getHorizontalSize(
                                  79,
                                ),
                              ),
                            ),
                            child: Container(
                              height: getSize(
                                158,
                              ),
                              width: getSize(
                                158,
                              ),
                              padding: getPadding(
                                left: 35,
                                top: 26,
                                right: 35,
                                bottom: 26,
                              ),
                              decoration:
                                  AppDecoration.fillTeal200.copyWith(
                                borderRadius:
                                    BorderRadiusStyle.circleBorder79,
                              ),
                              child: Stack(
                                children: [
                                  CustomImageView(
                                    svgPath:
                                        ImageConstant.imgUnionWhiteA700,
                                    height: getVerticalSize(
                                      93,
                                    ),
                                    width: getHorizontalSize(
                                      73,
                                    ),
                                    alignment: Alignment.topRight,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: getVerticalSize(
                            184,
                          ),
                          width: getHorizontalSize(
                            209,
                          ),
                          child: Image.asset(ImageConstant.imgEllipse102),
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    height: getVerticalSize(
                      43,
                    ),
                    width: getHorizontalSize(
                      187,
                    ),
                    margin: getMargin(
                      top: 12,
                      bottom: 122,
                    ),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        CustomImageView(
                          svgPath: ImageConstant.imgRigelCyan700,
                          height: getVerticalSize(
                            38,
                          ),
                          width: getHorizontalSize(
                            166,
                          ),
                          alignment: Alignment.bottomLeft,
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            "PSY",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style:
                                AppStyle.txtAkrobatBold20Cyan700.copyWith(
                              letterSpacing: getHorizontalSize(
                                0.8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          GetBuilder(
            builder: (K1Controller _) => Visibility(
                visible: controller.loading,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: getPadding(bottom: 50),
                    child: Text('Идёт установка дополнительный файлов, пожалуйста, подождите', style: AppStyle.txtSFProDisplayLight10Gray800,),
                  ),
                )),
          )
          ]
        ),
      ),
    );
  }
}

