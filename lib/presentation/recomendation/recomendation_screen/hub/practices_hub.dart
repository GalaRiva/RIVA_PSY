import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/negative_emotion_tabs.dart';
import 'package:riva_psy/presentation/initial_setup/onboarding/first_steps_checklist.dart';
import 'package:riva_psy/theme/app_colors.dart';
import 'package:riva_psy/widgets/go_to_new_tariff_widget.dart';
import 'package:riva_psy/widgets/hero_banner.dart';

import '../controller.dart';
import '../widgets/tab_widget.dart';
import '../working_out/bloc/cubit.dart';
import '../working_out/bloc/state.dart';
import '../working_out/desires/desires_page.dart';
import '../working_out/guided_journals/guided_journals_page.dart';
import '../working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';
import '../working_out/happiness_in_focus/ui/happiness_in_focus_page.dart';
import '../working_out/programs/data/course_progress_store.dart';
import '../working_out/programs/data/course_repository.dart';
import '../working_out/programs/models/course.dart';
import '../working_out/programs/pages/course_screen.dart';
import '../working_out/programs/programs_page.dart';
import '../working_out/working_out_irrational/bloc/cubit.dart';
import '../working_out/working_out_irrational/working_out_irrational_tab.dart';
import 'emotion_tile.dart';
import 'hub_section_screen.dart';
import 'parallax_backdrop.dart';
import 'sos_screen.dart';
import 'package:riva_psy/presentation/initial_setup/onboarding/onboarding_flow.dart';

TextStyle _ts(double size, {FontWeight? w, Color? color, double? height, double? spacing}) =>
    AppStyle.txtSFProDisplayRegular11.copyWith(
      fontSize: getFontSize(size),
      fontWeight: w,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: spacing,
    );

/// The "Практики" home: everything that helps, in one scrollable page and
/// grouped by what a person needs, instead of three levels of tabs. Each
/// block opens its area as a full screen (see [HubSectionScreen]); the
/// content of those areas is the existing, unchanged pages.
class PracticesHub extends StatefulWidget {
  final K70Controller controller;

  /// Route arguments from places that deep-link into the old tab layout
  /// (`first`/`second` for the emotion tabs, `initialTab`/`workingOutTab`
  /// for the written practices); mapped to the matching area on open.
  final Map? deepLink;

  const PracticesHub({Key? key, required this.controller, this.deepLink}) : super(key: key);

  @override
  State<PracticesHub> createState() => _PracticesHubState();
}

class _PracticesHubState extends State<PracticesHub> {
  List<Course>? _courses;
  final Map<String, int> _done = {};

