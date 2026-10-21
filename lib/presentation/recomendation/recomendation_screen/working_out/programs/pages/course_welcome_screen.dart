import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_colors.dart';

import '../models/course.dart';
import '../widgets/course_ui.dart';

// A short "how this program works" introduction, shown once the first time a
// course is opened (after the safety questions). Three quiet pages, can be
// skipped at any time.
class CourseWelcomeScreen extends StatefulWidget {
  final Course course;
  const CourseWelcomeScreen({Key? key, required this.course}) : super(key: key);

  @override
  State<CourseWelcomeScreen> createState() => _CourseWelcomeScreenState();
}

class _CourseWelcomeScreenState extends State<CourseWelcomeScreen> {
  final _page = PageController();
  int _index = 0;

  List<WelcomePage> get _pages =>
      widget.course.welcome.where((p) => !p.androidOnly || Platform.isAndroid).toList();

  IconData _icon(String key) {
    switch (key) {
      case 'pace':
        return Icons.schedule_rounded;
      case 'help':
        return Icons.favorite_border_rounded;
      case 'shortcut':
        return Icons.touch_app_rounded;
      default:
        return Icons.route_rounded;
    }
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      Navigator.pop(context);
    } else {
      _page.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _index >= _pages.length - 1;
    return CourseTextScale(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: getPadding(left: 20, right: 8, top: 4),
                child: Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('onb_skip'.tr(),
                          style: AppStyle.txtSFProDisplayLight14.copyWith(color: AppColors.textSecondary)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => SingleChildScrollView(
                    padding: getPadding(left: 28, right: 28, top: 24, bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: getSize(84),
                          height: getSize(84),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
                          child: Icon(_icon(_pages[i].icon), size: getSize(38), color: AppColors.primary),
                        ),
                        SizedBox(height: getVerticalSize(30)),
                        Text(_pages[i].title,
                            style: AppStyle.txtH1.copyWith(
                                color: AppColors.textPrimary, fontSize: getFontSize(28), height: 1.15)),
                        SizedBox(height: getVerticalSize(16)),
                        Text(_pages[i].body,
                            style: AppStyle.txtSFProDisplayLight16.copyWith(
                                color: AppColors.textPrimary.withOpacity(0.78),
                                height: 1.6,
                                fontSize: getFontSize(17))),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: i == _index ? AppColors.primary : AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: getPadding(left: 20, right: 20, top: 18, bottom: 18),
                child: CapsuleButton(
                    label: (last ? 'course_welcome_start' : 'course_next').tr(), onTap: _next),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
