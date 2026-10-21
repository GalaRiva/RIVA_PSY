import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/settings/help_now_screen/help_now_screen.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_pop_button.dart';
import 'package:riva_psy/widgets/helpline_link.dart';

import '../models/course.dart';

// Short, non-diagnostic safety questions before a course. Answers are not
// stored anywhere — they only decide the route:
//   self-harm "yes"      -> help page, the course does not start;
//   any specialist "yes" -> a calm "see a specialist first" page, the person
//                           may still open the course as a supplement;
//   otherwise            -> the course.
// Pops with true when the person may continue into the course.
class ScreeningScreen extends StatefulWidget {
  final Course course;
  const ScreeningScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<ScreeningScreen> createState() => _ScreeningScreenState();
}

class _ScreeningScreenState extends State<ScreeningScreen> {
  final Map<String, bool?> _answers = {};
  bool _showSpecialist = false;

  bool get _allAnswered => widget.course.screening.every((q) => _answers[q.id] != null);

  void _continue() {
    final stop = widget.course.screening.any((q) => q.level == 'stop' && _answers[q.id] == true);
    if (stop) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const HelpNowScreen()));
      return;
    }
    final specialist =
        widget.course.screening.any((q) => q.level == 'specialist' && _answers[q.id] == true);
    if (specialist) {
      setState(() => _showSpecialist = true);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final body = AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5);
    if (_showSpecialist) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: getPadding(left: 20, right: 20, top: 16, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.course.specialistTitle ?? 'course_specialist_title'.tr(), style: AppStyle.txtH1),
                SizedBox(height: getVerticalSize(14)),
                Text(widget.course.specialistBody ?? 'course_specialist_body'.tr(), style: body),
                SizedBox(height: getVerticalSize(10)),
                const HelplineLink(),
                const Spacer(),
                CustomButton(
                  height: getVerticalSize(48),
                  width: double.infinity,
                  text: 'course_specialist_continue'.tr().toUpperCase(),
                  textIsFitted: true,
                  variant: ButtonVariant.Cyan,
                  fontStyle: ButtonFontStyle.White16,
                  onTap: () => Navigator.pop(context, true),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text('back'.tr(),
                      style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final cover = widget.course.cover;
    final total = widget.course.screening.length;
    final answered = widget.course.screening.where((q) => _answers[q.id] != null).length;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Cover header: the course artwork fading into the page, with the
          // title sitting on it.
          SizedBox(
            height: getVerticalSize(210),
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (cover != null)
                  Image.asset(cover, fit: BoxFit.cover)
                else
                  Container(color: ColorConstant.cyan700.withOpacity(0.6)),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.35),
                        Colors.black.withOpacity(0.05),
                        AppColors.background,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: getPadding(left: 8, top: 4),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Semantics(
                        button: true,
                        label: 'back'.tr(),
                        excludeSemantics: true,
                        child: IconButton(
                          icon: Container(
                            width: getSize(38),
                            height: getSize(38),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: Colors.black.withOpacity(0.28)),
                            child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: getSize(22)),
                          ),
                          onPressed: () => Navigator.pop(context, false),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: getPadding(left: 20, right: 20, top: 0, bottom: 8),
              children: [
                Text('course_screen_title'.tr(),
                    style: AppStyle.txtH1.copyWith(fontSize: getFontSize(26), height: 1.2)),
                SizedBox(height: getVerticalSize(8)),
                Text('course_screen_intro'.tr(), style: body),
                SizedBox(height: getVerticalSize(18)),
                for (var i = 0; i < total; i++) _questionCard(widget.course.screening[i], i + 1, total, body),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: getPadding(left: 20, right: 20, top: 8, bottom: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_allAnswered)
                    Padding(
                      padding: getPadding(bottom: 8),
                      child: Text('$answered / $total',
                          style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
                    ),
                  CustomButton(
                    height: getVerticalSize(50),
                    width: double.infinity,
                    text: 'continue'.tr().toUpperCase(),
                    variant: ButtonVariant.Cyan,
                    fontStyle: ButtonFontStyle.White16,
                    onTap: _allAnswered ? _continue : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionCard(ScreeningQuestion q, int index, int total, TextStyle body) {
    final answer = _answers[q.id];
    return Padding(
      padding: getPadding(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: getPadding(left: 16, top: 14, right: 16, bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: ColorConstant.cyan700.withOpacity(answer == null ? 0.16 : 0.4)),
          boxShadow: [
            BoxShadow(color: ColorConstant.cyan700.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$index / $total',
                style: AppStyle.txtSFProDisplayRegular11
                    .copyWith(color: ColorConstant.cyan700, letterSpacing: 0.6)),
            SizedBox(height: getVerticalSize(6)),
            Text(q.q, style: body.copyWith(height: 1.45)),
            SizedBox(height: getVerticalSize(12)),
            Row(
              children: [
                for (final yes in [true, false]) ...[
                  Expanded(child: _answerButton(q.id, yes, answer == yes)),
                  if (yes) SizedBox(width: getHorizontalSize(10)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _answerButton(String id, bool yes, bool selected) {
    return Semantics(
      button: true,
      selected: selected,
      label: (yes ? 'course_yes' : 'course_no').tr(),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: () => setState(() => _answers[id] = yes),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: getVerticalSize(42),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? ColorConstant.cyan700.withOpacity(0.14) : Colors.transparent,
            borderRadius: BorderRadius.circular(21),
            border: Border.all(
                color: selected ? ColorConstant.cyan700 : ColorConstant.cyan700.withOpacity(0.25),
                width: selected ? 1.5 : 1),
          ),
          child: Text(
            (yes ? 'course_yes' : 'course_no').tr(),
            style: AppStyle.txtSFProDisplayLight16.copyWith(
              color: selected ? ColorConstant.cyan700 : ColorConstant.gray800,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
