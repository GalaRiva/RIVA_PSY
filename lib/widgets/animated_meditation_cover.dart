import 'dart:math' as math;

import 'package:flutter/material.dart';

// "Submerged Resonance": a glass-like heart silhouette breathing on a dark
// field — green/teal/deep-blue fill, a glowing gold rim, soft ambient halo
// for air, and a slow diagonal sheen. Code-drawn so the pulse/glow/shimmer
// the design calls for comes for free, no static asset.
class HeartCongruenceCover extends StatefulWidget {
  const HeartCongruenceCover({Key? key}) : super(key: key);

  @override
  State<HeartCongruenceCover> createState() => _HeartCongruenceCoverState();
}

class _HeartCongruenceCoverState extends State<HeartCongruenceCover>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 7200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFF040807)),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _HeartResonancePainter(_controller.value),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _HeartResonancePainter extends CustomPainter {
  final double phase;
  _HeartResonancePainter(this.phase);

  static const _gold = Color(0xFFE0B36A);
  static const _teal = Color(0xFF2FA98C);
  static const _green = Color(0xFF3FBE7A);
  static const _deepBlue = Color(0xFF0E2B4A);

  Path _heartPath(Rect bounds) {
    final path = Path();
    const steps = 140;
    for (int i = 0; i <= steps; i++) {
      final t = (i / steps) * 2 * math.pi;
      final sinT = math.sin(t);
      final x = 16 * sinT * sinT * sinT;
      final y = 13 * math.cos(t) -
          5 * math.cos(2 * t) -
          2 * math.cos(3 * t) -
          math.cos(4 * t);
      final nx = x / 16;
      final ny = -y / 17;
      final px = bounds.center.dx + nx * bounds.width / 2;
      final py = bounds.center.dy + ny * bounds.height / 2;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final breath = (math.sin(phase * 2 * math.pi) + 1) / 2;
    final scale = 0.94 + breath * 0.06;

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF040807));

    final bounds = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.52),
      width: w * 0.62,
      height: h * 0.62,
    );
    final heart = _heartPath(bounds);

    final haloPaint = Paint()
      ..color = _teal.withOpacity(0.16 + breath * 0.06)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.16);
    canvas.drawCircle(bounds.center, w * 0.36 * scale, haloPaint);
    final goldHaloPaint = Paint()
      ..color = _gold.withOpacity(0.10 + breath * 0.05)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.22);
    canvas.drawCircle(
      bounds.center.translate(w * 0.03, -h * 0.02),
      w * 0.4 * scale,
      goldHaloPaint,
    );

    canvas.save();
    canvas.translate(bounds.center.dx, bounds.center.dy);
    canvas.scale(scale);
    canvas.translate(-bounds.center.dx, -bounds.center.dy);

    canvas.save();
    canvas.clipPath(heart);

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_green.withOpacity(0.85), _teal.withOpacity(0.7), _deepBlue.withOpacity(0.92)],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(bounds);
    canvas.drawRect(bounds.inflate(4), fillPaint);

    final swirl1 = Paint()
      ..color = _green.withOpacity(0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    canvas.drawCircle(
      Offset(
        bounds.left + bounds.width * (0.35 + math.sin(phase * 2 * math.pi) * 0.05),
        bounds.top + bounds.height * 0.4,
      ),
      bounds.width * 0.28,
      swirl1,
    );

    final swirl2 = Paint()
      ..color = _deepBlue.withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(
      Offset(bounds.right - bounds.width * 0.28, bounds.top + bounds.height * 0.55),
      bounds.width * 0.3,
      swirl2,
    );

    // Sweep travels within (0.15, 0.85) so the ±0.12 stop offsets never
    // leave (0, 1) — kept strictly increasing without extra clamping
    // (see k1_screen's ring shimmer, which broke once when stops collapsed).
    final sweepT = 0.15 + breath * 0.7;
    final sheenPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.10),
          Colors.transparent,
        ],
        stops: [sweepT - 0.12, sweepT, sweepT + 0.12],
      ).createShader(bounds);
    canvas.drawRect(bounds.inflate(4), sheenPaint);

    canvas.restore();

    final rimGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..color = _gold.withOpacity(0.35 + breath * 0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawPath(heart, rimGlow);

    final rimCore = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = _gold.withOpacity(0.65 + breath * 0.3);
    canvas.drawPath(heart, rimCore);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeartResonancePainter oldDelegate) =>
      oldDelegate.phase != phase;
}
