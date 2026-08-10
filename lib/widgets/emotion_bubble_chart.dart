import 'dart:math';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/utils/color_constant.dart';
import '../core/utils/size_utils.dart';
import '../presentation/charts/charts_screen/models/emotion_model.dart';
import '../theme/app_style.dart';
import 'emotion_color_blob.dart';

/// "Эмоциональное облако" (2026-08-10): replaces the flat pie+legend for
/// "Какие эмоции я испытываю" with a force-directed bubble cloud — positive
/// emotions drift to the top zone, negative to the bottom, bubble area is
/// proportional to how often that emotion was logged, and a regrouped
/// legend (positive/negative, each sorted by frequency) sits underneath.
///
/// The physics is a small hand-rolled simulation (gravity toward a zone +
/// pairwise circle repulsion + velocity damping) driven by a raw [Ticker],
/// rather than a general-purpose physics engine — the app has no existing
/// physics dependency, and this scene is simple enough (a few dozen
/// non-rotating circles) not to need one.
class EmotionBubbleChart extends StatefulWidget {
  final List<EmotionModel> data;

  const EmotionBubbleChart({Key? key, required this.data}) : super(key: key);

  @override
  State<EmotionBubbleChart> createState() => _EmotionBubbleChartState();
}

class _Bubble {
  final EmotionModel model;
  final bool positive;
  double x, y;
  double vx = 0, vy = 0;
  final double radius;

  // "Дыхание": once settled, each bubble drifts toward a small random
  // offset (1-3px) and holds it for a few seconds before picking a new one
  // — an organic, Perlin-ish wander rather than a continuous wave, so the
  // whole cloud doesn't visibly pulse in lockstep. jitterX/jitterY are the
  // current interpolated values the painter reads; they never feed back
  // into x/y so they can't perturb the collision physics.
  double jitterX = 0, jitterY = 0;
  double _driftFromX = 0, _driftFromY = 0;
  double _driftToX = 0, _driftToY = 0;
  double driftStart;
  double driftInterval;

  _Bubble({
    required this.model,
    required this.positive,
    required this.x,
    required this.y,
    required this.radius,
    required this.driftStart,
    required this.driftInterval,
  });
}

/// Bumped once per physics tick; the canvas repaints via this instead of a
/// full widget rebuild on every frame.
class _Repainter extends ChangeNotifier {
  void tick() => notifyListeners();
}

