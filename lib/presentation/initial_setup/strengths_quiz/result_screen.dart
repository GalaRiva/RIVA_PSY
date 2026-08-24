import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../core/models/quiz/strength_trait.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';

// Phase 4 — shows the leading strength with its "shadow side" (the
// vulnerability the app helps with), reusing that trait's own quiz image
// so the user recognizes it from the question they scored highest on.
class QuizResultScreen extends StatelessWidget {
  final StrengthTrait trait;
  // Takes this screen's own live BuildContext — see loading_screen.dart's
  // onComplete for why a context threaded through earlier screens goes
  // stale after each pushReplacement.
  final void Function(BuildContext context) onContinue;

  const QuizResultScreen({Key? key, required this.trait, required this.onContinue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
