import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../core/db/hive_db.dart';
import '../../../theme/app_colors.dart';
import '../../recomendation/recomendation_screen/working_out/guided_journals/guided_journal_topic_screen.dart';
import '../../main/path/path_final_screen/repository.dart';
import 'onboarding_concern.dart';
import 'onboarding_flow.dart';

// "Первые шаги": three small, real milestones shown on the home screen for
// after the new onboarding — note a state, do a practice,
// write a journal entry. Only for installs that went through the new
// onboarding (OnboardingPrefs.startedAt != null), never for existing users.
// Stays until all three are done — it is not dismissible and does not expire.
// Tapping a step opens the screen where it is done; the tick appears by itself
// once the action really happened (no ticking without doing).
class FirstStepsChecklist extends StatefulWidget {
  /// Opens the "note your state" path (supplied by the home screen, which
  /// owns the slider value).
  final VoidCallback onNoteState;

  /// Home screen: one quiet line ("Первые шаги, 1 из 3") that opens the
  /// practices hub, where the full list lives. Otherwise the full block
  /// ("Начните здесь") with the three steps.
  final bool compact;
  const FirstStepsChecklist({Key? key, required this.onNoteState, this.compact = false}) : super(key: key);

  @override
  State<FirstStepsChecklist> createState() => _FirstStepsChecklistState();
}

class _FirstStepsChecklistState extends State<FirstStepsChecklist> with WidgetsBindingObserver {
  List<bool>? _done;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    OnboardingPrefs.changes.addListener(_onChanged);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    OnboardingPrefs.changes.removeListener(_onChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _load();
  }

  // Event writes finish a moment after the notification fires.
  void _onChanged() => Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) _load();
      });

  Future<void> _load() async {
    try {
      final started = await OnboardingPrefs.startedAt();
      if (started == null) return;
      // Only entries with a mood count as "noted a state" — journal and course
      // entries written to the diary carry no mood.
      final noted = (await K39Repo().getEvent()).any((e) => e.howDoYouFeel != null);
      final journals = await HiveDB.getBox(HiveDBTags.guidedJournalAnswers);
      final done = [
        noted,
        await OnboardingPrefs.firstPracticeDone(),
        journals.isNotEmpty || await OnboardingPrefs.nextStepDone(),
      ];
      if (!mounted) return;
      setState(() => _done = done.every((d) => d) ? null : done);
    } catch (_) {
      // A nicety — never block the home screen.
    }
  }

  Future<void> _open(int i) async {
    switch (i) {
      case 0:
        widget.onNoteState();
        break;
      case 1:
        final concern = await OnboardingPrefs.concern();
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => concern == null
                  ? const OnboardingConcernScreen(fromSettings: true)
                  : OnboardingPracticeScreen(concern: concern, fromSettings: true)),
        );
        break;
      default:
        final concern = await OnboardingPrefs.concern();
        if (!mounted) return;
        final topicId = concern?.journalTopicId;
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => topicId == null
                  ? const OnboardingConcernScreen(fromSettings: true)
                  : GuidedJournalTopicScreen(topicId: topicId, freePass: true)),
        );
    }
    if (mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    final done = _done;
    if (done == null) return const SizedBox.shrink();
    final steps = ['onb_steps_step1', 'onb_steps_step2', 'onb_steps_step3'];
    final count = done.where((d) => d).length;
    return widget.compact ? _compactLine(context, done, steps, count) : _block(context, done, steps, count);
  }

  // Home: one soft violet line instead of a three-row block.
  Widget _compactLine(BuildContext context, List<bool> done, List<String> steps, int count) {
    final next = done.indexWhere((d) => !d);
    return Padding(
      padding: getPadding(top: 8, bottom: 16),
      child: Semantics(
        button: true,
        label: 'steps_line_title'.tr(args: ['$count']),
        excludeSemantics: true,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            AppRoutes.currentRoute = AppRoutes.recommendations;
            Navigator.pushNamed(context, AppRoutes.recommendations);
          },
          child: Container(
            width: double.infinity,
            padding: getPadding(left: 12, top: 10, right: 12, bottom: 10),
            decoration: BoxDecoration(
              color: AppColors.violetSoft,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.violetLine),
            ),
            child: Row(
              children: [
                Container(
                  width: getSize(34),
                  height: getSize(34),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.auto_awesome_rounded, size: getSize(18), color: AppColors.violet),
                ),
                SizedBox(width: getHorizontalSize(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('steps_line_title'.tr(args: ['$count']),
                          style: AppStyle.txtSFProDisplayRegular11.copyWith(
                              fontSize: getFontSize(14), fontWeight: FontWeight.w600, color: AppColors.violetDeep)),
                      if (next >= 0)
                        Text('steps_line_next'.tr(args: [steps[next].tr()]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppStyle.txtSFProDisplayRegular11
                                .copyWith(fontSize: getFontSize(12), color: AppColors.violet)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: getSize(22), color: AppColors.violet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Practices hub, "Начните здесь": the three steps with a small picture.
  Widget _block(BuildContext context, List<bool> done, List<String> steps, int count) {
    return Container(
      width: double.infinity,
      margin: getMargin(bottom: 14),
      padding: getPadding(left: 14, top: 12, right: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('hub_start'.tr(),
                    style: AppStyle.txtSFProDisplayRegular11.copyWith(
                        fontSize: getFontSize(15), fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              ),
              Text('$count/3',
                  style: AppStyle.txtSFProDisplayRegular11
                      .copyWith(fontSize: getFontSize(13), color: AppColors.primary)),
            ],
          ),
          SizedBox(height: getVerticalSize(4)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < steps.length; i++)
                      Semantics(
                        button: !done[i],
                        label: '${steps[i].tr()}${done[i] ? ', ${'onb_steps_done'.tr()}' : ''}',
                        excludeSemantics: true,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: done[i] ? null : () => _open(i),
                          child: Padding(
                            padding: getPadding(top: 9, bottom: 9, right: 4),
                            child: Row(
                              children: [
                                Icon(
                                  done[i] ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  size: getSize(22),
                                  color: AppColors.primary.withOpacity(done[i] ? 1 : 0.7),
                                ),
                                SizedBox(width: getHorizontalSize(10)),
                                Expanded(
                                  child: Text(
                                    steps[i].tr(),
                                    style: AppStyle.txtSFProDisplayLight16.copyWith(
                                      fontSize: getFontSize(14),
                                      color: done[i] ? AppColors.textSecondary : AppColors.textPrimary,
                                      decoration: done[i] ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                ),
                                if (!done[i])
                                  Icon(Icons.chevron_right_rounded, size: getSize(20), color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(width: getHorizontalSize(8)),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset('assets/images/hub/star_02.jpg',
                    width: getSize(64), height: getSize(100), fit: BoxFit.cover),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
