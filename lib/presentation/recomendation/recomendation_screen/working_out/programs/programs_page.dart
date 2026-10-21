import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import 'data/course_repository.dart';
import 'models/course.dart';
import 'pages/course_screen.dart';

// "Программы" inside Обретение: the list of courses. A course is a guided,
// repeatable skill-training path (audio + tasks + tools), not a one-off
// exercise.
class ProgramsPage extends StatefulWidget {
  const ProgramsPage({Key? key}) : super(key: key);

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  List<Course>? _courses;

  @override
  void initState() {
    super.initState();
    CourseRepository().loadAll().then((c) {
      if (mounted) setState(() => _courses = c);
    });
  }

  @override
  Widget build(BuildContext context) {
    final courses = _courses;
    return SingleChildScrollView(
      padding: getPadding(left: 16, right: 16, top: 14, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('programs_tab'.tr(), style: AppStyle.txtH1),
          SizedBox(height: getVerticalSize(8)),
          Text('programs_intro'.tr(),
              style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.gray800, height: 1.5)),
          SizedBox(height: getVerticalSize(16)),
          if (courses == null)
            const Center(child: CircularProgressIndicator())
          else if (courses.isEmpty)
            Text('programs_empty'.tr(),
                style: AppStyle.txtSFProDisplayRegular11.copyWith(color: ColorConstant.gray500))
          else
            for (final c in courses)
              Padding(
                padding: getPadding(bottom: 12),
                child: _CourseCard(
                  course: c,
                  onTap: () =>
                      Navigator.push(context, MaterialPageRoute(builder: (_) => CourseScreen(course: c))),
                ),
              ),
        ],
      ),
    );
  }
}

// Same look as the "Хлебные крошки" topic cards: the cover fills the card,
// a soft dark scrim keeps the white text legible.
class _CourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;
  const _CourseCard({Key? key, required this.course, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cover = course.cover;
    return Semantics(
      button: true,
      label: course.title,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: getVerticalSize(176),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 3)),
                ],
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (cover != null)
                    Image.asset(cover, fit: BoxFit.cover)
                  else
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            ColorConstant.cyan700.withOpacity(0.55),
                            ColorConstant.cyan700.withOpacity(0.85),
                          ],
                        ),
                      ),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.0), Colors.black.withOpacity(0.7)],
                        stops: const [0.2, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: getPadding(left: 20, right: 12, bottom: 14),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('course_steps_count'.tr(namedArgs: {'count': '${course.steps.length}'}),
                                    style: AppStyle.txtSFProDisplayRegular11
                                        .copyWith(color: Colors.white.withOpacity(0.8), letterSpacing: 0.4)),
                                SizedBox(height: getVerticalSize(4)),
                                Text(course.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyle.txtSFProDisplayLight16
                                        .copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                                SizedBox(height: getVerticalSize(4)),
                                Text(course.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyle.txtSFProDisplayLight14
                                        .copyWith(color: Colors.white.withOpacity(0.88), height: 1.35)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
