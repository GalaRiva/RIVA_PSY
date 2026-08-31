import 'package:flutter/material.dart';

import '../../../../routes/app_routes.dart';
import 'cta_action.dart';
import 'widgets/audio_track_sheet.dart';

// One central place mapping a CtaAction to real navigation — tests and
// their hybrid combinations only ever store a CtaAction value, never a
// route string directly, so renaming/moving a destination screen later
// only means touching this file (PROJECT_CONTEXT.md §62).
class CtaActionRouter {
  static void navigate(BuildContext context, CtaAction action, {String? audioLabel}) {
    switch (action.type) {
      case CtaActionType.energyMatrix:
      case CtaActionType.socialBattery:
        // Both widgets already live on the same Charts (K61) screen — no
        // dedicated route/tab per widget exists.
        Navigator.pushNamed(context, AppRoutes.charts);
        break;

      case CtaActionType.desiresScreen:
        Navigator.pushNamed(context, AppRoutes.recommendations,
            arguments: {'initialTab': 1, 'workingOutTab': 2});
        break;

      case CtaActionType.challengeThought:
      case CtaActionType.challengeDo:
        // No separate "challenge an action" screen exists — both CTA
        // flavors open the same "Оспорить мысль" exercise.
        Navigator.pushNamed(context, AppRoutes.recommendations,
            arguments: {'initialTab': 1, 'workingOutTab': 0});
        break;

      case CtaActionType.happinessInFocus:
        Navigator.pushNamed(context, AppRoutes.recommendations,
            arguments: {'initialTab': 1, 'workingOutTab': 1});
        break;

      case CtaActionType.audioTrack:
        AudioTrackSheet.show(context, trackId: action.trackId!, title: audioLabel ?? '');
        break;
    }
  }
}
