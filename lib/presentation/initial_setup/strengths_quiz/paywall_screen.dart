import 'dart:async';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../core/services/google_play_billing_service.dart';
import '../../../widgets/custom_button.dart';

class _Bullet {
  final IconData icon;
  final String titleKey;
  final String descKey;
  const _Bullet(this.icon, this.titleKey, this.descKey);
}

const List<_Bullet> _bullets = [
  _Bullet(Icons.psychology_rounded, 'quiz_paywall_bullet_1_title', 'quiz_paywall_bullet_1_desc'),
  _Bullet(Icons.bolt_rounded, 'quiz_paywall_bullet_2_title', 'quiz_paywall_bullet_2_desc'),
  _Bullet(Icons.lock_rounded, 'quiz_paywall_bullet_3_title', 'quiz_paywall_bullet_3_desc'),
  _Bullet(Icons.savings_rounded, 'quiz_paywall_bullet_4_title', 'quiz_paywall_bullet_4_desc'),
  _Bullet(Icons.self_improvement_rounded, 'quiz_paywall_bullet_5_title', 'quiz_paywall_bullet_5_desc'),
];

// Deep wine red — reserved for urgency/scarcity cues (old price, discount
// badge, timer, "one-time offer" line) so they read as distinct from the
// app's usual teal without tipping into a garish "SALE" red.
const Color _urgencyBordo = Color(0xFF7A1F2B);

// Vivid emerald, brighter/more saturated than the app's usual cyan700 —
// reserved for the CTA so it visually "burns" against the dark card
// instead of blending into the rest of the teal accents.
const Color _ctaEmerald = Color(0xFF1FAE7A);

// Splices a discounted amount into the store's own formatted price string
// (e.g. "64,99 €" -> "19,50 €"), preserving whatever symbol/spacing/decimal
// style Play Store already chose for this locale — safer than reformatting
// a currency amount from scratch. Mirrors the digit/decimal detection
// in_app_purchase_android itself uses internally to extract currency
// symbols, just run in reverse (extract the number, not the symbol).
String? _discountedPriceText(ProductDetails product) {
  final match = RegExp(r'[\d.,]+').firstMatch(product.price);
  if (match == null) return null;
  final numPart = match.group(0)!;
  final usesComma = numPart.lastIndexOf(',') > numPart.lastIndexOf('.');
  final discounted = product.rawPrice * 0.3;
  final formatted =
      usesComma ? discounted.toStringAsFixed(2).replaceAll('.', ',') : discounted.toStringAsFixed(2);
  return product.price.replaceRange(match.start, match.end, formatted);
}

// Phase 7 — the welcome-offer paywall. The 24h countdown is anchored to
// quizCompletedAt (a server timestamp written the moment the quiz flow
// finished), never to the device clock, so it can't be extended by
// changing the phone's time. The discount itself is a Play Console "Offer"
// (id: GooglePlayBillingService.welcomeOfferId) with developer-determined
// eligibility — this screen is what determines eligibility, by only asking
// for it while time remains.
//
// Design note: a dense, near-opaque dark card with light text — a first
// pass used the light frosted-glass card shared with the rest of the quiz
// flow, but against a busy photo background it left the price/bullets
// hard to scan at a glance. A paywall is read in seconds, not studied, so
// contrast wins over consistency with the lighter screens here.
class QuizPaywallScreen extends StatefulWidget {
  final DateTime quizCompletedAt;
  final void Function(BuildContext context) onDone;

  const QuizPaywallScreen({Key? key, required this.quizCompletedAt, required this.onDone})
      : super(key: key);

  @override
  State<QuizPaywallScreen> createState() => _QuizPaywallScreenState();
}

class _QuizPaywallScreenState extends State<QuizPaywallScreen> with SingleTickerProviderStateMixin {
  static const _offerWindow = Duration(hours: 24);
  static const _hotRed = Color(0xFFFF5A45);

