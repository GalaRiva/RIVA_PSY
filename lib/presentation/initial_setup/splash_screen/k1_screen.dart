import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';

import 'k1_controller.dart';
import '../../../theme/app_colors.dart';

class K1Screen extends StatefulWidget {
  const K1Screen({Key? key}) : super(key: key);

  @override
  State<K1Screen> createState() => _K1ScreenState();
}

class _K1ScreenState extends State<K1Screen> {
  late final K1Controller controller;

  @override
  void initState() {
    super.initState();
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
    // completed timer(). initState() runs exactly once per route visit (a
    // new Route always gets a new State), which is what this fix needs:
    // fresh-per-visit without being fresh-per-rebuild too.
    Get.delete<K1Controller>();
    controller = Get.put(K1Controller());
    controller.initialization(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            child: GetBuilder<K1Controller>(
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
