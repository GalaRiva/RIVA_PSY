import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:riva_psy/core/services/datasource_service.dart';
import 'package:riva_psy/core/utils/size_utils.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/theme/app_style.dart';

/// A soft panel for the "how to live through it" buttons of an emotion: a
/// mint ground with a light wave band (as on the website) and the emotion's own
/// line drawing behind frosted-glass capsules, so the glass has something to
/// blur. [children] are the capsules ([GlassChip] via SelectButtonWidget).
class EmotionGlassPanel extends StatelessWidget {
  final String title;
  final String? illustration;
  final List<Widget> children;

  const EmotionGlassPanel({Key? key, required this.title, required this.children, this.illustration}) : super(key: key);

  Widget? _art() {
    final path = illustration;
    if (path == null || path.isEmpty) return null;
    final w = getHorizontalSize(100);
    if (path.startsWith('assets/')) {
      return path.endsWith('.svg')
          ? SvgPicture.asset(path, width: w, fit: BoxFit.contain)
          : Image.asset(path, width: w, fit: BoxFit.contain);
    }
    if (DataSourceService.dataSourceIsRemote()) {
      return SvgPicture.network(path, width: w, fit: BoxFit.contain, placeholderBuilder: (_) => SizedBox(width: w));
    }
    return SvgPicture.file(File(path), width: w, fit: BoxFit.contain);
  }

  @override
  Widget build(BuildContext context) {
    final art = _art();
    return Container(
      // Full width always: inside a start-aligned Column the panel used to shrink
      // to its content, so panels of different emotions had different widths.
      width: double.infinity,
      margin: getPadding(left: 16, right: 16, top: 24, bottom: 8),
      decoration: BoxDecoration(color: const Color(0xFFE3EEEA), borderRadius: BorderRadius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _WavePainter())),
          if (art != null) Positioned(right: getHorizontalSize(16), top: 46, child: ExcludeSemantics(child: art)),
          Padding(
            padding: getPadding(left: 16, right: 16, top: 20, bottom: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: art != null ? 224.0 : 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(
                      fontSize: getFontSize(15),
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: art != null ? 44.0 : 14.0),
                  Wrap(spacing: getHorizontalSize(8), runSpacing: getVerticalSize(8), children: children),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A soft, wide band sweeping across the panel, a lighter tone than the ground.
class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s.height * 0.22
      ..color = Colors.white.withOpacity(0.55);
    final p = Path()
      ..moveTo(-s.width * 0.1, s.height * 0.22)
      ..cubicTo(s.width * 0.25, s.height * 0.02, s.width * 0.3, s.height * 0.62, s.width * 0.6, s.height * 0.55)
      ..cubicTo(s.width * 0.85, s.height * 0.5, s.width * 0.9, s.height * 0.9, s.width * 1.1, s.height * 0.86);
    canvas.drawPath(p, paint);
    // A second, teal-tinted band lower down, so glass over it has a visible tone to refract.
    final tint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s.height * 0.16
      ..color = AppColors.primary.withOpacity(0.10);
    final q = Path()
      ..moveTo(-s.width * 0.1, s.height * 0.8)
      ..cubicTo(s.width * 0.2, s.height * 0.55, s.width * 0.45, s.height * 1.0, s.width * 0.75, s.height * 0.78)
      ..cubicTo(s.width * 0.9, s.height * 0.68, s.width * 1.0, s.height * 0.62, s.width * 1.1, s.height * 0.66);
    canvas.drawPath(q, tint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => false;
}

/// One frosted-glass capsule: blurred backdrop, white veil, hairline white edge.
class GlassChip extends StatelessWidget {
  final String text;
  final bool pressed;
  final VoidCallback onTap;

  const GlassChip({Key? key, required this.text, required this.onTap, this.pressed = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(24);
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: size.width - getHorizontalSize(64)),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Material(
            color: Colors.white.withOpacity(pressed ? 0.6 : 0.26),
            shape: RoundedRectangleBorder(borderRadius: radius, side: BorderSide(color: Colors.white.withOpacity(0.9), width: 1.2)),
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: Padding(
                padding: getPadding(left: 16, right: 16, top: 11, bottom: 11),
                child: Text(
                  text,
                  style: AppStyle.txtSFProDisplayRegular11.copyWith(
                    fontSize: getFontSize(14),
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
