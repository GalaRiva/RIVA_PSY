import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';

import '../../../core/models/quiz/quiz_question.dart';
import '../../../core/models/quiz/strength_trait.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/glass_card.dart';
import 'quiz_controller.dart';

class StrengthsQuizScreen extends GetWidget<StrengthsQuizController> {
  final controller = Get.put(StrengthsQuizController());
  final void Function(BuildContext context, StrengthsQuizController controller)
      onFinished;
  final void Function(BuildContext context) onSkip;

  StrengthsQuizScreen(
      {Key? key, required this.onFinished, required this.onSkip})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<StrengthsQuizController>(
        builder: (_) {
          final question = controller.currentQuestion;
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                // Default layoutBuilder wraps children in a non-expanding
                // Stack, so the image gets loose constraints and sizes to
                // its own aspect ratio instead of the full screen — cover
                // then "covers" that smaller box, leaving letterboxing.
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  fit: StackFit.expand,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild
                  ],
                ),
                child: Image.asset(
                  question.trait.imageAsset,
                  key: ValueKey(controller.currentIndex),
                  fit: BoxFit.cover,
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.28),
                      Colors.transparent,
                      Colors.black.withOpacity(0.10),
                      Colors.black.withOpacity(0.45),
                    ],
                    stops: const [0.0, 0.28, 0.55, 1.0],
                  ),
                ),
              ),
              Align(
                // Stack(fit: StackFit.expand) stretches every non-positioned
                // child to the full screen — without this, the Row below
                // gets the whole screen's height and centers its children
                // vertically instead of sitting at the top (that's why the
                // skip button/progress pill were showing mid-screen).
                alignment: Alignment.topCenter,
                child: SafeArea(
                  child: Padding(
                    padding: getPadding(left: 20, right: 20, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GlassPill(
                          child: Text(
                            '${controller.currentIndex + 1} / ${strengthsQuizQuestions.length}',
                            style: AppStyle.txtSFProDisplayRegular14
                                .copyWith(color: Colors.white),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => onSkip(context),
                          child: Container(
                            width: getSize(38),
                            height: getSize(38),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withOpacity(0.5),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.9),
                                  width: 1.4),
                            ),
                            // Hand-drawn bold X instead of an Icons glyph —
                            // no dependency on whether the icon font supports
                            // a "weight" variation axis.
                            child: SizedBox(
                              width: getSize(16),
                              height: getSize(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Transform.rotate(
                                    angle: 0.785398, // 45deg
                                    child: Container(
                                        width: getSize(16),
                                        height: 3,
                                        color: Colors.white),
                                  ),
                                  Transform.rotate(
                                    angle: -0.785398,
                                    child: Container(
                                        width: getSize(16),
                                        height: 3,
                                        color: Colors.white),
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
              ),
              Align(
                alignment: const Alignment(0, -0.15),
                child: Padding(
                  padding: getPadding(left: 30, right: 30),
                  child: GlassCard(
                    padding:
                        getPadding(left: 20, top: 22, right: 20, bottom: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.statementKey.tr(),
                          style: AppStyle.txtH1
                              .copyWith(fontSize: getFontSize(19)),
                        ),
                        SizedBox(height: getVerticalSize(20)),
                        _AnswerScale(
                          selected: controller.currentAnswer,
                          onSelect: controller.selectAnswer,
                        ),
                        SizedBox(height: getVerticalSize(8)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('quiz_scale_low'.tr(),
                                style:
                                    AppStyle.txtSFProDisplayRegular11Gray800),
                            Text('quiz_scale_high'.tr(),
                                style:
                                    AppStyle.txtSFProDisplayRegular11Gray800),
                          ],
                        ),
                        SizedBox(height: getVerticalSize(20)),
                        CustomButton(
                          height: getVerticalSize(48),
                          width: double.infinity,
                          text: (controller.isLastQuestion
                                  ? 'quiz_finish'.tr()
                                  : 'continue'.tr())
                              .toUpperCase(),
                          variant: ButtonVariant.Cyan,
                          fontStyle: ButtonFontStyle.White16,
                          onTap: controller.currentAnswer == null
                              ? null
                              : () {
                                  final wasLast = controller.isLastQuestion;
                                  controller.confirmCurrentAnswer();
                                  if (wasLast) onFinished(context, controller);
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AnswerScale extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelect;

  const _AnswerScale({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(5, (i) {
        final value = i + 1;
        final isSelected = selected == value;
        return GestureDetector(
          onTap: () => onSelect(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: getSize(48),
            height: getSize(48),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? ColorConstant.cyan700
                  : Colors.white.withOpacity(0.55),
              border: Border.all(
                color: isSelected
                    ? ColorConstant.cyan700
                    : ColorConstant.cyan700.withOpacity(0.35),
                width: 1.4,
              ),
            ),
            child: Text(
              '$value',
              style: AppStyle.txtSFProDisplayRegular14.copyWith(
                color: isSelected ? Colors.white : ColorConstant.gray800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      }),
    );
  }
}
