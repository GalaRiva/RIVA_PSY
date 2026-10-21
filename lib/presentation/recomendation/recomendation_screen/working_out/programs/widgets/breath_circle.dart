import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

import 'course_ui.dart';

// A slow breathing guide: the circle grows on the breath in and shrinks on
// the (longer) breath out, with a light tap at each change and a breath
// counter. No score, nothing to "complete": it can be stopped any time.
class BreathCircle extends StatefulWidget {
  final int inhale;
  final int exhale;
  final int cycles;
  const BreathCircle({Key? key, required this.inhale, required this.exhale, required this.cycles})
      : super(key: key);

  @override
  State<BreathCircle> createState() => _BreathCircleState();
}

class _BreathCircleState extends State<BreathCircle> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  bool _running = false;
  bool _done = false;
  int _cycle = 0; // breaths finished
  bool _inPhase = true;

  double get _total => (widget.inhale + widget.exhale).toDouble();

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: Duration(seconds: widget.inhale + widget.exhale))
      ..addListener(_onTick)
      ..addStatusListener((s) {
        if (s != AnimationStatus.completed || !_running) return;
        setState(() => _cycle++);
        if (_cycle >= widget.cycles) {
          setState(() {
            _running = false;
            _done = true;
          });
        } else {
          _c.forward(from: 0);
        }
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _onTick() {
    final inPhase = _c.value * _total < widget.inhale;
    if (inPhase != _inPhase) {
      _inPhase = inPhase;
      HapticFeedback.selectionClick();
      setState(() {});
    }
  }

  void _start() {
    setState(() {
      _running = true;
      _done = false;
      _cycle = 0;
      _inPhase = true;
    });
    HapticFeedback.selectionClick();
    _c.forward(from: 0);
  }

  void _stop() {
    _c.stop();
    setState(() => _running = false);
  }

  double _scale() {
    if (!_running && !_done) return 0.55;
    if (_done) return 0.55;
    final t = _c.value * _total;
    if (t < widget.inhale) return 0.55 + 0.45 * Curves.easeInOut.transform(t / widget.inhale);
    return 1.0 - 0.45 * Curves.easeInOut.transform((t - widget.inhale) / widget.exhale);
  }

  @override
  Widget build(BuildContext context) {
    final size = getSize(220);
    final label = _done
        ? 'course_breath_done'.tr()
        : !_running
            ? 'course_breath_ready'.tr()
            : (_inPhase ? 'course_breath_in' : 'course_breath_out').tr();
    return Padding(
      padding: getPadding(top: 22),
      child: Column(
        children: [
          SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                final s = _scale();
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withOpacity(0.12), width: 1.5),
                      ),
                    ),
                    Container(
                      width: size * s,
                      height: size * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [AppColors.primary.withOpacity(0.28), AppColors.primary.withOpacity(0.12)],
                        ),
                      ),
                    ),
                    Text(label,
                        textAlign: TextAlign.center,
                        style: AppStyle.txtH2.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: getVerticalSize(12)),
          Text('${_running || _done ? _cycle.clamp(0, widget.cycles) : 0} / ${widget.cycles}',
              style: AppStyle.txtSFProDisplayRegular11.copyWith(color: AppColors.textSecondary, letterSpacing: 0.6)),
          SizedBox(height: getVerticalSize(14)),
          SizedBox(
            width: getHorizontalSize(190),
            child: CapsuleButton(
              outlined: true,
              label: (_running ? 'course_timer_stop' : (_done ? 'course_breath_again' : 'course_timer_start')).tr(),
              onTap: _running ? _stop : _start,
            ),
          ),
        ],
      ),
    );
  }
}
