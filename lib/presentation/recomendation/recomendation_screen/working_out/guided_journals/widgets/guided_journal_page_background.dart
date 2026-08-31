import 'package:flutter/material.dart';

// Shared full-bleed background for every "Хлебные крошки" screen past the
// library (question + insight) — plain dark, same tone as the library
// screen itself. An earlier version rendered the topic's own cover image
// here, blurred — dropped per explicit feedback: the source artwork is
// already fairly soft, and blurring it on top just read as mushy rather
// than atmospheric.
const kGuidedJournalPageBg = Color(0xFF0B1917);

class GuidedJournalPageBackground extends StatelessWidget {
  final Widget child;

  const GuidedJournalPageBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: kGuidedJournalPageBg, child: child);
  }
}
