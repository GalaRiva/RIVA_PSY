import 'dart:ui';

import 'package:flutter/material.dart';

// Matte frosted-glass backing for text/controls placed over a photographic
// background — used throughout the quiz/paywall flow wherever a full-bleed
// image sits behind readable content.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color tint;

  const GlassCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.blurSigma = 18,
    this.tint = const Color(0x59FFFFFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Small pill variant for compact chrome (progress indicator, skip link)
// over an image, rather than a full card.
class GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const GlassPill({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: padding,
      borderRadius: const BorderRadius.all(Radius.circular(100)),
      blurSigma: 14,
      tint: const Color(0x40FFFFFF),
      child: child,
    );
  }
}
