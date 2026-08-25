import 'package:flutter/material.dart';

import '../core/services/insights/insight_popup_store.dart';
import 'glow_message_dialog.dart';

// Same mechanic as GratitudeNudgePopup, for the nightly "smart insight"
// notification — checks once after the main screen's first frame and
// surfaces the last unread one as a gentle modal.
class InsightPopup extends StatefulWidget {
  const InsightPopup({Key? key}) : super(key: key);

  @override
  State<InsightPopup> createState() => _InsightPopupState();
}

class _InsightPopupState extends State<InsightPopup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final content = await InsightPopupStore.consumeUnseen();
      if (content == null || !mounted) return;
      // Strip a leading emoji (the source translation carries "✨ " for the
      // push notification's status-bar title) — the popup already has its
      // own glowing logo badge doing that job visually.
      final title = content.title.replaceFirst(RegExp(r'^[^\w\s]+\s*'), '');
      showGlowMessageDialog(context, title: title, body: content.body);
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
