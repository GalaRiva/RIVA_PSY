import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// "Ambient Bloom" card background for the analytics dashboards — soft,
/// large, low-opacity color blooms behind a translucent glass layer,
/// instead of the chart's own bubbles/cells being the only color on an
/// otherwise flat white card. Colour reads as atmosphere here; the actual
/// data marks (bubbles, cells, the line's endpoint) stay small and precise
/// so they still read as the thing you're looking at.
class AmbientBloomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AmbientBloomCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(20, 21, 20, 20),
  }) : super(key: key);

  Widget _bloom({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.24), color.withOpacity(0.0)],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(0.16), blurRadius: 30, spreadRadius: 2),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF7),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
          ),
          child: Stack(
            children: [
              Positioned(top: -70, left: -50, child: _bloom(size: 240, color: AppColors.chartTeal)),
              Positioned(top: -40, right: -70, child: _bloom(size: 210, color: AppColors.chartAqua)),
              Positioned(bottom: -80, left: -30, child: _bloom(size: 220, color: AppColors.chartStress)),
              Positioned.fill(child: Container(color: Colors.white.withOpacity(0.4))),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      ),
    );
  }
}
