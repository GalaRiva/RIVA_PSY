import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../core/db/firebase_firestore/data/repository.dart';
import '../presentation/initial_setup/strengths_quiz/paywall_screen.dart';

const Duration _offerWindow = Duration(hours: 24);
const Color _hotRed = Color(0xFFFF5A45);
const Color _urgencyBordo = Color(0xFF7A1F2B);

// Phase 8 fallback — if the user closed the quiz paywall without buying,
// this brings the same 24h welcome offer back within reach from the main
// screen, so it isn't lost the moment they navigate away. Collapses to
// nothing once the window (anchored server-side to quiz_completed_at, same
// as the paywall itself) has actually expired.
class WelcomeOfferBanner extends StatefulWidget {
  const WelcomeOfferBanner({Key? key}) : super(key: key);

  @override
  State<WelcomeOfferBanner> createState() => _WelcomeOfferBannerState();
}

class _WelcomeOfferBannerState extends State<WelcomeOfferBanner>
    with SingleTickerProviderStateMixin {
  DateTime? _quizCompletedAt;
  Duration _remaining = Duration.zero;
  Timer? _timer;
  bool _loaded = false;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  bool get _offerActive => _quizCompletedAt != null && _remaining > Duration.zero;

  @override
  void initState() {
    super.initState();
    FireStoreRepositoryImpl().getQuizCompletedAt().then((value) {
      if (!mounted) return;
      setState(() {
        _quizCompletedAt = value;
        _loaded = true;
      });
      if (value != null) {
        _tick();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
      }
    });
  }

  void _tick() {
    final elapsed = DateTime.now().difference(_quizCompletedAt!);
    final remaining = _offerWindow - elapsed;
    if (!mounted) return;
    setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _fmtCountdown(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || !_offerActive) return const SizedBox.shrink();
    return Padding(
      padding: getPadding(top: 12, bottom: 4),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuizPaywallScreen(
                quizCompletedAt: _quizCompletedAt!,
                onDone: (ctx) =>
                    Navigator.pushNamedAndRemoveUntil(ctx, AppRoutes.main, (route) => false),
              ),
            ),
          );
        },
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final t = _pulseController.value;
            return Container(
              width: double.infinity,
              padding: getPadding(left: 16, top: 12, right: 16, bottom: 12),
              decoration: BoxDecoration(
                color: _urgencyBordo,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _hotRed.withOpacity(0.4 + t * 0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: _hotRed.withOpacity(0.15 + t * 0.25),
                    blurRadius: 10 + t * 8,
                    spreadRadius: t * 1.5,
                  ),
                ],
              ),
              child: child,
            );
          },
          child: Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: _hotRed, size: 22),
              SizedBox(width: getHorizontalSize(10)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'quiz_paywall_cta'.tr(),
                      style: AppStyle.txtSFProDisplayRegular14.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${'quiz_paywall_timer_label'.tr()}: ${_fmtCountdown(_remaining)}',
                      style: AppStyle.txtSFProDisplayRegular11.copyWith(
                        color: _hotRed,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
