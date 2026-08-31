import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// Same local Timer.periodic recalculation pattern as welcome_offer_banner /
// QuizPaywallScreen — anchored locally (not server time) since a manipulated
// device clock has no monetization downside here, only a pacing one.
class PortraitCountdown extends StatefulWidget {
  final DateTime unlockAt;

  const PortraitCountdown({Key? key, required this.unlockAt}) : super(key: key);

  @override
  State<PortraitCountdown> createState() => _PortraitCountdownState();
}

class _PortraitCountdownState extends State<PortraitCountdown> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final remaining = widget.unlockAt.difference(DateTime.now());
    if (!mounted) return;
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${'portrait_unlock_countdown_prefix'.tr()} ${_fmt(_remaining)}',
      style: AppStyle.txtSFProDisplayRegular11.copyWith(
        color: Colors.white.withOpacity(0.7),
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}
