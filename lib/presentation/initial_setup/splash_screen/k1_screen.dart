import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';

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
            // BoxFit.cover crops to fill the screen — on a device aspect
            // ratio noticeably different from the source image (360x812),
            // that can crop out the logo entirely (it isn't perfectly
            // centered in the artwork), leaving only the background color
            // visible. BoxFit.contain guarantees the whole image, logo
            // included, always fits — worst case is letterboxing, and the
            // image's own background is close enough to this Scaffold's
            // gray300 that the letterboxing is barely visible.
            child: Image.asset(
              ImageConstant.splashLogoRiva,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('[SPLASH-DIAG] splashLogoRiva failed to load: $error');
                return const SizedBox.shrink();
              },
            ),
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

