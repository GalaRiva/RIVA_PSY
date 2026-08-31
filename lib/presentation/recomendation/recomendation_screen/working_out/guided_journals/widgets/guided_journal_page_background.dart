import 'dart:ui';

import 'package:flutter/material.dart';

// Shared full-bleed background for every "Хлебные крошки" screen past the
// library (question + insight) — the topic's own cover image, softly
// blurred, with a dark scrim for text contrast. A light touch (sigma 6),
// not the strong blur an initial pass used — the source artwork is
// already somewhat soft, so a heavy blur on top of it read as mushy.
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
        if (hasImage) ...[
          Image.network(imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),
        ],
        child,
      ],
    );
  }
}
