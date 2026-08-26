import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/services/dashboards/energy_matrix_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/ambient_bloom_card.dart';
import '../../../../widgets/dashboard_detail_sheet.dart';
import '../../../../widgets/dashboard_insight_card.dart';

/// "Матрица Энергии" — quadrant scatter of context tags (who/what/where),
/// positioned by average valence (X) and average arousal (Y). Bubbles are
/// plain positioned widgets inside a zoomable/pannable canvas rather than
/// one CustomPainter doing its own hit-testing — that way tap targets and
/// InteractiveViewer's transform stay in sync for free, no manual inverse-
/// matrix math needed.
class EnergyMatrixWidget extends StatefulWidget {
  final List<EnergyMatrixPoint> points;

  const EnergyMatrixWidget({Key? key, required this.points}) : super(key: key);

  @override
  State<EnergyMatrixWidget> createState() => _EnergyMatrixWidgetState();
}

class _EnergyMatrixWidgetState extends State<EnergyMatrixWidget> with SingleTickerProviderStateMixin {
  static const double _canvasWidth = 340;
  // Taller than wide, per request — a plain square felt cramped once real
  // data spread bubbles toward the quadrant corners.
  static const double _canvasHeight = _canvasWidth * 1.3;
  // Points map into the middle band of the canvas, not edge-to-edge — a
  // point at the extreme ±5 still needs its full bubble radius inside the
  // canvas, or it gets clipped by the card's rounded border. This margin
  // is sized for the largest bubble (see _onScreenDiameter's max diameter).
  static const double _canvasMargin = 42;

  final _transformController = TransformationController();
  double _scale = 1.0;
  bool _darkened = false;

