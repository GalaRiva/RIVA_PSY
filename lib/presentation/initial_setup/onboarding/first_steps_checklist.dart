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
  const FirstStepsChecklist({Key? key, required this.onNoteState}) : super(key: key);

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
    return Padding(
      padding: getPadding(top: 8, bottom: 16),
      child: Container(
        width: double.infinity,
        padding: getPadding(left: 16, top: 14, right: 12, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColorConstant.cyan700.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'onb_steps_title'.tr()} · $count/3',
                style: AppStyle.txtSFProDisplayRegular11
                    .copyWith(color: ColorConstant.cyan700, letterSpacing: 0.4)),
            SizedBox(height: getVerticalSize(4)),
            for (var i = 0; i < steps.length; i++)
              Semantics(
                button: !done[i],
                label: '${steps[i].tr()}${done[i] ? ', ${'onb_steps_done'.tr()}' : ''}',
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: done[i] ? null : () => _open(i),
                  child: Padding(
                    padding: getPadding(top: 10, bottom: 10, right: 4),
                    child: Row(
                      children: [
                        Icon(
                          done[i] ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                          size: getSize(22),
                          color: done[i] ? ColorConstant.cyan700 : ColorConstant.cyan700.withOpacity(0.7),
                        ),
                        SizedBox(width: getHorizontalSize(12)),
                        Expanded(
                          child: Text(
                            steps[i].tr(),
                            style: AppStyle.txtSFProDisplayLight16.copyWith(
                              color: done[i] ? ColorConstant.gray500 : ColorConstant.gray800,
                              decoration: done[i] ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        if (!done[i])
                          Icon(Icons.chevron_right_rounded, size: getSize(22), color: ColorConstant.cyan700),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
