import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import 'data/course_progress_store.dart';
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
  // course id -> finished numbered steps (shown as a quiet progress line).
  final Map<String, int> _done = {};

  @override
  void initState() {
    super.initState();
    CourseRepository().loadAll().then((c) {
      if (mounted) setState(() => _courses = c);
      _loadProgress(c);
    });
  }

  Future<void> _loadProgress(List<Course> courses) async {
    for (final c in courses) {
      final p = await CourseProgressStore.load(c.id);
      final done = c.steps.where((s) => s.number != null && p.step(s.id).complete).length;
      if (mounted) setState(() => _done[c.id] = done);
    }
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
                  done: _done[c.id] ?? 0,
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseScreen(course: c)));
                    _loadProgress(courses);
                  },
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
  final int done;
  final VoidCallback onTap;
  const _CourseCard({Key? key, required this.course, required this.done, required this.onTap})
      : super(key: key);

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
                  // The cover is a bubble on the right: only the left part (where
                  // the text sits) is darkened, so the whole bubble stays bright.
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Colors.black.withOpacity(0.62), Colors.black.withOpacity(0.0)],
                        stops: const [0.0, 0.62],
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
                            flex: 11,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(builder: (_) {
                                  final total = course.steps.where((s) => s.number != null).length;
                                  if (done > 0 && total > 0) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('course_progress_of'.tr(namedArgs: {'done': '$done', 'total': '$total'}),
                                            style: AppStyle.txtSFProDisplayRegular11
                                                .copyWith(color: Colors.white.withOpacity(0.85), letterSpacing: 0.4)),
                                        SizedBox(height: getVerticalSize(5)),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(2),
                                          child: SizedBox(
                                            width: getHorizontalSize(120),
                                            height: 3,
                                            child: LinearProgressIndicator(
                                              value: (done / total).clamp(0.0, 1.0),
                                              backgroundColor: Colors.white.withOpacity(0.25),
                                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                  return Text('course_steps_count'.tr(namedArgs: {'count': '${course.steps.length}'}),
                                      style: AppStyle.txtSFProDisplayRegular11
                                          .copyWith(color: Colors.white.withOpacity(0.8), letterSpacing: 0.4));
                                }),
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
                          const Spacer(flex: 8),
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
