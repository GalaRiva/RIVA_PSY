import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

import '../models/course.dart';
import 'course_basis.dart';
import 'course_fold.dart';
import 'course_ui.dart';

IconData _aboutIcon(String k) {
  switch (k) {
    case 'spa':
      return Icons.spa_outlined;
    case 'layers':
      return Icons.layers_outlined;
    case 'route':
      return Icons.alt_route_rounded;
    case 'warn':
      return Icons.shield_outlined;
    case 'time':
      return Icons.hourglass_empty_rounded;
    case 'heart':
      return Icons.favorite_border_rounded;
    default:
      return Icons.info_outline_rounded;
  }
}

/// The body of the "О программе" panel as short visual blocks instead of one
/// long text: what it is, the modules, the pace, what it is not, then the
/// science note and the sources as folding lists.
class CourseAboutBody extends StatelessWidget {
  final Course course;
  const CourseAboutBody({Key? key, required this.course}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final b in course.about) ...[
          _Block(block: b),
          SizedBox(height: getVerticalSize(12)),
        ],
        if (course.scienceNote.isNotEmpty)
          CourseFold(
            icon: Icons.menu_book_outlined,
            title: 'course_basis_title'.tr(),
            child: Text(course.scienceNote,
                style: courseBody().copyWith(color: courseSoft(false), height: 1.5)),
          ),
        if (course.sourceIds.isNotEmpty) ...[
          SizedBox(height: getVerticalSize(10)),
          CourseFold(
            icon: Icons.link_rounded,
            title: 'course_basis_sources'.tr(),
            count: course.sourceIds.length,
            child: CourseSourcesList(ids: course.sourceIds),
          ),
        ],
      ],
    );
  }
}

class _Block extends StatelessWidget {
  final AboutBlock block;
  const _Block({required this.block});

  @override
  Widget build(BuildContext context) {
    final warn = block.tone == 'warn';
    final plain = block.tone == 'plain';
    final bg = warn ? const Color(0xFFF6EFE2) : (plain ? AppColors.surface : AppColors.primaryLight);
    final fg = warn ? const Color(0xFF8A6A2E) : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: getPadding(left: 16, top: 14, right: 16, bottom: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: plain ? Border.all(color: AppColors.divider) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_aboutIcon(block.icon), size: getSize(20), color: fg),
              SizedBox(width: getHorizontalSize(10)),
              Expanded(
                child: Text(block.title,
                    style: AppStyle.txtSFProDisplayLight16
                        .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.2)),
              ),
            ],
          ),
          if (block.body.isNotEmpty) ...[
            SizedBox(height: getVerticalSize(8)),
            Text(block.body,
                style: courseBody().copyWith(color: courseSoft(false), height: 1.5)),
          ],
          for (var i = 0; i < block.items.length; i++) ...[
            SizedBox(height: getVerticalSize(i == 0 ? 10 : 8)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: getSize(24),
                  height: getSize(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.75)),
                  child: block.numbered
                      ? Text('${i + 1}',
                          style: courseCaption().copyWith(color: fg, fontWeight: FontWeight.w700, height: 1))
                      : Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: fg)),
                ),
                SizedBox(width: getHorizontalSize(10)),
                Expanded(
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: block.items[i][0],
                          style: courseBody()
                              .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600, height: 1.45)),
                      TextSpan(
                          text: '  ${block.items[i][1]}',
                          style: courseBody().copyWith(color: courseSoft(false), height: 1.45)),
                    ]),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