  K70Controller get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _loadCourses();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleDeepLink());
  }

  Future<void> _loadCourses() async {
    final courses = await CourseRepository().loadAll();
    if (!mounted) return;
    setState(() => _courses = courses);
    _loadProgress(courses);
  }

  Future<void> _loadProgress(List<Course> courses) async {
    for (final c in courses) {
      final p = await CourseProgressStore.load(c.id);
      final done = c.steps.where((s) => s.number != null && p.step(s.id).complete).length;
      if (mounted) setState(() => _done[c.id] = done);
    }
  }

  // ---- navigation -------------------------------------------------------

  /// Opens [child] as a full screen. The cubits that the old tab layout
  /// provided are handed on, so the existing pages keep working unchanged.
  Future<void> _push(String title, Widget child, {bool workingOut = false}) {
    final wo = context.read<WorkingOutCubit>();
    final irr = context.read<WorkingOutIrrationalCubit>();
    final hif = context.read<HappinessInFocusCubit>();
    return Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: wo),
          BlocProvider.value(value: irr),
          BlocProvider.value(value: hif),
        ],
        child: HubSectionScreen(title: title, hidesMiniPlayer: workingOut, child: child),
      ),
    ));
  }

  Widget _gated(Widget page) => BlocBuilder<WorkingOutCubit, WorkingOutState>(
        builder: (context, _) {
          // Same rule as before: without a subscription the three paid
          // practices show only the teaser, their bodies are not built.
          if (!context.read<WorkingOutCubit>().showContent) {
            return SingleChildScrollView(child: GoToNewTariffWidget(goToFreeRecommendation: false));
          }
          return Padding(padding: const EdgeInsets.only(top: 6), child: page);
        },
      );

  void _openEmotion(int index) {
    final bodies = _c.negativeEmotionsModel?.tabBodies ?? const <Widget>[];
    if (index < 0 || index >= bodies.length) return;
    // The picture header inside carries the emotion's name.
    _push('', bodies[index]);
  }

  void _openDepression() => _push(
        '',
        TabWidget(
            tab: _c.depressionModel,
            controller: _c,
            height: 2515,
            heroAsset: 'assets/images/hub/emo_depression.jpg',
            heroTitle: 'depression'.tr()),
      );

  void _openIntroduction() => _push(
        '',
        TabWidget(
            isStandardCheck: false,
            enableScroll: false,
            tab: _c.introductionModel,
            controller: _c,
            height: 875,
            heroAsset: 'assets/images/hub/star_08.jpg',
            heroTitle: 'introduction'.tr()),
      );

  void _openMeditations() => _push(
        '',
        TabWidget(
            enableScroll: false,
            tab: _c.meditationModel,
            controller: _c,
            height: 523,
            heroAsset: 'assets/images/hub/star_12.jpg',
            heroTitle: 'meditations'.tr()),
      );

  void _openCrumbs() => _push('breadcrumbs_exercise'.tr(), const GuidedJournalsPage(), workingOut: true);
  void _openIrrational() => _push('work_out_irrational'.tr(), _gated(WorkingOutIrrationalTab()), workingOut: true);
  void _openHappiness() => _push('prestige_in_focus'.tr(), _gated(HappinessInFocusPage()), workingOut: true);
  void _openDesires() => _push('desires'.tr(), _gated(DesiresPage()), workingOut: true);
  void _openPrograms() => _push('', const ProgramsPage(), workingOut: true);

  void _openSos() => _push(
        'hub_sos'.tr(),
        SosScreen(onListen: () => _openEmotion(_c.panicTab)),
      );

  Future<void> _openCourse(Course c) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => CourseScreen(course: c)));
    if (_courses != null) _loadProgress(_courses!);
  }

  void _handleDeepLink() {
    final data = widget.deepLink;
    if (data == null || !mounted) return;
    final initialTab = data['initialTab'] as int?;
    final workingOutTab = data['workingOutTab'] as int?;
    final first = data['first'] as int?;
    final second = data['second'] as int?;
    if (initialTab == 2 || workingOutTab != null) {
      switch (workingOutTab ?? 0) {
        case 1:
          _openHappiness();
          break;
        case 2:
          _openDesires();
          break;
        case 3:
          _openPrograms();
          break;
        default:
          _openIrrational();
      }
    } else if (initialTab == 1) {
      _openCrumbs();
    } else if (first != null) {
      switch (first) {
        case 0:
          _openIntroduction();
          break;
        case 1:
          _openMeditations();
          break;
        case 3:
          _openDepression();
          break;
        default:
          _openEmotion(second ?? 0);
      }
    }
  }

  // ---- blocks -----------------------------------------------------------

  Widget _block({required String title, String? action, VoidCallback? onAction, required Widget child, Color? color}) {
    return Container(
      width: double.infinity,
      margin: getMargin(bottom: 14),
      padding: getPadding(left: 14, top: 12, right: 14, bottom: 14),
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color == null ? AppColors.divider : Colors.white.withOpacity(0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: _ts(15, w: FontWeight.w600))),
              if (action != null)
                InkWell(
                  onTap: onAction,
                  child: Padding(
                    padding: getPadding(left: 8, top: 4, bottom: 4),
                    child: Text(action, style: _ts(13, w: FontWeight.w500, color: AppColors.primary)),
                  ),
                ),
            ],
          ),
          SizedBox(height: getVerticalSize(10)),
          child,
        ],
      ),
    );
  }

  Widget _sos() => Padding(
        padding: getPadding(top: 12, bottom: 14),
        child: Semantics(
          button: true,
          label: 'hub_sos'.tr(),
          excludeSemantics: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: _openSos,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: getVerticalSize(64),
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/hub/star_14.jpg', fit: BoxFit.cover),
                      Container(color: const Color(0xFF0E2628).withOpacity(0.52)),
                      Padding(
                        padding: getPadding(left: 14, right: 12),
                        child: Row(
                          children: [
                            Icon(Icons.support_rounded, color: Colors.white, size: getSize(24)),
                            SizedBox(width: getHorizontalSize(10)),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('hub_sos'.tr(), style: _ts(15, w: FontWeight.w600, color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// "Мой запрос": the short path (what is hardest right now -> a practice for
  /// it -> how do you feel). Always here, unlike the "Начните здесь" block,
  /// which goes away once its three steps are done.
  Widget _request() => Padding(
        padding: getPadding(bottom: 14),
        child: Semantics(
          button: true,
          label: 'hub_request'.tr(),
          excludeSemantics: true,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(22),
              onTap: () => startOnboardingFlow(context, fromSettings: true),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: SizedBox(
                  height: getVerticalSize(64),
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/images/hub/star_13.jpg', fit: BoxFit.cover),
                      Container(color: const Color(0xFF0E2628).withOpacity(0.52)),
                      Padding(
                        padding: getPadding(left: 14, right: 12),
                        child: Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: getSize(22)),
                            SizedBox(width: getHorizontalSize(10)),
                            Expanded(child: Text('hub_request'.tr(), style: _ts(15, w: FontWeight.w600, color: Colors.white))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  /// The program the person has started but not finished, if any.
  Widget _continue() {
    final courses = _courses;
    if (courses == null) return const SizedBox.shrink();
    Course? current;
    int total = 0, done = 0;
    for (final c in courses) {
      final t = c.steps.where((s) => s.number != null).length;
      final d = _done[c.id] ?? 0;
      if (d > 0 && d < t) {
        current = c;
        total = t;
        done = d;
        break;
      }
    }
    if (current == null) return const SizedBox.shrink();
    final course = current;
    return _block(
      title: 'hub_continue'.tr(),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openCourse(course),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: course.cover != null
                  ? Image.asset(course.cover!, width: getSize(50), height: getSize(50), fit: BoxFit.cover)
                  : Container(width: getSize(50), height: getSize(50), color: AppColors.primaryLight),
            ),
            SizedBox(width: getHorizontalSize(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.cardTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: _ts(14, w: FontWeight.w600)),
                  SizedBox(height: getVerticalSize(2)),
                  Text('hub_step_of'.tr(args: ['${done + 1}', '$total']),
                      style: _ts(12, color: AppColors.textSecondary)),
                  SizedBox(height: getVerticalSize(6)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: (done / total).clamp(0.0, 1.0),
                      minHeight: 3,
                      backgroundColor: AppColors.primaryLight,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: getHorizontalSize(10)),
            Container(
              width: getSize(36),
              height: getSize(36),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: getSize(22)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _programs() {
    final courses = _courses;
    if (courses == null || courses.isEmpty) return const SizedBox.shrink();
    return _block(
      title: 'hub_programs'.tr(),
      action: 'hub_all'.tr(),
      onAction: _openPrograms,
      // All courses in a row that scrolls sideways: the next card peeks in, and a
      // tap opens the course straight away.
      child: SizedBox(
        height: getVerticalSize(118),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          itemCount: courses.length,
          separatorBuilder: (_, __) => SizedBox(width: getHorizontalSize(8)),
          itemBuilder: (_, i) => SizedBox(width: getHorizontalSize(150), child: _programCard(courses[i])),
        ),
      ),
    );
  }

  Widget _programCard(Course c) {
    final total = c.steps.where((s) => s.number != null).length;
    final done = _done[c.id] ?? 0;
    return Semantics(
      button: true,
      label: c.cardTitle,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openCourse(c),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (c.cover != null)
                Image.asset(c.cover!, fit: BoxFit.cover)
              else
                Container(color: AppColors.primary),
              Container(color: const Color(0xFF0A181A).withOpacity(0.42)),
              Padding(
                padding: getPadding(left: 10, right: 10, bottom: 10),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.cardTitle,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: _ts(13, w: FontWeight.w600, color: Colors.white, height: 1.2)),
                      if (done > 0 && total > 0)
                        Text('course_progress_of'.tr(namedArgs: {'done': '$done', 'total': '$total'}),
                            style: _ts(11, color: const Color(0xFFDBE7E5))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emotions() {
    final tabs = NegativeEmotionTabs.tabs;
    // Every emotion in its own colour from the app's palette, two to a row,
    // so the tiles fill the block evenly. "Депрессия" stays reachable here
    // until it becomes a program.
    final tiles = <Widget>[
      for (final t in tabs)
        EmotionTile(label: t.title, color: emotionTileColor(t.tag), onTap: () => _openEmotion(t.tabIndex)),
      EmotionTile(label: 'depression'.tr(), color: emotionTileColor('depression'), onTap: _openDepression),
    ];
    final gap = getHorizontalSize(8);
    // A colourful backdrop that drifts slower than the page, so the glass tiles
    // have something that changes behind them as the screen moves.
    return Container(
      width: double.infinity,
      margin: getMargin(bottom: 14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: ParallaxBackdrop(asset: 'assets/images/hub/glass_backdrop.jpg')),
          Positioned.fill(child: Container(color: const Color(0xFF031A22).withOpacity(0.12))),
          Padding(
            padding: getPadding(left: 14, top: 14, right: 14, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('hub_emotions'.tr(), style: _ts(15, w: FontWeight.w600, color: Colors.white)),
                SizedBox(height: getVerticalSize(12)),
                for (var i = 0; i < tiles.length; i += 2)
                  Padding(
                    padding: EdgeInsets.only(bottom: i + 2 < tiles.length ? gap : 0),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: tiles[i]),
                          SizedBox(width: gap),
                          Expanded(child: i + 1 < tiles.length ? tiles[i + 1] : const SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _audioTile(String image, String title, VoidCallback onTap) => Expanded(
        child: Semantics(
          button: true,
          label: title,
          excludeSemantics: true,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: getVerticalSize(92),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(image, fit: BoxFit.cover),
                    Container(color: const Color(0xFF0A181A).withOpacity(0.4)),
                    Padding(
                      padding: getPadding(left: 10, right: 10, bottom: 9),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: _ts(13, w: FontWeight.w600, color: Colors.white)),
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

  Widget _audio() => _block(
        title: 'hub_audio'.tr(),
        child: Row(
          children: [
            _audioTile('assets/images/hub/star_08.jpg', 'introduction'.tr(), _openIntroduction),
            SizedBox(width: getHorizontalSize(8)),
            _audioTile('assets/images/hub/star_12.jpg', 'meditations'.tr(), _openMeditations),
          ],
        ),
      );

  Widget _b612Row(String title, String sub, VoidCallback onTap, {bool last = false}) => InkWell(
        onTap: onTap,
        child: Container(
          padding: getPadding(top: 11, bottom: 11),
          decoration: BoxDecoration(
            border: last ? null : const Border(bottom: BorderSide(color: Color(0xFFEFEDF7))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _ts(14, w: FontWeight.w600)),
                    Text(sub, style: _ts(12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: getSize(20), color: AppColors.violet),
            ],
          ),
        ),
      );

  /// The written practices. B-612 is the asteroid-home of the Little Prince:
  /// a warm place of one's own that these entries lead toward.
  Widget _b612() => Container(
        width: double.infinity,
        margin: getMargin(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // The planet picture is 16:10 and centred, so it fills the block
            // (cover); the name sits in the empty top-left sky.
            Container(
              height: getVerticalSize(210),
              width: double.infinity,
              color: const Color(0xFF011720),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/hub/b612_planet.jpg', fit: BoxFit.cover),
                  Padding(
                    padding: getPadding(left: 16, top: 14),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('hub_b612'.tr(), style: _ts(24, w: FontWeight.w600, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: getPadding(left: 14, right: 14, top: 2, bottom: 2),
              child: Column(
                children: [
                  _b612Row('breadcrumbs_exercise'.tr(), 'hub_b612_crumbs_sub'.tr(), _openCrumbs),
                  _b612Row('work_out_irrational'.tr(), 'hub_b612_irr_sub'.tr(), _openIrrational),
                  _b612Row('desires'.tr(), 'hub_b612_desires_sub'.tr(), _openDesires),
                  _b612Row('prestige_in_focus'.tr(), 'hub_b612_happy_sub'.tr(), _openHappiness, last: true),
                ],
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: getPadding(left: 16, right: 16, top: 12, bottom: 24),
      children: [
        HeroBanner(
          asset: 'assets/images/hub/star_06.jpg',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('hub_title'.tr(), style: AppStyle.txtH1.copyWith(color: Colors.white)),
            ],
          ),
        ),
        _sos(),
        _request(),
        FirstStepsChecklist(
          onNoteState: () {
            AppRoutes.currentRoute = AppRoutes.main;
            Navigator.pushNamed(context, AppRoutes.main);
          },
        ),
        _continue(),
        _programs(),
        _emotions(),
        _audio(),
        _b612(),
      ],
    );
  }
}
