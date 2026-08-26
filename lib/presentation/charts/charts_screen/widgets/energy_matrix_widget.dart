import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/app_export.dart';
import '../../../../core/services/dashboards/energy_matrix_service.dart';
import '../../../../theme/app_colors.dart';
import '../../../../widgets/ambient_bloom_card.dart';
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
  static const double _canvasSize = 340;

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
    return Offset(
      (jx + 5) / 10 * _canvasSize,
      (5 - jy) / 10 * _canvasSize, // flip: +Y (high energy) is drawn upward
    );
  }

  double _onScreenDiameter(int frequency) {
    final maxFreq = widget.points.map((e) => e.frequency).reduce(max);
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
    final quadrant = _quadrantKey(p.x, p.y);
    final variant = Random().nextInt(3) + 1;
    final text = 'energy_matrix_${quadrant}_$variant'.tr(namedArgs: {'tag': p.tagLabel});
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _InsightSheet(tagLabel: p.tagLabel, frequency: p.frequency, text: text),
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
          Text(
            'energy_matrix'.tr(),
            overflow: TextOverflow.ellipsis,
            style: AppStyle.txtSFProDisplayLight14Gray800,
          ),
          SizedBox(height: getVerticalSize(6)),
          Text(
            'energy_matrix_intro'.tr(),
            style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
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
            AspectRatio(aspectRatio: 1, child: _buildQuadrant()),
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
              width: _canvasSize,
              height: _canvasSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CustomPaint(size: const Size(_canvasSize, _canvasSize), painter: _QuadrantBackgroundPainter()),
                  for (final p in widget.points) _buildBubble(p),
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
    final center = _canvasPosition(p);
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
      child: GestureDetector(
        onTap: () => _onBubbleTap(p),
        onDoubleTap: _resetZoom,
        child: AnimatedBuilder(
          animation: _breath,
          builder: (context, child) {
            final t = Curves.easeInOut.transform(_breath.value);
            return Transform.scale(scale: 1 + t * 0.02, child: child);
          },
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Glass-sphere gradient: a lighter highlight near the top-left,
              // deepening into the full jewel-tone color — reads as a
              // translucent bead of glass rather than a flat painted disc.
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.4),
                radius: 1.1,
                colors: [
                  Color.lerp(color, Colors.white, 0.55)!.withOpacity(0.9),
                  color.withOpacity(0.88),
                  Color.lerp(color, Colors.black, 0.15)!.withOpacity(0.92),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              border: Border.all(color: Colors.white.withOpacity(0.55), width: 1 / _scale),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 14 / _scale,
                  spreadRadius: 0.5 / _scale,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: canvasDiameter * _scale > 34
                ? Padding(
                    padding: const EdgeInsets.all(2),
                    child: Text(
                      p.tagLabel,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: (11 / _scale).clamp(7, 13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
          ),
        ),
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
    final mid = size.width / 2;
    final zones = <Rect, Color>{
      Rect.fromLTWH(mid, 0, mid, mid): AppColors.chartAqua.withOpacity(0.08), // Драйв
      Rect.fromLTWH(mid, mid, mid, mid): AppColors.chartTeal.withOpacity(0.08), // Ресурс
      Rect.fromLTWH(0, 0, mid, mid): AppColors.chartStress.withOpacity(0.08), // Стресс
      Rect.fromLTWH(0, mid, mid, mid): AppColors.chartPurple.withOpacity(0.08), // Истощение
    };
    zones.forEach((rect, color) => canvas.drawRect(rect, Paint()..color = color));
    final axisPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.12)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(mid, 0), Offset(mid, size.height), axisPaint);
    canvas.drawLine(Offset(0, mid), Offset(size.width, mid), axisPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InsightSheet extends StatelessWidget {
  final String tagLabel;
  final int frequency;
  final String text;

  const _InsightSheet({Key? key, required this.tagLabel, required this.frequency, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // The sheet's own fixed bottom padding wasn't enough to clear a
      // gesture-nav bar on some devices, so the last line rendered right
      // at (or behind) the system inset — SafeArea adds whatever extra
      // padding that device actually needs.
      child: Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Text(tagLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'energy_matrix_frequency'.tr(namedArgs: {'count': '$frequency'}),
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 12),
          Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
        ],
      ),
      ),
    );
  }
}