  // Slow shared "breathing" pulse for every bubble — a single controller
  // driving all of them stays in sync and costs one ticker, not N.
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _transformController.dispose();
    _breath.dispose();
    super.dispose();
  }

  // Deterministic per-tag jitter (seeded by the tag's own name) so bubbles
  // that land on the same coordinate spread into a readable little cluster
  // instead of fully overlapping — same offset every rebuild, not reshuffled
  // on every frame.
  double _jitter(String key, {required bool isX}) {
    final rnd = Random(key.hashCode + (isX ? 0 : 1000003));
    return (rnd.nextDouble() - 0.5) * 0.6;
  }

  Offset _canvasPosition(EnergyMatrixPoint p) {
    final jx = (p.x + _jitter(p.tagLabel, isX: true)).clamp(-5.0, 5.0);
    final jy = (p.y + _jitter(p.tagLabel, isX: false)).clamp(-5.0, 5.0);
    final usableWidth = _canvasWidth - _canvasMargin * 2;
    final usableHeight = _canvasHeight - _canvasMargin * 2;
    return Offset(
      _canvasMargin + (jx + 5) / 10 * usableWidth,
      // flip: +Y (high energy) is drawn upward
      _canvasMargin + (5 - jy) / 10 * usableHeight,
    );
  }

  // Above this many tags a quadrant turns into an overlapping blob that's
  // both unreadable and hard to tap accurately — so each quadrant shows at
  // most this many individual bubbles (already the most frequent ones,
  // since the service hands points back sorted by frequency) and folds
  // everything past that into one "Other" bubble, same pattern used
  // elsewhere in the app for long tag lists.
  static const int _maxPerQuadrant = 4;

  List<EnergyMatrixPoint>? _visibleCache;
  List<EnergyMatrixPoint>? _visibleCacheFor;

  List<EnergyMatrixPoint> get _visiblePoints {
    // widget.points is a new list on every parent rebuild even when the
    // underlying data hasn't changed, so cache by identity of that list
    // rather than recomputing (and re-seeding "Other"'s position) every
    // single frame the breathing animation ticks.
    if (identical(_visibleCacheFor, widget.points) && _visibleCache != null) {
      return _visibleCache!;
    }
    final byQuadrant = <String, List<EnergyMatrixPoint>>{};
    for (final p in widget.points) {
      (byQuadrant[_quadrantKey(p.x, p.y)] ??= []).add(p);
    }
    final result = <EnergyMatrixPoint>[];
    byQuadrant.forEach((quadrant, list) {
      // Already sorted by frequency desc (EnergyMatrixService.compute).
      result.addAll(list.take(_maxPerQuadrant));
      final rest = list.skip(_maxPerQuadrant).toList();
      if (rest.isNotEmpty) {
        final totalFreq = rest.fold<int>(0, (sum, p) => sum + p.frequency);
        final wx = rest.fold<double>(0, (sum, p) => sum + p.x * p.frequency) / totalFreq;
        final wy = rest.fold<double>(0, (sum, p) => sum + p.y * p.frequency) / totalFreq;
        result.add(EnergyMatrixPoint(
          tagLabel: 'energy_matrix_other'.tr(),
          x: wx,
          y: wy,
          frequency: totalFreq,
          groupedTags: rest.map((p) => p.tagLabel).toList(),
        ));
      }
    });
    _visibleCache = result;
    _visibleCacheFor = widget.points;
    return result;
  }

  // Same string used for a bubble's Positioned.key and its slot in the
  // resolved-position map — keeps the two lookups from drifting apart.
  String _pointKey(EnergyMatrixPoint p) => '${p.tagLabel}_${p.x.toStringAsFixed(2)}_${p.y.toStringAsFixed(2)}';

  Map<String, Offset>? _positionsCache;
  List<EnergyMatrixPoint>? _positionsCacheFor;

  // Raw jittered positions can still land two bubbles closer together than
  // half their combined radius (real "> 50% overlap"). This relaxes those
  // pairs apart with small symmetric nudges — a handful of iterations is
  // enough since each quadrant holds at most _maxPerQuadrant + 1 bubbles.
  Map<String, Offset> _resolvedPositions() {
    final points = _visiblePoints;
    if (identical(_positionsCacheFor, points) && _positionsCache != null) {
      return _positionsCache!;
    }
    final positions = <String, Offset>{};
    final radii = <String, double>{};
    for (final p in points) {
      final key = _pointKey(p);
      positions[key] = _canvasPosition(p);
      radii[key] = _onScreenDiameter(p.frequency) / 2;
    }
    final keys = positions.keys.toList();
    for (var iter = 0; iter < 60; iter++) {
      var moved = false;
      for (var i = 0; i < keys.length; i++) {
        for (var j = i + 1; j < keys.length; j++) {
          final ki = keys[i];
          final kj = keys[j];
          final pi = positions[ki]!;
          final pj = positions[kj]!;
          final delta = pj - pi;
          final dist = delta.distance;
          final minDist = (radii[ki]! + radii[kj]!) * 0.5;
          if (dist < minDist) {
            moved = true;
            final safeDist = dist < 0.01 ? 0.01 : dist;
            final dir = dist < 0.01 ? const Offset(1, 0) : delta / safeDist;
            final push = (minDist - safeDist) / 2;
            positions[ki] = pi - dir * push;
            positions[kj] = pj + dir * push;
          }
        }
      }
      if (!moved) break;
    }
    // Relaxation can walk a bubble's center past the margin — pull every
    // full circle back inside the canvas as a final pass.
    for (final key in keys) {
      final r = radii[key]!;
      final p = positions[key]!;
      positions[key] = Offset(
        p.dx.clamp(r, _canvasWidth - r).toDouble(),
        p.dy.clamp(r, _canvasHeight - r).toDouble(),
      );
    }
    _positionsCache = positions;
    _positionsCacheFor = points;
    return positions;
  }

  double _onScreenDiameter(int frequency) {
    final maxFreq = _visiblePoints.map((e) => e.frequency).reduce(max);
    final t = frequency / maxFreq;
    return 34 + sqrt(t) * 48;
  }

  Color _quadrantColor(double x, double y) {
    if (x >= 0 && y >= 0) return AppColors.chartAqua; // Драйв
    if (x >= 0 && y < 0) return AppColors.chartTeal; // Ресурс
    if (x < 0 && y >= 0) return AppColors.chartStress; // Стресс
    return AppColors.chartPurple; // Истощение
  }

  String _quadrantKey(double x, double y) {
    if (x >= 0 && y >= 0) return 'drive';
    if (x >= 0 && y < 0) return 'resource';
    if (x < 0 && y >= 0) return 'stress';
    return 'burnout';
  }

  void _resetZoom() {
    _transformController.value = Matrix4.identity();
    setState(() => _scale = 1.0);
  }

  Future<void> _onBubbleTap(EnergyMatrixPoint p) async {
    setState(() => _darkened = true);
    // Same reasoning as the main-screen save flow: a bottom sheet's modal
    // barrier appears almost instantly, so give the darken animation a beat
    // to actually be visible before it does.
    await Future.delayed(const Duration(milliseconds: 120));
    if (!mounted) return;
    final text = p.isGroup
        ? 'energy_matrix_other_body'.tr(namedArgs: {'tags': p.groupedTags!.join(', ')})
        : 'energy_matrix_${_quadrantKey(p.x, p.y)}_${Random().nextInt(3) + 1}'.tr(namedArgs: {'tag': p.tagLabel});
    await DashboardDetailSheet.show(
      context,
      title: p.tagLabel,
      subtitle: 'energy_matrix_frequency'.tr(namedArgs: {'count': '${p.frequency}'}),
      body: text,
    );
    if (mounted) setState(() => _darkened = false);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      child: AmbientBloomCard(
      padding: const EdgeInsets.fromLTRB(12, 21, 12, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'energy_matrix'.tr(),
                overflow: TextOverflow.ellipsis,
                style: AppStyle.txtSFProDisplayLight14Gray800,
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => DashboardDetailSheet.show(
                  context,
                  title: 'energy_matrix'.tr(),
                  body: 'energy_matrix_intro'.tr(),
                ),
                child: Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary.withOpacity(0.7)),
              ),
            ],
          ),
          SizedBox(height: getVerticalSize(16)),
          if (widget.points.isEmpty)
            Padding(
              padding: getPadding(top: 24, bottom: 24),
              child: Text(
                'energy_matrix_empty'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.txtSFProDisplayLight14,
              ),
            )
          else ...[
            AspectRatio(aspectRatio: _canvasWidth / _canvasHeight, child: _buildQuadrant()),
            SizedBox(height: getVerticalSize(20)),
            _buildInsight(),
          ],
        ],
      ),
      ),
    );
  }

  Widget _buildInsight() {
    final insight = EnergyMatrixService.pickTopVampireAndDonor(widget.points);
    if (insight == null) {
      return Text('insight_matrix_no_contrast'.tr(), style: AppStyle.txtSFProDisplayLight14);
    }
    final vampire = insight.vampire.tagLabel;
    final donor = insight.donor.tagLabel;
    final variant = (vampire + donor).hashCode.abs() % 2 + 1;
    return DashboardInsightCard(
      signature: 'matrix_${vampire}_$donor',
      summaryText: 'insight_matrix_summary_$variant'.tr(namedArgs: {'vampire': vampire, 'donor': donor}),
      highlights: [vampire, donor],
      nudgeText: 'insight_matrix_nudge_$variant'.tr(namedArgs: {'vampire': vampire, 'donor': donor}),
      theoryTitle: 'insight_matrix_theory_title'.tr(),
      theoryBody: 'insight_matrix_theory_body'.tr(),
    );
  }

  Widget _buildQuadrant() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: 1.0,
            maxScale: 4.0,
            boundaryMargin: const EdgeInsets.all(80),
            onInteractionEnd: (_) =>
                setState(() => _scale = _transformController.value.getMaxScaleOnAxis()),
            child: SizedBox(
              width: _canvasWidth,
              height: _canvasHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(size: const Size(_canvasWidth, _canvasHeight), painter: _QuadrantBackgroundPainter()),
                  for (final p in _visiblePoints) _buildBubble(p),
                ],
              ),
            ),
          ),
        ),
        IgnorePointer(child: _buildAxisOverlay()),
        Positioned(
          right: 8,
          bottom: 8,
          child: GestureDetector(
            onTap: _resetZoom,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), shape: BoxShape.circle),
              child: const Icon(Icons.center_focus_strong, size: 18, color: Colors.black54),
            ),
          ),
        ),
        if (_darkened)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.black.withOpacity(0.35)),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBubble(EnergyMatrixPoint p) {
    final center = _resolvedPositions()[_pointKey(p)]!;
    // On-screen diameter is kept roughly constant regardless of zoom level
    // ("semantic zoom") by shrinking the canvas-space diameter as scale
    // grows — canvasDiameter * scale ≈ onScreenDiameter always.
    final onScreenDiameter = _onScreenDiameter(p.frequency);
    final canvasDiameter = onScreenDiameter / _scale;
    final color = _quadrantColor(p.x, p.y);
    return Positioned(
      left: center.dx - canvasDiameter / 2,
      top: center.dy - canvasDiameter / 2,
      width: canvasDiameter,
      height: canvasDiameter,
      child: _EnergyBubble(
        // "Other" bubbles across different quadrants share the same
        // tagLabel, so key on position too — otherwise Flutter sees
        // duplicate keys among Stack siblings.
        key: ValueKey(_pointKey(p)),
        label: p.tagLabel,
        diameter: canvasDiameter,
        scale: _scale,
        color: color,
        breath: _breath,
        onTap: () => _onBubbleTap(p),
        onDoubleTap: _resetZoom,
      ),
    );
  }

  Widget _buildAxisOverlay() {
    return Stack(
      children: [
        Positioned(top: 4, left: 0, right: 0, child: Center(child: _axisLabel('energy_matrix_y_positive'.tr()))),
        Positioned(bottom: 4, left: 0, right: 0, child: Center(child: _axisLabel('energy_matrix_y_negative'.tr()))),
        Positioned(
          left: 4,
          top: 0,
          bottom: 0,
          child: Center(child: RotatedBox(quarterTurns: 3, child: _axisLabel('energy_matrix_x_negative'.tr()))),
        ),
        Positioned(
          right: 4,
          top: 0,
          bottom: 0,
          child: Center(child: RotatedBox(quarterTurns: 1, child: _axisLabel('energy_matrix_x_positive'.tr()))),
        ),
      ],
    );
  }

  // Hairline instead of a solid white plaque — a thin muted rule with the
  // label floating just above it, so the axis reads as a quiet structural
  // cue rather than a boxed UI chip competing with the bubbles.
  Widget _axisLabel(String text) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 3),
            Container(width: 18, height: 1, color: AppColors.textSecondary.withOpacity(0.35)),
          ],
        ),
      );
}

