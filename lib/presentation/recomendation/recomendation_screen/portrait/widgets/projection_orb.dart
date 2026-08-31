import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

import '../../../../../core/services/identity/local_identity_service.dart';

// "Проекция Я" — the visualization at the top of the module: a shared
// cinematic nebula video (same asset for every user) with a personal star
// layer on top, seeded from the user's own local id — different, stable
// (not re-randomized per session) star pattern/sizes/colors per person, so
// the shared backdrop still reads as "their own sky". Full-bleed (no side
// padding at the call site, no card/frame).
//
// The video itself swaps at phase boundaries (matches the module's
// existing paywall boundary at kPortraitFreeTestCount = 6 numbered tests)
// — add later phases here as their videos are produced. Each of the 12
// tests instead gets its own visible change via the star layer's group
// unlock (see the shader) — not this video swap, which only happens once
// or twice across the whole 12-test arc.
// Each test plays its own whole, complete clip (never a cut piece of one
// clip — an earlier version sliced a single render into two files to
// stage tests 7 vs 8-9, but the cut point read as an ugly edit seam
// on-device). The "phase3_planets" clip is actually test 9's own video
// (still part of the shadow phase, not a separate integration phase) —
// filename is a holdover from an initial guess, kept as-is to avoid
// churn. "Интеграция" (tests 10-12): planets at test 10, galaxies at 11,
// a second galaxies clip for test 12 (the last numbered test).
String _videoAssetFor(double progress) {
  if (progress >= 12) return 'assets/videos/projection/phase4c_finale.mp4'; // test 12
  if (progress >= 11) return 'assets/videos/projection/phase4b_galaxies.mp4'; // test 11
  if (progress >= 10) return 'assets/videos/projection/phase4_integration.mp4'; // test 10
  if (progress >= 9) return 'assets/videos/projection/phase3_planets.mp4'; // test 9
  if (progress >= 8) return 'assets/videos/projection/phase2b_veins.mp4';
  if (progress >= 7) return 'assets/videos/projection/phase2_veins.mp4';
  return 'assets/videos/projection/phase1_core.mp4';
}

// The slow "closer approach" is specific to the shadow-vein phase's own
// narrative (tests 8-9) — phase 3 (planets, tests 10+) is a new chapter
// and plays at its natural speed, not inheriting the slowdown.
double _playbackSpeedFor(double progress) => (progress >= 8 && progress < 10) ? 0.6 : 1.0;

// Finale-only: replays the whole 0-12 journey once, automatically, so the
// "Сборка портрета" screen shows the arc from near-darkness through every
// phase to the final richest state, instead of just landing on it. Reuses
// ProjectionOrb entirely — same star/orbit/core layers animate perfectly
// smoothly through the ramp; only the video layer underneath necessarily
// reloads at each phase boundary (a real async asset load), which may
// show as brief blips at the ~6 phase transitions during the recap.
class ProjectionOrbReplay extends StatefulWidget {
  final double height;

  const ProjectionOrbReplay({Key? key, this.height = 300}) : super(key: key);

  @override
  State<ProjectionOrbReplay> createState() => _ProjectionOrbReplayState();
}

class _ProjectionOrbReplayState extends State<ProjectionOrbReplay> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 14))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => ProjectionOrb(progress: _controller.value * 12, height: widget.height),
    );
  }
}

class ProjectionOrb extends StatefulWidget {
  final double progress;
  final double height;

  const ProjectionOrb({Key? key, required this.progress, this.height = 300}) : super(key: key);

  @override
  State<ProjectionOrb> createState() => _ProjectionOrbState();
}

class _ProjectionOrbState extends State<ProjectionOrb> with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  VideoPlayerController? _videoController;
  String? _videoAsset;
  bool _videoReady = false;
  double _seed = 0;
  late final Ticker _ticker;
  double _seconds = 0;

  @override
  void initState() {
    super.initState();

    ui.FragmentProgram.fromAsset('shaders/projection_orb.frag').then((program) {
      if (mounted) setState(() => _shader = program.fragmentShader());
    });

    _loadVideo(_videoAssetFor(widget.progress));

    LocalIdentityService.ensureLocalId().then((id) {
      if (mounted) setState(() => _seed = (id.hashCode & 0x7FFFFFFF) / 0x7FFFFFFF);
    });

    _ticker = createTicker((elapsed) {
      setState(() => _seconds = elapsed.inMicroseconds / 1e6);
    })..start();
  }

  void _loadVideo(String asset) {
    _videoAsset = asset;
    _videoReady = false;
    final controller = VideoPlayerController.asset(asset)
      ..setLooping(true)
      ..setVolume(0);
    _videoController = controller;
    controller.initialize().then((_) {
      if (!mounted || _videoController != controller) return;
      setState(() => _videoReady = true);
      _syncPlayback();
    });
  }

  // Test 1 is a static frame (video paused at 0:00), test 2 is where the
  // video starts actually moving — a deliberate staged reveal, not just
  // "video always autoplays".
  void _syncPlayback() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;
    controller.setPlaybackSpeed(_playbackSpeedFor(widget.progress));
    if (widget.progress >= 2) {
      controller.play();
    } else {
      controller.pause();
      controller.seekTo(Duration.zero);
    }
  }

  @override
  void didUpdateWidget(covariant ProjectionOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextAsset = _videoAssetFor(widget.progress);
    if (nextAsset != _videoAsset) {
      final old = _videoController;
      setState(() => _loadVideo(nextAsset));
      old?.dispose();
    } else if (widget.progress != oldWidget.progress) {
      _syncPlayback();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final controller = _videoController;
    return SizedBox(
      width: width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_videoReady && controller != null)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            )
          else
            const ColoredBox(color: Color(0xFF0B1917)),
          CustomPaint(
            size: Size(width, widget.height),
            painter: _OrbitsPainter(time: _seconds, progress: widget.progress),
          ),
          if (_shader != null)
            CustomPaint(
              size: Size(width, widget.height),
              painter: _StarsPainter(
                shader: _shader!,
                time: _seconds,
                seed: _seed,
                progress: widget.progress,
              ),
            ),
          if (widget.progress >= 3)
            CustomPaint(
              size: Size(width, widget.height),
              painter: _ShootingStarsPainter(time: _seconds, seed: _seed),
            ),
        ],
      ),
    );
  }
}

