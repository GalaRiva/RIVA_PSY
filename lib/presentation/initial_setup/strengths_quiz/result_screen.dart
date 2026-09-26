import 'package:easy_localization/easy_localization.dart';
import '../../../widgets/medical_disclaimer.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../core/models/quiz/strength_trait.dart';
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
  // Used to call RatingRequestService.maybeRequestReview() here — the very
  // first result a brand-new user sees during onboarding, before they've
  // used the app for anything real. Apple rejected the app under Guideline
  // 5.6.3 ("only ask for a rating after the user has sufficiently engaged
  // with the app") over exactly this. The request now lives in
  // RatingRequestService.recordPracticeCompleted(), called from K39Screen's
  // "Завершить практику" after a real coping exercise is actually
  // finished a few times over — not here.
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
                    SizedBox(height: getVerticalSize(14)),
                    MedicalDisclaimer(textColor: ColorConstant.gray800, compact: true),
                    SizedBox(height: getVerticalSize(10)),
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
