import 'dart:math';

import 'package:flutter/material.dart';

/// Small radiating-dot "success" burst — plays whenever [trigger] changes
/// value. Native Flutter (AnimationController + CustomPainter-free particle
/// list), no Lottie/asset dependency — there's no ready-made animation
/// asset for this, and this effect is simple enough not to need one.
class SparkBurst extends StatefulWidget {
  final int trigger;
  final Color color;
  final double travel;

  const SparkBurst({Key? key, required this.trigger, this.color = const Color(0xFF3FBF8F), this.travel = 46})
      : super(key: key);

  @override
  State<SparkBurst> createState() => _SparkBurstState();
}

class _SparkBurstState extends State<SparkBurst> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
  }

  @override
  void didUpdateWidget(covariant SparkBurst oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger != oldWidget.trigger) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          if (t <= 0 || t >= 1) return const SizedBox();
          final distance = widget.travel * Curves.easeOut.transform(t);
          final opacity = (1 - t).clamp(0.0, 1.0);
          const count = 8;
          return Stack(
            alignment: Alignment.center,
            children: List.generate(count, (i) {
              final angle = (2 * pi / count) * i;
              return Transform.translate(
                offset: Offset(cos(angle) * distance, sin(angle) * distance),
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color),
                  ),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