class _QuadrantBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final midX = size.width / 2;
    final midY = size.height / 2;
    final zones = <Rect, Color>{
      Rect.fromLTWH(midX, 0, midX, midY): AppColors.chartAqua.withOpacity(0.08), // Драйв
      Rect.fromLTWH(midX, midY, midX, midY): AppColors.chartTeal.withOpacity(0.08), // Ресурс
      Rect.fromLTWH(0, 0, midX, midY): AppColors.chartStress.withOpacity(0.08), // Стресс
      Rect.fromLTWH(0, midY, midX, midY): AppColors.chartPurple.withOpacity(0.08), // Истощение
    };
    zones.forEach((rect, color) => canvas.drawRect(rect, Paint()..color = color));
    final axisPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(midX, 0), Offset(midX, size.height), axisPaint);
    canvas.drawLine(Offset(0, midY), Offset(size.width, midY), axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// One bubble, in charge of its own "pressed" look — tapping down brightens
/// and lifts it immediately, so it's unambiguous which bubble a finger
/// actually landed on before the detail sheet even opens.
class _EnergyBubble extends StatefulWidget {
  final String label;
  final double diameter;
  final double scale;
  final Color color;
  final Animation<double> breath;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;

  const _EnergyBubble({
    Key? key,
    required this.label,
    required this.diameter,
    required this.scale,
    required this.color,
    required this.breath,
    required this.onTap,
    required this.onDoubleTap,
  }) : super(key: key);

  @override
  State<_EnergyBubble> createState() => _EnergyBubbleState();
}

class _EnergyBubbleState extends State<_EnergyBubble> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.scale;
    final color = widget.color;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: AnimatedBuilder(
        animation: widget.breath,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(widget.breath.value);
          final pressed = _pressed ? -0.08 : 0.0;
          return Transform.scale(scale: 1 + t * 0.02 + pressed, child: child);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Glass-sphere gradient: a lighter highlight near the top-left,
            // deepening into the full jewel-tone color — reads as a
            // translucent bead of glass rather than a flat painted disc.
            // Pressed state pushes the highlight brighter and wider, like
            // the bead catching more light under a finger.
            gradient: RadialGradient(
              center: const Alignment(-0.35, -0.4),
              radius: 1.1,
              colors: [
                Color.lerp(color, Colors.white, _pressed ? 0.75 : 0.55)!.withOpacity(0.92),
                color.withOpacity(0.88),
                Color.lerp(color, Colors.black, 0.15)!.withOpacity(0.92),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(_pressed ? 0.9 : 0.55),
              width: (_pressed ? 2 : 1) / scale,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(_pressed ? 0.55 : 0.4),
                blurRadius: (_pressed ? 20 : 14) / scale,
                spreadRadius: (_pressed ? 1.2 : 0.5) / scale,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: widget.diameter * scale > 34
              ? Padding(
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    widget.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (11 / scale).clamp(7, 13),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