class _EmotionBubbleChartState extends State<EmotionBubbleChart>
    with SingleTickerProviderStateMixin {
  static const double _canvasHeight = 460;

  late final Ticker _ticker;
  final _repaint = _Repainter();
  final _rand = Random();
  List<_Bubble> _bubbles = [];
  double? _lastWidth;
  double _elapsedSeconds = 0;
  double _entranceT = 0;
  String? _highlightKey;
  double _highlightT = 0;
  bool _positiveExpanded = false;
  bool _negativeExpanded = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant EmotionBubbleChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) {
      _lastWidth = null;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  double get _total {
    double s = 0;
    for (final e in widget.data) s += e.quantity;
    return s == 0 ? 1 : s;
  }

  bool _isPositive(EmotionModel e) =>
      emotionSpectrumMood(e.identity) != EmotionMood.negative;

  void _buildBubbles(double width) {
    final rand = Random(7);

    // Radius scaling has two independent caps, and takes the smaller one:
    // - Value-based: relative to the single largest emotion in its own zone
    //   (positive/negative), so a dominant emotion reads as dominant.
    // - Density-based: how big a circle can be while still letting every
    //   bubble in that zone fit into the zone's share of the canvas without
    //   wall-to-wall overlap. Without this second cap, a data set where many
    //   emotions tie for the max value (e.g. everything logged exactly once)
    //   made *every* bubble render at the same, oversized radius — there's
    //   no room for 20+ maximum-sized circles in a phone-width canvas.
    const userMinR = 20.0;
    const userMaxR = 78.0;
    const fillFactor = 0.5; // fraction of the zone's area bubbles may cover
    final zoneArea = width * (_canvasHeight * 0.5);

    final positive = widget.data.where(_isPositive).toList();
    final negative = widget.data.where((e) => !_isPositive(e)).toList();

    double zoneMax(List<EmotionModel> zone) {
      double m = 0;
      for (final e in zone) {
        if (e.quantity > m) m = e.quantity.toDouble();
      }
      return m == 0 ? 1 : m;
    }

    double densityCap(int count) {
      if (count == 0) return userMaxR;
      final areaPerBubble = zoneArea * fillFactor / count;
      return sqrt(areaPerBubble / pi).clamp(14.0, userMaxR);
    }

    List<_Bubble> buildZone(List<EmotionModel> zone, bool positive) {
      final maxValue = zoneMax(zone);
      final capR = densityCap(zone.length);
      final minR = min(userMinR, capR * 0.55);
      return [
        for (final e in zone)
          _Bubble(
            model: e,
            positive: positive,
            // A small random scatter around the center, not the exact same
            // point for every bubble — otherwise every pair starts at
            // distance zero, which makes the repulsion direction undefined
            // (0/0) and bubbles that spawn coincident never separate.
            x: width / 2 + (rand.nextDouble() - 0.5) * 60,
            y: _canvasHeight / 2 + (rand.nextDouble() - 0.5) * 60,
            radius: minR + (capR - minR) * sqrt((e.quantity / maxValue).clamp(0, 1)),
            // Staggered so bubbles don't all pick a new drift target on the
            // same frame — negative start = "already partway through an
            // interval" at t=0.
            driftStart: -rand.nextDouble() * 2.5,
            driftInterval: 2.0 + rand.nextDouble() * 1.5,
          ),
      ];
    }

    _bubbles = [...buildZone(positive, true), ...buildZone(negative, false)];
    _entranceT = 0;
    _lastWidth = width;
  }

  void _onTick(Duration elapsed) {
    final t = elapsed.inMicroseconds / 1e6;
    final dt = (_elapsedSeconds == 0 ? 0.016 : t - _elapsedSeconds).clamp(0.0, 0.05);
    _elapsedSeconds = t;

    if (_bubbles.isEmpty || _lastWidth == null) return;

    // Entrance: 1200ms, easeOutQuart (fast start, long gentle settle). The
    // painter reads this same eased value for both scale and fade-in.
    if (_entranceT < 1) {
      _entranceT = (_entranceT + dt / 1.2).clamp(0.0, 1.0);
    }
    final entranceEased = Curves.easeOutQuart.transform(_entranceT);

    final width = _lastWidth!;
    // Two firm poles (upper third / lower third) rather than a soft pull,
    // so the two moods separate into distinct clusters with visible air
    // between them instead of blending into one mass in the middle.
    final posY = _canvasHeight * 0.22;
    final negY = _canvasHeight * 0.78;
    final centerX = width / 2;

    final yGravity = 11.0 * entranceEased;
    final xGravity = 4.0 * entranceEased;

    for (final b in _bubbles) {
      final targetY = b.positive ? posY : negY;
      b.vx += (centerX - b.x) * xGravity * dt * 0.02;
      b.vy += (targetY - b.y) * yGravity * dt * 0.02;
    }

    // Several relaxation passes per tick: a single pass leaves visible
    // overlap when many circles are crowded into the same zone, since
    // resolving one pair's overlap can reintroduce overlap with a third
    // bubble. Multiple passes converge to a clean non-overlapping layout
    // within a couple of frames instead of oscillating indefinitely.
    for (int pass = 0; pass < 3; pass++) {
      for (int i = 0; i < _bubbles.length; i++) {
        for (int j = i + 1; j < _bubbles.length; j++) {
          final a = _bubbles[i];
          final b = _bubbles[j];
          final dx = b.x - a.x;
          final dy = b.y - a.y;
          final dist = sqrt(dx * dx + dy * dy) + 0.001;
          final minDist = (a.radius + b.radius) * 1.0;
          if (dist < minDist) {
            final overlap = minDist - dist;
            final nx = dx / dist;
            final ny = dy / dist;
            final push = overlap * 3.2;
            a.vx -= nx * push * dt;
            a.vy -= ny * push * dt;
            b.vx += nx * push * dt;
            b.vy += ny * push * dt;
          }
        }
      }
    }

    for (final b in _bubbles) {
      b.vx *= 0.8;
      b.vy *= 0.8;
      b.x += b.vx;
      b.y += b.vy;
      b.x = b.x.clamp(b.radius, max(b.radius, width - b.radius));
      b.y = b.y.clamp(b.radius, _canvasHeight - b.radius);

      // "Дыхание": drift toward a small random offset, holding it briefly
      // before picking a new one, instead of a continuous wave.
      final since = _elapsedSeconds - b.driftStart;
      if (since >= b.driftInterval) {
        b._driftFromX = b.jitterX;
        b._driftFromY = b.jitterY;
        b._driftToX = (_rand.nextDouble() - 0.5) * 6; // ±3px
        b._driftToY = (_rand.nextDouble() - 0.5) * 6;
        b.driftStart = _elapsedSeconds;
        b.driftInterval = 2.0 + _rand.nextDouble() * 1.5;
      } else {
        final driftT = Curves.easeInOutSine.transform((since / b.driftInterval).clamp(0.0, 1.0));
        b.jitterX = b._driftFromX + (b._driftToX - b._driftFromX) * driftT;
        b.jitterY = b._driftFromY + (b._driftToY - b._driftFromY) * driftT;
      }
    }

    if (_highlightKey != null) {
      _highlightT += dt;
      if (_highlightT > 1.0) {
        _highlightKey = null;
        _highlightT = 0;
      }
    }

    _repaint.tick();
  }

  void _highlight(String key) {
    setState(() {
      _highlightKey = key;
      _highlightT = 0;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    for (final b in _bubbles.reversed) {
      final dx = details.localPosition.dx - b.x;
      final dy = details.localPosition.dy - b.y;
      if (sqrt(dx * dx + dy * dy) <= b.radius) {
        _highlight(b.model.identity);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _total;
    final positiveList = widget.data.where(_isPositive).toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    final negativeList = widget.data.where((e) => !_isPositive(e)).toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));
    final positivePercent = positiveList.fold<double>(0, (s, e) => s + e.quantity) / total * 100;
    final negativePercent = negativeList.fold<double>(0, (s, e) => s + e.quantity) / total * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(builder: (context, constraints) {
          final width = constraints.maxWidth;
          if (_lastWidth != width) {
            _buildBubbles(width);
          }
          return GestureDetector(
            onTapUp: _handleTapUp,
            child: Container(
              height: _canvasHeight,
              width: width,
              // Faint warm-to-cool gradient behind the cloud: a quiet visual
              // cue that the top is the "light" zone and the bottom is the
              // "shadow" zone, even before any bubbles are read individually.
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFDF7),
                    Color(0xFFFFFDF7),
                    Color(0xFFF4F5F7),
                    Color(0xFFF4F5F7),
                  ],
                  stops: [0.0, 0.4, 0.6, 1.0],
                ),
              ),
              child: AnimatedBuilder(
                animation: _repaint,
                builder: (context, _) => CustomPaint(
                  painter: _BubblePainter(
                    bubbles: _bubbles,
                    entranceT: _entranceT,
                    elapsedSeconds: _elapsedSeconds,
                    highlightKey: _highlightKey,
                    highlightT: _highlightT,
                  ),
                  size: Size(width, _canvasHeight),
                ),
              ),
            ),
          );
        }),
        if (positiveList.isNotEmpty)
          _legendGroup(
            'positive_emotions'.tr(),
            positivePercent,
            positiveList,
            total,
            expanded: _positiveExpanded,
            onToggle: () => setState(() => _positiveExpanded = !_positiveExpanded),
          ),
        if (positiveList.isNotEmpty && negativeList.isNotEmpty)
          Padding(
            padding: getPadding(left: 16, right: 16, top: 8),
            child: Divider(color: ColorConstant.gray50, height: getVerticalSize(1)),
          ),
        if (negativeList.isNotEmpty)
          _legendGroup(
            'negative_emotions'.tr(),
            negativePercent,
            negativeList,
            total,
            expanded: _negativeExpanded,
            onToggle: () => setState(() => _negativeExpanded = !_negativeExpanded),
          ),
        SizedBox(height: getVerticalSize(20)),
      ],
    );
  }

  Widget _legendGroup(
    String title,
    double percent,
    List<EmotionModel> list,
    double total, {
    required bool expanded,
    required VoidCallback onToggle,
  }) {
    return Padding(
      padding: getPadding(left: 16, right: 16, top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsible: a long list of 1-2%-each emotions otherwise forces
          // a lot of scrolling just to see the other group or get back to
          // the cloud.
          InkWell(
            onTap: onToggle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title (${percent.toInt()}%)',
                  style: AppStyle.txtSFProDisplayLight14Gray800.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: getFontSize(16),
                  ),
                ),
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down, color: ColorConstant.gray800),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: !expanded
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: getVerticalSize(12)),
                      ...list.map((e) => GestureDetector(
                onTap: () => _highlight(e.identity),
                child: Padding(
                  padding: getPadding(bottom: 14),
                  child: Row(
                    children: [
                      Container(
                        width: getSize(16),
                        height: getSize(16),
                        decoration: BoxDecoration(color: e.color, shape: BoxShape.circle),
                      ),
                      SizedBox(width: getHorizontalSize(10)),
                      Expanded(
                        child: Text(
                          e.name,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.txtSFProDisplayLight10Gray800.copyWith(fontSize: getFontSize(15)),
                        ),
                      ),
                      Text(
                        '${(e.quantity / total * 100).toInt()}%',
                        style: AppStyle.txtSFProDisplayLight10Gray800.copyWith(
                          fontSize: getFontSize(15),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<_Bubble> bubbles;
  final double entranceT;
  final double elapsedSeconds;
  final String? highlightKey;
  final double highlightT;

  _BubblePainter({
    required this.bubbles,
    required this.entranceT,
    required this.elapsedSeconds,
    required this.highlightKey,
    required this.highlightT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Entrance: easeOutQuart drives both scale (0->1) and fade-in (0->1),
    // per spec — fast start, long gentle settle.
    final entranceEased = Curves.easeOutQuart.transform(entranceT.clamp(0.0, 1.0));

    for (final b in bubbles) {
      double scale = entranceEased;
      double opacity = entranceEased;
      if (highlightKey != null) {
        if (b.model.identity == highlightKey) {
          scale *= 1.0 + sin((highlightT).clamp(0.0, 1.0) * pi) * 0.15;
        } else {
          opacity *= 0.5;
        }
      }

      final cx = b.x + b.jitterX;
      final cy = b.y + b.jitterY;
      final r = b.radius * scale;
      if (r <= 0) continue;

      canvas.drawCircle(Offset(cx, cy), r, Paint()..color = b.model.color.withOpacity(opacity));

      // Density-capped radii can end up quite small when a zone has many
      // emotions — a >22 cutoff silently dropped the label on most of them.
      // Draw down to much smaller bubbles too, just with a tiny clamped
      // font (with ellipsis) rather than skipping the label outright.
      if (r > 11) {
        final textColor =
            b.model.color.computeLuminance() < 0.5 ? Colors.white : const Color(0xFF1F1F1F);
        final tp = TextPainter(
          text: TextSpan(
            text: b.model.name,
            style: TextStyle(
              color: textColor.withOpacity(opacity),
              fontSize: (r * 0.34).clamp(7, 15),
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: ui.TextDirection.ltr,
          maxLines: 2,
          ellipsis: '…',
        );
        tp.layout(maxWidth: r * 1.8);
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}