  Timer? _timer;
  Duration _remaining = Duration.zero;
  ProductDetails? _product;
  bool _purchasing = false;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  bool get _offerActive => _remaining > Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
    GooglePlayBillingService.queryProduct(GooglePlayBillingService.yearlyProductId).then((p) {
      if (mounted) setState(() => _product = p);
    });
  }

  void _tick() {
    final elapsed = DateTime.now().difference(widget.quizCompletedAt);
    final remaining = _offerWindow - elapsed;
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

  Future<void> _onBuy(BuildContext context) async {
    setState(() => _purchasing = true);
    try {
      await GooglePlayBillingService.buy(
        GooglePlayBillingService.yearlyProductId,
        useWelcomeOffer: _offerActive,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
    widget.onDone(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1917),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/quiz/paywall_hero.jpg', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.35), Colors.black.withOpacity(0.75)],
                stops: const [0.0, 0.55],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: getPadding(left: 20, right: 20, top: 16, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: getVerticalSize(70)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        padding: getPadding(left: 22, top: 24, right: 22, bottom: 22),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E211E).withOpacity(0.88),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'quiz_paywall_title'.tr(),
                              textAlign: TextAlign.center,
                              style: AppStyle.txtH1WhiteA700.copyWith(
                                fontSize: getFontSize(24),
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: getVerticalSize(8)),
                            Text(
                              'quiz_paywall_subtitle'.tr(),
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight16
                                  .copyWith(color: Colors.white.withOpacity(0.75)),
                            ),
                            if (_offerActive) ...[
                              SizedBox(height: getVerticalSize(16)),
                              Center(
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    final t = _pulseController.value;
                                    return Container(
                                      padding: getPadding(left: 20, top: 10, right: 20, bottom: 10),
                                      decoration: BoxDecoration(
                                        color: _urgencyBordo,
                                        borderRadius: BorderRadius.circular(100),
                                        border: Border.all(
                                          color: _hotRed.withOpacity(0.4 + t * 0.5),
                                          width: 1.5,
                                        ),
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
                                  child: Text(
                                    '${'quiz_paywall_timer_label'.tr()}: ${_fmtCountdown(_remaining)}',
                                    style: AppStyle.txtSFProDisplayRegular14.copyWith(
                                      color: _hotRed,
                                      fontWeight: FontWeight.w700,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            SizedBox(height: getVerticalSize(22)),
                            Container(height: 1, color: Colors.white.withOpacity(0.12)),
                            SizedBox(height: getVerticalSize(20)),
                            if (_product != null)
                              _offerActive
                                  ? Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'quiz_paywall_price_regular_label'.tr(),
                                              style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                                color: Colors.white.withOpacity(0.55),
                                              ),
                                            ),
                                            SizedBox(height: getVerticalSize(4)),
                                            Text(
                                              _product!.price,
                                              style: AppStyle.txtSFProDisplayRegular14.copyWith(
                                                color: _hotRed,
                                                fontSize: getFontSize(19),
                                                fontWeight: FontWeight.w700,
                                                decoration: TextDecoration.lineThrough,
                                                decorationColor: _hotRed,
                                                decorationThickness: 2.4,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          width: 1,
                                          height: getVerticalSize(38),
                                          color: Colors.white.withOpacity(0.15),
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              'quiz_paywall_price_discounted_label'.tr(),
                                              style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                            SizedBox(height: getVerticalSize(4)),
                                            Row(
                                              children: [
                                                Text(
                                                  _discountedPriceText(_product!) ?? _product!.price,
                                                  style: AppStyle.txtH1WhiteA700.copyWith(
                                                    fontSize: getFontSize(36),
                                                    fontWeight: FontWeight.w800,
                                                    shadows: [
                                                      Shadow(
                                                        color: const Color(0xFFC9A24B).withOpacity(0.55),
                                                        blurRadius: 18,
                                                      ),
                                                      Shadow(
                                                        color: _ctaEmerald.withOpacity(0.35),
                                                        blurRadius: 24,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: getHorizontalSize(8)),
                                                Container(
                                                  padding: getPadding(
                                                      left: 8, top: 3, right: 8, bottom: 3),
                                                  decoration: BoxDecoration(
                                                    color: _urgencyBordo,
                                                    borderRadius: BorderRadius.circular(100),
                                                  ),
                                                  child: Text(
                                                    '−70%',
                                                    style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        _product!.price,
                                        style: AppStyle.txtH1WhiteA700.copyWith(fontSize: getFontSize(28)),
                                      ),
                                    ),
                            if (_offerActive) ...[
                              SizedBox(height: getVerticalSize(10)),
                              Center(
                                child: Text(
                                  'quiz_paywall_micro_trust'.tr(),
                                  textAlign: TextAlign.center,
                                  style: AppStyle.txtSFProDisplayRegular11
                                      .copyWith(color: Colors.white.withOpacity(0.6)),
                                ),
                              ),
                            ],
                            SizedBox(height: getVerticalSize(22)),
                            Container(height: 1, color: Colors.white.withOpacity(0.12)),
                            SizedBox(height: getVerticalSize(18)),
                            for (final bullet in _bullets)
                              Padding(
                                padding: getPadding(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: getSize(38),
                                      height: getSize(38),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: _ctaEmerald.withOpacity(0.18),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(bullet.icon, color: _ctaEmerald, size: getSize(20)),
                                    ),
                                    SizedBox(width: getHorizontalSize(14)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bullet.titleKey.tr(),
                                            style: AppStyle.txtSFProDisplayRegular14.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            bullet.descKey.tr(),
                                            style: AppStyle.txtSFProDisplayRegular11
                                                .copyWith(color: Colors.white.withOpacity(0.65)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: getVerticalSize(6)),
                            AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) => Transform.scale(
                                scale: 1 + _pulseController.value * 0.02,
                                child: child,
                              ),
                              child: CustomButton(
                                height: getVerticalSize(50),
                                width: double.infinity,
                                bgColor: _ctaEmerald,
                                prefixWidget: const Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                                ),
                                text: (_purchasing ? '…' : 'quiz_paywall_cta'.tr()).toUpperCase(),
                                variant: ButtonVariant.Cyan,
                                fontStyle: ButtonFontStyle.White16,
                                onTap: _purchasing ? null : () => _onBuy(context),
                              ),
                            ),
                            if (_offerActive) ...[
                              SizedBox(height: getVerticalSize(12)),
                              Text(
                                'quiz_paywall_disclaimer'.tr(),
                                textAlign: TextAlign.center,
                                style: AppStyle.txtSFProDisplayRegular11.copyWith(
                                  color: const Color(0xFFE0879A),
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            SizedBox(height: getVerticalSize(10)),
                            GestureDetector(
                              onTap: _purchasing ? null : () => widget.onDone(context),
                              child: Padding(
                                padding: getPadding(top: 4, bottom: 4),
                                child: Text(
                                  'quiz_paywall_skip'.tr(),
                                  textAlign: TextAlign.center,
                                  style: AppStyle.txtSFProDisplayRegular14
                                      .copyWith(color: Colors.white.withOpacity(0.5)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
