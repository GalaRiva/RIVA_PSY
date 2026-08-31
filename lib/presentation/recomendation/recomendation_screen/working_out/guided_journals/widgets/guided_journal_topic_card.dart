import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// No dedicated illustration exists per-topic (only whole-group icons, which
// would visually duplicate the negative-emotions tab this sits next to) —
// same generated-accent-card visual language as HeroAudioCarousel's
// no-cover fallback, built as a real tappable library card instead of a
// carousel item.
class GuidedJournalTopicCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;

  const GuidedJournalTopicCard({Key? key, required this.title, required this.onTap, this.onInfoTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          height: getVerticalSize(88),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ColorConstant.cyan700.withOpacity(0.55),
                ColorConstant.cyan700.withOpacity(0.85),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: getPadding(left: 20, right: 16),
          child: Row(
            children: [
              Icon(Icons.auto_stories_rounded, color: Colors.white.withOpacity(0.9), size: 28),
              SizedBox(width: getHorizontalSize(16)),
              Expanded(
                child: Text(
                  title,
                  style: AppStyle.txtSFProDisplayLight16.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onInfoTap != null)
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onInfoTap,
                  child: Padding(
                    padding: getPadding(all: 6),
                    child: Icon(Icons.info_outline_rounded, color: Colors.white.withOpacity(0.85), size: 20),
                  ),
                ),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.85)),
            ],
          ),
        ),
      ),
    );
  }
}