class _StarsPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;
  final double seed;
  final double progress;

  _StarsPainter({
    required this.shader,
    required this.time,
    required this.seed,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time)
      ..setFloat(3, seed)
      ..setFloat(4, progress);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.seed != seed || oldDelegate.progress != progress;
}

class _RingSpec {
  final double radiusFactor; // of shortest side / 2
  final double squashY; // ellipse flattening — approximates a tilted plane
  final double baseAngle;
  final double rotSpeed; // radians/sec
  final Color color;

  const _RingSpec(this.radiusFactor, this.squashY, this.baseAngle, this.rotSpeed, this.color);
}

// Thin orbit rings — tests 4-6 ("Анализ паттернов"): the psychological
// register shifts from feeling to structure/thinking, so a ring starts
// orbiting the core. One ring per test (4/5/6), each in its own plane
// (different squash + tilt) and its own slow independent speed. Colors
// pulled from the same white/gold/violet family as the star layer (not a
// separate silver/sapphire palette) so the rings read as part of the same
// visual language instead of a foreign graphic element, and each ring's
// hue is distinct enough from the other two that a new one is unmistakably
// its own thing, not a near-duplicate of the last.
const List<_RingSpec> _kRingSpecs = [
  _RingSpec(0.58, 0.26, 0.35, 0.055, Color(0xFFE8C878)), // gold, tight tilt
  _RingSpec(0.74, 0.55, -0.9, -0.04, Color(0xFFB08CF0)), // violet, wide/open tilt
  _RingSpec(0.66, 0.15, 1.35, 0.032, Color(0xFFF3F1EA)), // near-white, near edge-on
];

class _OrbitsPainter extends CustomPainter {
  final double time;
  final double progress;

  _OrbitsPainter({required this.time, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    _drawCore(canvas, center, size.shortestSide);

    final ringCount = progress >= 6
        ? 3
        : progress >= 5
            ? 2
            : progress >= 4
                ? 1
                : 0;
    if (ringCount == 0) return;

    for (var i = 0; i < ringCount; i++) {
      final spec = _kRingSpecs[i];
      final isNewest = i == ringCount - 1;

      // Each ring breathes (grows/shrinks) on its own slow cycle, offset
      // from the other rings and from the core's own breath, so they never
      // pulse in lockstep — same principle as their independent rotation
      // speeds. ~7-11s per ring, per feedback ("орбиты пусть тоже
      // увеличиваются и светятся").
      final ringBreathe = 0.5 + 0.5 * math.sin(time * (2 * math.pi / (7.0 + i * 2)) + i * 2.1);
      final r = size.shortestSide / 2 * spec.radiusFactor * (0.94 + 0.12 * ringBreathe);
      final rect = Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 2 * spec.squashY);

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(spec.baseAngle + time * spec.rotSpeed);

      // Wide, blurred glow pass underneath, then a thin near-sharp pass on
      // top — the same bloom trick used for the stars, so a ring reads as
      // luminous rather than a flat vector line laid over the video.
      // Brighter overall, and glow intensity breathes too, per feedback
      // ("орбиты тоже сияли ярко" / "увеличиваются и светятся").
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = (isNewest ? 15 : 12) * (0.85 + 0.3 * ringBreathe)
        ..color = spec.color.withOpacity(((isNewest ? 0.55 : 0.34) * (0.7 + 0.5 * ringBreathe)).clamp(0.0, 1.0))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawOval(rect, glowPaint);

      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isNewest ? 1.8 : 1.4
        ..color = spec.color.withOpacity(isNewest ? 1.0 : 0.75)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);
      canvas.drawOval(rect, linePaint);

      canvas.restore();
    }
  }

  // The color sequence the core shimmers through — gold, turquoise,
  // violet, light blue, blue, white — cycling slowly and continuously
  // (not tied to progress; every phase gets the full shimmer).
  static const List<Color> _coreColors = [
    Color(0xFFF0C878), // gold
    Color(0xFF6FE3D6), // turquoise
    Color(0xFFB08CF0), // violet
    Color(0xFF7FC7F0), // light blue
    Color(0xFF4A6FE0), // blue
    Color(0xFFFFFFFF), // white
  ];

  Color _shimmerColor(double t) {
    const secondsPerColor = 4.0;
    final n = _coreColors.length;
    final pos = (t / secondsPerColor) % n;
    final i = pos.floor();
    final frac = pos - i;
    return Color.lerp(_coreColors[i], _coreColors[(i + 1) % n], frac)!;
  }

  // Soft, breathing point of light at the center — present from test 1
  // onward, before any rings exist, so the rings have something to
  // visibly wrap around instead of orbiting empty space. Slow ~9s breath,
  // independent of the rings' own rotation speeds. Bigger and shimmering
  // through a slow color cycle per feedback ("увеличилась и каждый раз
  // разным цветом мигала, переливалась").
  void _drawCore(Canvas canvas, Offset center, double shortestSide) {
    final breathe = 0.5 + 0.5 * math.sin(time * (2 * math.pi / 9.0));
    final radius = shortestSide * (0.062 + 0.028 * breathe);
    final shimmer = _shimmerColor(time);

    final outerGlow = Paint()
      ..color = shimmer.withOpacity(0.18 + 0.28 * breathe)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius * 3.2, outerGlow);

    final midGlow = Paint()
      ..color = shimmer.withOpacity(0.38 + 0.38 * breathe)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 13);
    canvas.drawCircle(center, radius * 1.6, midGlow);

    final hot = Paint()..color = Color.lerp(shimmer, Colors.white, 0.7)!.withOpacity(0.95);
    canvas.drawCircle(center, radius * 0.55, hot);
  }

  @override
  bool shouldRepaint(covariant _OrbitsPainter oldDelegate) =>
      oldDelegate.time != time || oldDelegate.progress != progress;
}

