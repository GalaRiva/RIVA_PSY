import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

import '../data/course_plan_pdf.dart';
import '../data/course_progress_store.dart';
import 'chain_visual.dart';
import '../models/course.dart';
import '../widgets/course_ui.dart';

// "Моя библиотека": everything the person wrote in the course tasks, newest
// first, grouped by round in the card's subtitle. Stays on the phone.
class CourseLibraryScreen extends StatefulWidget {
  final Course course;
  const CourseLibraryScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseLibraryScreen> createState() => _CourseLibraryScreenState();
}

class _CourseLibraryScreenState extends State<CourseLibraryScreen> {
  List<CourseCard> _cards = [];
  bool _loaded = false;
  bool _hasPlan = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final cards = await CourseProgressStore.cards(widget.course.id);
    final hasPlan = await CoursePlanPdf.hasAnything(widget.course);
    // "wave" and "weekly" cards are inputs of "Моя динамика", not something
    // to read back as a card.
    const hidden = {'wave', 'weekly', 'night_thought', 'meeting_result'};
    final shown = cards.where((c) => !hidden.contains(c.cardType)).toList();
    if (mounted) setState(() {
      _cards = shown;
      _hasPlan = hasPlan;
      _loaded = true;
    });
  }

  CourseTask? _taskFor(String cardType) {
    for (final s in widget.course.steps) {
      if (s.task.cardType == cardType) return s.task;
    }
    return null;
  }

  void _open(CourseCard card) {
    final task = _taskFor(card.cardType);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: getPadding(left: 20, right: 20, top: 24, bottom: 28),
        decoration: BoxDecoration(
          color: ColorConstant.whiteA700,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task?.title ?? card.cardType, style: AppStyle.txtH2),
              SizedBox(height: getVerticalSize(12)),
              if (task?.visual == 'chain')
                ChainVisual(fields: task!.fields, values: card.values)
              else
              for (final f in task?.fields ?? <CourseField>[])
                if ((card.values[f.id] ?? '').isNotEmpty && card.values[f.id] != '0')
                  Padding(
                    padding: getPadding(bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.label,
                            style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500)),
                        Text(card.values[f.id] == '1' ? '✓' : card.values[f.id]!,
                            style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800)),
                      ],
                    ),
                  ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await CourseProgressStore.deleteCard(widget.course.id, card.id);
                      _reload();
                    },
                    child: Text('course_delete'.tr(),
                        style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray500)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('close'.tr(),
                        style: AppStyle.txtSFProDisplayLight14.copyWith(color: ColorConstant.gray800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CourseTextScale(child: _buildBody(context));

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: getPadding(left: 20, right: 20, top: 10, bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RoundIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                  tooltip: 'back'.tr(),
                  onImage: false),
              SizedBox(height: getVerticalSize(20)),
              Text('course_my_library'.tr(),
                  style: AppStyle.txtH1.copyWith(color: AppColors.textPrimary, fontSize: getFontSize(27))),
              SizedBox(height: getVerticalSize(14)),
              if (_loaded && _cards.isEmpty)
                Text('course_library_empty'.tr(),
                    style: AppStyle.txtSFProDisplayLight16
                        .copyWith(color: AppColors.textPrimary.withOpacity(0.75), height: 1.55)),
              if (_hasPlan)
                Padding(
                  padding: getPadding(bottom: 14),
                  child: CapsuleButton(
                    outlined: true,
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'course_pdf_button'.tr(),
                    onTap: () => CoursePlanPdf.share(widget.course,
                        footer: 'course_pdf_footer'.tr(), title: 'course_pdf_title'.tr()),
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: getPadding(bottom: 12),
                  children: [
                    for (final c in _cards)
                      Padding(
                        padding: getPadding(bottom: 10),
                        child: SoftCard(
                          onTap: () => _open(c),
                          padding: getPadding(left: 16, top: 14, right: 12, bottom: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_taskFor(c.cardType)?.title ?? c.cardType,
                                        style: AppStyle.txtSFProDisplayLight16.copyWith(
                                            color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                    SizedBox(height: getVerticalSize(3)),
                                    Text(
                                        '${'course_card_round'.tr(namedArgs: {'n': '${c.round}'})} · '
                                        '${c.createdAt.day.toString().padLeft(2, '0')}.${c.createdAt.month.toString().padLeft(2, '0')}.${c.createdAt.year}',
                                        style: AppStyle.txtSFProDisplayRegular11
                                            .copyWith(color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
