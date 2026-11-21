import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/emotion_color_blob.dart';

/// Colour for an emotion tab, taken from the app's own emotion palette
/// (the same colour as its circle in "Пройти путь" and in the charts).
/// A few tab names have no emotion of their own in that palette, so they
/// borrow the closest one.
Color emotionTileColor(String tag) {
  const borrowed = {
    'panic': 'agitation',
    'depression': 'melancholia',
  };
  final key = borrowed[tag] ?? tag;
  return emotionBlobColor(key, EmotionMood.negative);
}

/// A large "liquid glass" tile in the emotion's own colour: the colour is a
/// translucent, slightly deeper-toward-the-corner fill over a blurred
/// backdrop, with a glossy highlight on top (like light on a lens), a thin
/// bright rim and a soft coloured shadow underneath so it looks like a drop of
/// glass lying on the picture.
class EmotionTile extends StatefulWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const EmotionTile({Key? key, required this.label, required this.color, required this.onTap}) : super(key: key);

  @override
  State<EmotionTile> createState() => _EmotionTileState();
}

class _EmotionTileState extends State<EmotionTile> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.color;
    // Palette colours are dark and dusty; lift them a little so they glow
    // through the glass instead of looking dull.
    final light = Color.lerp(c, Colors.white, 0.30)!;
    final deep = Color.lerp(c, Colors.black, 0.10)!;
    final radius = BorderRadius.circular(22);
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        child: AnimatedScale(
          scale: _down ? 0.97 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: Container(
            constraints: BoxConstraints(minHeight: getVerticalSize(58)),
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: [
                BoxShadow(color: c.withOpacity(0.45), blurRadius: 14, offset: const Offset(0, 6)),
              ],
            ),
            child: ClipRRect(
              borderRadius: radius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Stack(
                  children: [
                    // Liquid body: translucent colour, lighter at the top left.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [light.withOpacity(0.86), deep.withOpacity(0.78)],
                          ),
                        ),
                      ),
                    ),
                    // Glossy lens highlight across the upper half.
                    Positioned(
                      left: 6,
                      right: 6,
                      top: 3,
                      height: getVerticalSize(24),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.white.withOpacity(0.50), Colors.white.withOpacity(0.02)],
                          ),
                        ),
                      ),
                    ),
                    // Soft glow gathered along the bottom edge (light passing
                    // through the glass).
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 3,
                      height: 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: Colors.white.withOpacity(0.38),
                        ),
                      ),
                    ),
                    // Bright rim.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: radius,
                          border: Border.all(color: Colors.white.withOpacity(0.62), width: 1.2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: getPadding(left: 10, right: 10, top: 10, bottom: 10),
                      child: Center(
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.txtSFProDisplayRegular11.copyWith(
                            fontSize: getFontSize(14.5),
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.35), blurRadius: 4)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