// Occasional shooting stars — two independent slots, each on its own
// period so they never feel synchronized, seeded per-user like the star
// field so the exact timing/paths are "their own sky" too. Present from
// test 3 onward, alongside the first big star reveal.
class _ShootingStarsPainter extends CustomPainter {
  final double time;
  final double seed;

  _ShootingStarsPainter({required this.time, required this.seed});

  double _hash(double x) {
    final v = math.sin(x * 12.9898) * 43758.5453;
    return v - v.floorToDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawShootingStar(canvas, size, slotSeed: seed * 13.1 + 1.0, period: 5.5);
    _drawShootingStar(canvas, size, slotSeed: seed * 7.7 + 5.0, period: 6.8);
    _drawShootingStar(canvas, size, slotSeed: seed * 31.3 + 9.0, period: 8.1);
  }

  void _drawShootingStar(Canvas canvas, Size size, {required double slotSeed, required double period}) {
    const flightDuration = 0.9;
    final cycleT = time + slotSeed * 17.0;
    final cycleIndex = (cycleT / period).floorToDouble();
    final localT = cycleT % period;
    if (localT > flightDuration) return;
    final progress = localT / flightDuration;

    // Deterministic per-cycle randomness, not per-frame — a fresh random
    // start point/angle each time this slot fires, but stable for the
    // whole flight. Full-screen start position and full-circle direction
    // (was constrained to the top-left corner and one shallow diagonal) —
    // "chaotic, from different places" per feedback.
    final rnd1 = _hash(cycleIndex + slotSeed);
    final rnd2 = _hash(cycleIndex + slotSeed + 91.7);
    final rnd3 = _hash(cycleIndex + slotSeed + 173.2);

    final startX = size.width * (-0.1 + 1.2 * rnd1);
    final startY = size.height * (-0.1 + 1.2 * rnd2);
    final angle = 2 * math.pi * rnd3;
    final travelDist = size.shortestSide * (0.5 + 0.5 * rnd1);
    final headX = startX + math.cos(angle) * travelDist * progress;
    final headY = startY + math.sin(angle) * travelDist * progress;

    final fadeIn = (progress * 6).clamp(0.0, 1.0);
    final fadeOut = ((1 - progress) * 4).clamp(0.0, 1.0);
    final alpha = math.min(fadeIn, fadeOut);
    if (alpha <= 0.0) return;

    final tailLen = size.shortestSide * 0.14;
    final tail = Offset(headX - math.cos(angle) * tailLen, headY - math.sin(angle) * tailLen);
    final head = Offset(headX, headY);

    final linePaint = Paint()
      ..shader = ui.Gradient.linear(
        head,
        tail,
        [Colors.white.withOpacity(0.9 * alpha), Colors.white.withOpacity(0.0)],
      )
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(head, tail, linePaint);

    canvas.drawCircle(head, 2.2, Paint()..color = Colors.white.withOpacity(0.95 * alpha));
  }

  @override
  bool shouldRepaint(covariant _ShootingStarsPainter oldDelegate) => oldDelegate.time != time;
}
