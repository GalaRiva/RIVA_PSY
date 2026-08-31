import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// Shared glassmorphism button for the whole "Проекция Я" module — deep,
// tinted glass with a radial glow at the center (as if lit from within), a
// frosted backdrop blur, and a thin bright edge to read as glass rather
// than flat paint. One accent color drives the whole look, so every button
// in the module (onboarding CTA, finale CTAs, ...) shares the same
// treatment instead of each screen inventing its own button style.
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final Color accent;
  final double height;

  const GlassButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.accent = const Color(0xFF1FAE7A),
    this.height = 54,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Darkened base tone the whole glow is built from (not the raw accent)
    // — keeps the surface moody enough for white button text to stay
    // legible even when accent itself is light/white.
    final base = Color.lerp(accent, Colors.black, 0.4)!;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: height,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.7,
                colors: [
                  Color.lerp(base, Colors.white, 0.15)!.withOpacity(0.72),
                  Color.lerp(base, Colors.white, 0.06)!.withOpacity(0.7),
                  base.withOpacity(0.68),
                  Color.lerp(base, Colors.black, 0.3)!.withOpacity(0.78),
                  Color.lerp(base, Colors.black, 0.5)!.withOpacity(0.85),
                ],
                stops: const [0.0, 0.3, 0.55, 0.8, 1.0],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
              boxShadow: [
                BoxShadow(color: base.withOpacity(0.45), blurRadius: 22, spreadRadius: 0),
                BoxShadow(
                  color: Color.lerp(base, Colors.white, 0.4)!.withOpacity(0.22),
                  blurRadius: 10,
                  spreadRadius: -2,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glass sheen — a soft highlight along the top edge.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 22,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white.withOpacity(0.12), Colors.white.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ),
                Text(
                  text,
                  style: AppStyle.txtSFProDisplayRegular14.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    shadows: [Shadow(color: Colors.black.withOpacity(0.4), blurRadius: 8)],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
