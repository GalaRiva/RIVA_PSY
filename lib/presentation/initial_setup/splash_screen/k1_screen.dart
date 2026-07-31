import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:provider/provider.dart';

import '../../../providers/language_provider.dart';
import 'k1_controller.dart';

class K1Screen extends GetWidget {


  @override
  Widget build(BuildContext context) {


    final controller = Get.put(K1Controller());
    controller.initialization(context);
    return Scaffold(
      backgroundColor: ColorConstant.gray300,
      // Was a hand-built widget tree combining a teal circular badge with
      // a separate wordmark image (img_rigel_cyan_700.svg) that spelled
      // "RIGEL", not "RIVA" — a leftover from the pre-rebrand build that
      // visual comparisons against Figma kept missing because nobody
      // actually rendered this exact screen. Replaced with the
      // user-supplied reference export (same role as bg_native.png for
      // the native splash) as a single full-bleed image; the loading
      // indicator overlay is unchanged.
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.asset(ImageConstant.splashLogoRiva, fit: BoxFit.cover),
          ),
          SafeArea(
            child: GetBuilder(
              builder: (K1Controller _) => Visibility(
                  visible: controller.loading,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: getPadding(bottom: 50),
                      child: Text('Идёт установка дополнительный файлов, пожалуйста, подождите', style: AppStyle.txtSFProDisplayLight10Gray800,),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

