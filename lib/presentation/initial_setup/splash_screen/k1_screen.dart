import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';

import 'k1_controller.dart';

class K1Screen extends GetWidget {


  @override
  Widget build(BuildContext context) {


    // The app uses plain MaterialApp, not GetMaterialApp — GetX's automatic
    // route-based dependency cleanup (GetObserver marking a controller
    // "dirty" when its route is disposed) never runs anywhere in this app,
    // because that hook is only wired up by GetMaterialApp. Get.put() is a
    // no-op when a non-dirty instance already exists (see get_instance.dart,
    // _insert()), so without this explicit delete, every return trip to
    // this screen (which happens on every login and every sign-up, not
    // just app cold start — see k2_controller.dart in sign_in/sign_up)
    // reused the *same* K1Controller from the very first visit: wasInit
    // already true, secondsToNewPage already zeroed from that first run's
    // completed timer(). initialization() then took the `else timer(context)`
    // branch straight away with a 0-second delay, navigating off this
    // screen before the splash image ever got a frame to paint — a blank
    // flash, not a rendering bug in the image itself.
    Get.delete<K1Controller>();
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
                // Was SizedBox.shrink() on error — if decoding ever fails,
                // that renders nothing at all, which looks identical to
                // "no problem, just an empty screen" from a screenshot.
                // Reported symptom is a fully blank screen with no logo,
                // no ring, no text whatsoever — if this branch is what's
                // firing, this makes that unmistakable instead of another
                // silent blank.
                return Container(
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'SPLASH LOAD ERROR:\n$error',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
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
          // TEMPORARY DIAGNOSTIC — remove once the blank-splash-on-repeat-
          // login investigation is closed. Deliberately crude (yellow,
          // top of the Stack, unmissable): if this doesn't appear at all on
          // a repeat visit, build() itself isn't running / isn't reaching
          // paint at that moment, which rules out everything inside this
          // widget's own logic (the 99036b7 controller-recreation fix
          // included) and points further up the navigation/frame pipeline.
          // If it DOES appear, the printed values pin down exactly what
          // state this build() call actually saw.
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              color: const Color(0xFFFFEB3B),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: Text(
                'DIAG build() @ ${DateTime.now().toIso8601String()}\n'
                'wasInit=${controller.wasInit} secondsToNewPage=${controller.secondsToNewPage} loading=${controller.loading}',
                style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

