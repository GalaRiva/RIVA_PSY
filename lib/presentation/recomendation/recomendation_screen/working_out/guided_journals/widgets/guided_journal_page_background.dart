import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Shared full-bleed background for every "Хлебные крошки" screen past the
// library (question + insight) — the topic's own cover image, shown as-is:
// no blur, no darkening scrim. Per explicit feedback, the image should
// render unmodified; content on top handles its own legibility instead of
// the background being dimmed for it.
const kGuidedJournalPageBg = Color(0xFF0B1917);

class GuidedJournalPageBackground extends StatelessWidget {
  final String? imageUrl;
  final Widget child;

  const GuidedJournalPageBackground({Key? key, required this.imageUrl, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasImage = (imageUrl ?? '').trim().isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: kGuidedJournalPageBg),
        if (hasImage)
          CachedNetworkImage(
            imageUrl: imageUrl!,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => const SizedBox.shrink(),
          ),
        child,
      ],
    );
  }
}
