import 'package:flutter/material.dart';

/// A tall picture that sits behind translucent glass and slides slower than the
/// page while it scrolls. The glass tiles stay with the content but the picture
/// behind them drifts, so the colour seen through each tile keeps changing, the
/// way it does with real glass.
///
/// The picture is always taller than the block, and the shift is mapped onto
/// the block's travel through the screen, so its edges never show.
class ParallaxBackdrop extends StatefulWidget {
  final String asset;

  const ParallaxBackdrop({Key? key, required this.asset}) : super(key: key);

  @override
  State<ParallaxBackdrop> createState() => _ParallaxBackdropState();
}

class _ParallaxBackdropState extends State<ParallaxBackdrop> {
  final ValueNotifier<double> _t = ValueNotifier<double>(0.5);
  ScrollPosition? _position;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = Scrollable.maybeOf(context)?.position;
    if (next != _position) {
      _position?.removeListener(_update);
      _position = next;
      _position?.addListener(_update);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _update());
  }

  @override
  void dispose() {
    _position?.removeListener(_update);
    _t.dispose();
    super.dispose();
  }

  // 0 when the block is just entering from the bottom of the screen, 1 when it
  // has just left through the top.
  void _update() {
    if (!mounted) return;
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return;
    final viewport = MediaQuery.of(context).size.height;
    final top = box.localToGlobal(Offset.zero).dy;
    final travel = viewport + box.size.height;
    _t.value = ((viewport - top) / travel).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final h = c.maxHeight;
      // The backdrop file is 800 x 2080; keep its proportions.
      final imageHeight = w * 2.6;
      final slack = (imageHeight - h).clamp(0.0, double.infinity);
      return ClipRect(
        child: ValueListenableBuilder<double>(
          valueListenable: _t,
          builder: (context, t, _) => OverflowBox(
            alignment: Alignment.topCenter,
            minHeight: imageHeight,
            maxHeight: imageHeight,
            minWidth: w,
            maxWidth: w,
            child: Transform.translate(
              offset: Offset(0, -slack * t),
              child: Image.asset(widget.asset, width: w, height: imageHeight, fit: BoxFit.cover),
            ),
          ),
        ),
      );
    });
  }
}
