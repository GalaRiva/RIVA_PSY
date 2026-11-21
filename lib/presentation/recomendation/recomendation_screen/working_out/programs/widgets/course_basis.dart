import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/course_sources.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'course_fold.dart';
import 'course_ui.dart';

Future<void> _openUrl(BuildContext context, String url) async {
  var ok = false;
  try {
    ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('src_open_failed'.tr())));
  }
}

/// The list of sources: each one a tappable citation that opens the guideline,
/// article (by DOI) or publisher page in the browser.
class CourseSourcesList extends StatelessWidget {
  final List<String> ids;
  const CourseSourcesList({Key? key, required this.ids}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = ids.map(courseSourceById).whereType<CourseSource>().toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 1, color: AppColors.divider),
          Semantics(
            link: true,
            label: items[i].citation,
            excludeSemantics: true,
            child: InkWell(
              onTap: () => _openUrl(context, items[i].url),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: getPadding(top: 10, bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(items[i].citation,
                          style: AppStyle.txtSFProDisplayRegular11
                              .copyWith(color: AppColors.textPrimary, fontSize: getFontSize(13), height: 1.4)),
                    ),
                    SizedBox(width: getHorizontalSize(10)),
                    Padding(
                      padding: getPadding(top: 2),
                      child: Icon(Icons.open_in_new_rounded, size: getSize(16), color: AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Splits a long note into short paragraphs (two sentences each) so it reads
/// as blocks, not as a wall of text.
List<String> _paragraphs(String text) {
  final sentences = text
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((e) => e.trim().isNotEmpty)
      .toList();
  final out = <String>[];
  for (var i = 0; i < sentences.length; i += 2) {
    out.add(sentences.skip(i).take(2).join(' '));
  }
  return out;
}

/// "Научная основа" of one step, in a bottom sheet: the method in short
/// paragraphs, the limits and the sources as folding lists, a cross on top.
void showCourseBasisSheet(BuildContext context, {required String text, required List<String> refIds}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => CourseTextScale(
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.88),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: getPadding(left: 22, right: 8, top: 10),
                child: Row(
                  children: [
                    Icon(Icons.menu_book_outlined, color: AppColors.primary, size: getSize(22)),
                    SizedBox(width: getHorizontalSize(10)),
                    Expanded(
                      child: Text('course_basis_title'.tr(),
                          style: AppStyle.txtH2.copyWith(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w700, height: 1.2)),
                    ),
                    IconButton(
                      tooltip: 'close'.tr(),
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(Icons.close_rounded, color: courseMuted(false)),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: getPadding(left: 22, right: 22, top: 6, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final para in _paragraphs(text)) ...[
                        Text(para,
                            style: AppStyle.txtSFProDisplayLight16
                                .copyWith(color: AppColors.textPrimary, height: 1.55)),
                        SizedBox(height: getVerticalSize(12)),
                      ],
                      SizedBox(height: getVerticalSize(6)),
                      CourseFold(
                        icon: Icons.fact_check_outlined,
                        title: 'course_basis_limits'.tr(),
                        child: Text('course_basis_note'.tr(),
                            style: courseBody()
                                .copyWith(color: courseSoft(false), height: 1.5)),
                      ),
                      if (refIds.isNotEmpty) ...[
                        SizedBox(height: getVerticalSize(10)),
                        CourseFold(
                          icon: Icons.link_rounded,
                          title: 'course_basis_sources'.tr(),
                          count: refIds.length,
                          child: CourseSourcesList(ids: refIds),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// The quiet "info" row shown under a step's description.
class CourseBasisRow extends StatelessWidget {
  final String text;
  final List<String> refIds;
  final Color accent;
  const CourseBasisRow({Key? key, required this.text, required this.refIds, required this.accent}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'course_basis_link'.tr(),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => showCourseBasisSheet(context, text: text, refIds: refIds),
        borderRadius: BorderRadius.circular(12),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline_rounded, size: getSize(18), color: accent),
              SizedBox(width: getHorizontalSize(8)),
              Flexible(
                child: Text('course_basis_link'.tr(),
                    style: courseBody().copyWith(color: accent, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
