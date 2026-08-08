import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// Premium redesign (body map, spec block 4): was a flat filled circle —
// now a soft radial-gradient "glowing sphere" (glow via BoxShadow blur,
// per spec) so emotion markers on the body silhouette read as a gentle
// glow instead of a hard-edged dot.
Widget CircularContainerWidget ({
  final double? height,
  final double? width,
  final EdgeInsetsGeometry? margin,
  final Color? color,
}) {
  final markerColor = color ?? ColorConstant.teal200;
  final size = height == null ? getSize(39) : height;
  return Container(
    margin: margin,
    height: size,
    width: width == null ? getSize(39) : width,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          markerColor.withOpacity(0.95),
          markerColor.withOpacity(0.0),
        ],
      ),
      boxShadow: [
        BoxShadow(
          color: markerColor.withOpacity(0.55),
          blurRadius: size * 0.6,
          spreadRadius: size * 0.08,
        ),
      ],
    ),
  );
}