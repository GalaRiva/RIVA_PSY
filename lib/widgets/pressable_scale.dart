import 'package:flutter/material.dart';

/// Wraps any widget with a press-down/spring-back scale effect — native
/// Flutter, no animation package needed.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double minScale;

  const PressableScale({Key? key, required this.child, this.onTap, this.minScale = 0.92}) : super(key: key);

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = widget.minScale),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
