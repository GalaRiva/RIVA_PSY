import 'dart:math' as math;

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

class _K1ScreenState extends State<K1Screen>
    with SingleTickerProviderStateMixin {
  late final K1Controller controller;
  // Drives the highlight travelling around the ring — one full lap every
  // 2.6s. Confirmed on a real device: this AnimationController + the
  // CustomPainter below were never the cause of the earlier "just shows
  // gray" reports — that turned out to be the SafeArea/GetBuilder loading
  // indicator that used to sit at the bottom of this screen (removed
  // below; see k1_controller.dart's `loading` flag if that indicator is
  // needed again — it'll need a different fix, not just re-adding it here).
  late final AnimationController _ringShimmerController;

  @override
  void initState() {
    super.initState();
    _ringShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    Get.delete<K1Controller>();
    controller = Get.put(K1Controller());
    controller.initialization(context);
  }

  @override
  void dispose() {
    _ringShimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              ImageConstant.splashLogoRiva,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
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
          // The artwork (assets/images/splash_logo_riva.png, 360x812) is
          // laid out here with BoxFit.contain inside a FittedBox sharing
          // the exact same 360x812 box the ring's coordinates below were
          // measured in, so the highlight scales/letterboxes identically
          // to the image on any screen size instead of drifting off it.
          Positioned.fill(
            child: IgnorePointer(
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: 360,
                  height: 812,
                  child: AnimatedBuilder(
                    animation: _ringShimmerController,
                    builder: (context, _) => CustomPaint(
                      size: const Size(360, 812),
                      painter:
                          _RingShimmerPainter(_ringShimmerController.value),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Redraws just the ring's own stroke path (measured from
// assets/images/splash_logo_riva.png: badge center (179, 328.5), ring
// radius ~104 in the 360x812 export, open ~80° gap centered at the
// bottom) with a rotating SweepGradient highlight blended additively
// (BlendMode.plus) on top of the artwork's already-static ring — so it
// brightens the printed ring where the highlight currently is, rather
// than replacing/masking it, and small measurement error doesn't show as
// a visible seam.
class _RingShimmerPainter extends CustomPainter {
  final double phase;

  _RingShimmerPainter(this.phase);

  static const Offset _center = Offset(179, 328.5);
  static const double _radius = 104;
  static const double _strokeWidth = 7;
  static const double _startAngleDeg = 130;
  static const double _sweepAngleDeg = 280;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(center: _center, radius: _radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus
      ..shader = SweepGradient(
        transform: GradientRotation(phase * 2 * math.pi),
        colors: const [
          Colors.transparent,
          Colors.transparent,
          Color(0x66FFFFFF),
          Colors.white,
          Color(0x66FFFFFF),
          Colors.transparent,
          Colors.transparent,
        ],
        stops: const [0.0, 0.40, 0.46, 0.50, 0.54, 0.60, 1.0],
      ).createShader(rect.inflate(_strokeWidth));

    canvas.drawArc(
      rect,
      _startAngleDeg * math.pi / 180,
      _sweepAngleDeg * math.pi / 180,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingShimmerPainter oldDelegate) =>
      oldDelegate.phase != phase;
}
