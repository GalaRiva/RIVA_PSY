import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared "gentle notification recovered" modal — a white glass card with a
/// glowing logo badge, used by both the gratitude-nudge and nightly-insight
/// popups (see gratitude_nudge_popup.dart / insight_popup.dart) so a swiped
/// notification isn't lost for good.
Future<void> showGlowMessageDialog(
  BuildContext context, {
  String? title,
  required String body,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.68),
    builder: (_) => _GlowMessageDialog(title: title, body: body),
  );
}

class _GlowMessageDialog extends StatefulWidget {
  final String? title;
  final String body;
  const _GlowMessageDialog({this.title, required this.body});

  @override
  State<_GlowMessageDialog> createState() => _GlowMessageDialogState();
}

class _GlowMessageDialogState extends State<_GlowMessageDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glow = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.chartGold.withOpacity(0.6), width: 1.5),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withOpacity(0.20), blurRadius: 30, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glow,
              builder: (context, child) {
                final t = _glow.value;
                return Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.chartGold.withOpacity(0.5 + t * 0.3), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.chartGold.withOpacity(0.35 + t * 0.25),
                        blurRadius: 16 + t * 10,
                        spreadRadius: 1 + t * 2,
                      ),
                    ],
                  ),
                  // Explicit clip + fixed image size — the logo asset's own
                  // canvas has soft anti-aliased edges that can otherwise
                  // read as "leaking" past the circle's border.
                  child: ClipOval(child: Center(child: child)),
                );
              },
              child: Image.asset('assets/app_icon.png', width: 64, height: 64, fit: BoxFit.contain),
            ),
            const SizedBox(height: 18),
            if (widget.title != null) ...[
              Text(
                widget.title!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1C1E)),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              widget.body,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, height: 1.55, color: Color(0xFF1A1C1E)),
            ),
            const SizedBox(height: 22),
            // Matches the bottom nav bar's central button: flat solid teal
            // with a soft matching shadow, not glass.
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'gratitude_popup_dismiss'.tr(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

