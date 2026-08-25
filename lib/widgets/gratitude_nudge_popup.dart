import 'package:flutter/material.dart';

import '../core/services/insights/gratitude_nudge_store.dart';
import 'glow_message_dialog.dart';

// Invisible on its own — its only job is to check, once after the main
// screen's first frame, whether a "spontaneous gratitude" push landed while
// the user wasn't looking at it (or they swiped it away unread) and surface
// it once as a gentle modal instead of it being lost for good.
class GratitudeNudgePopup extends StatefulWidget {
  const GratitudeNudgePopup({Key? key}) : super(key: key);

  @override
  State<GratitudeNudgePopup> createState() => _GratitudeNudgePopupState();
}

class _GratitudeNudgePopupState extends State<GratitudeNudgePopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final text = await GratitudeNudgeStore.consumeUnseen();
      if (text == null || !mounted) return;
      showGlowMessageDialog(context, body: text);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
