import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../theme/app_colors.dart';
import '../../../widgets/custom_button.dart';

// Phase 5 — bridges the quiz result to real content. Always recommends the
// same "Конгруэнтность сердца" meditation regardless of the leading trait
// (per the simplified, agreed-on approach — no trait→content mapping to
// maintain), with a note that it's best experienced with headphones.
class QuizBridgeScreen extends StatelessWidget {
  final void Function(BuildContext context) onListen;
  final void Function(BuildContext context) onSkip;

  const QuizBridgeScreen({Key? key, required this.onListen, required this.onSkip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: getPadding(left: 24, right: 24, top: 24, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset('assets/images/quiz/love.jpg', fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: getVerticalSize(32)),
              Text(
                'quiz_bridge_title'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.txtH1.copyWith(fontSize: getFontSize(22)),
              ),
              SizedBox(height: getVerticalSize(12)),
              Text(
                'quiz_bridge_subtitle'.tr(),
                textAlign: TextAlign.center,
                style: AppStyle.txtSFProDisplayLight16.copyWith(
                  color: ColorConstant.gray500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: getVerticalSize(14)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.headphones_rounded, size: getSize(18), color: ColorConstant.cyan700),
                  SizedBox(width: getHorizontalSize(8)),
                  Text(
                    'quiz_bridge_headphones_note'.tr(),
                    style: AppStyle.txtSFProDisplayRegular11Cyan700,
                  ),
                ],
              ),
              const Spacer(),
              CustomButton(
                height: getVerticalSize(48),
                width: double.infinity,
                text: 'quiz_bridge_cta'.tr().toUpperCase(),
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: () => onListen(context),
              ),
              SizedBox(height: getVerticalSize(12)),
              GestureDetector(
                onTap: () => onSkip(context),
                child: Padding(
                  padding: getPadding(top: 4, bottom: 4),
                  child: Text(
                    'continue'.tr(),
                    style: AppStyle.txtSFProDisplayRegular14.copyWith(color: ColorConstant.gray500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
