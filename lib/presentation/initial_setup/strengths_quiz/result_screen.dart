import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../core/models/quiz/strength_trait.dart';
import '../../../core/services/rating/rating_request_service.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

// Phase 4 — shows the leading strength with its "shadow side" (the
// vulnerability the app helps with), reusing that trait's own quiz image
// so the user recognizes it from the question they scored highest on.
class QuizResultScreen extends StatefulWidget {
  final StrengthTrait trait;
  // Takes this screen's own live BuildContext — see loading_screen.dart's
  // onComplete for why a context threaded through earlier screens goes
  // stale after each pushReplacement.
  final void Function(BuildContext context) onContinue;

  const QuizResultScreen({Key? key, required this.trait, required this.onContinue})
      : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  @override
  void initState() {
    super.initState();
    // Let the user actually read and feel the result before the native
    // review dialog can appear over it.
    Future.delayed(const Duration(milliseconds: 1800), () async {
      if (!mounted) return;
      final outcome = await RatingRequestService.maybeRequestReview();
      if (!kDebugMode || !mounted) return;
      // Debug-only visibility — sideloaded/debug installs never actually
      // show the native dialog, so this is the only way to confirm the
      // call fired and see why it did or didn't.
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('🧪 Rating request: ${_debugLabel(outcome)}'),
      ));
    });
  }

  String _debugLabel(RatingRequestOutcome outcome) {
    switch (outcome) {
      case RatingRequestOutcome.requested:
        return 'вызван requestReview()';
      case RatingRequestOutcome.skippedMaxCount:
        return 'пропущен — исчерпан лимит вызовов за всё время';
      case RatingRequestOutcome.skippedInterval:
        return 'пропущен — ещё не прошло 90 дней с прошлого вызова';
      case RatingRequestOutcome.skippedUnavailable:
        return 'пропущен — API недоступен на этом устройстве';
    }
  }

  @override
  Widget build(BuildContext context) {
    final trait = widget.trait;
    final onContinue = widget.onContinue;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(trait.imageAsset, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.20),
                  Colors.transparent,
                  Colors.black.withOpacity(0.45),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.15),
            child: Padding(
              padding: getPadding(left: 30, right: 30),
              child: GlassCard(
                padding: getPadding(left: 24, top: 26, right: 24, bottom: 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trait.resultBodyKey.tr(),
                      style: AppStyle.txtSFProDisplayLight16.copyWith(
                        color: ColorConstant.gray800,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: getVerticalSize(22)),
                    CustomButton(
                      height: getVerticalSize(48),
                      width: double.infinity,
                      text: 'continue'.tr().toUpperCase(),
                      variant: ButtonVariant.Cyan,
                      fontStyle: ButtonFontStyle.White16,
                      onTap: () => onContinue(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
