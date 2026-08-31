import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// Real per-topic illustration ("Хлебные крошки" forest artwork, R2-hosted)
// replaces the old generated-accent-card fallback — same gradient/icon
// look kept as a fallback for any topic without an image_url yet (new
// topics land in Firestore before their artwork is commissioned).
class GuidedJournalTopicCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onInfoTap;
  final String? imageUrl;

  const GuidedJournalTopicCard({
    Key? key,
    required this.title,
    required this.onTap,
    this.onInfoTap,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = (imageUrl ?? '').trim().isNotEmpty;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: getVerticalSize(120),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (hasImage)
                  CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _fallbackGradient(),
                    errorWidget: (_, __, ___) => _fallbackGradient(),
                  )
                else
                  _fallbackGradient(),
                // Bottom scrim so the title/icons stay legible over any
                // artwork, regardless of how light or busy it is.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.55)],
                      stops: const [0.35, 1.0],
                    ),
                  ),
                ),
                Padding(
                  padding: getPadding(left: 20, right: 16, bottom: 14),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Row(
                      children: [
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
                              child:
                                  Icon(Icons.info_outline_rounded, color: Colors.white.withOpacity(0.9), size: 20),
                            ),
                          ),
                        Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.9)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _fallbackGradient() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstant.cyan700.withOpacity(0.55),
            ColorConstant.cyan700.withOpacity(0.85),
          ],
        ),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: getPadding(left: 20, top: 18),
          child: Icon(Icons.auto_stories_rounded, color: Colors.white.withOpacity(0.9), size: 28),
        ),
      ),
    );
  }
}
