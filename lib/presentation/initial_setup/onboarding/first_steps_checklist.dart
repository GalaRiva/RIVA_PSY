import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../core/db/hive_db.dart';
import '../../../theme/app_colors.dart';
import 'onboarding_concern.dart';

// "Первые шаги": three small, real milestones shown on the home screen for
// the first 7 days after the new onboarding — note a state, do a practice,
// write a journal entry. Only for installs that went through the new
// onboarding (OnboardingPrefs.startedAt != null), never for existing users.
// Disappears when all three are done, after 7 days, or when dismissed.
class FirstStepsChecklist extends StatefulWidget {
  const FirstStepsChecklist({Key? key}) : super(key: key);

  @override
  State<FirstStepsChecklist> createState() => _FirstStepsChecklistState();
}

class _FirstStepsChecklistState extends State<FirstStepsChecklist> {
  List<bool>? _done;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final started = await OnboardingPrefs.startedAt();
      if (started == null) return;
      if (DateTime.now().difference(started) > const Duration(days: 7)) return;
      if (await OnboardingPrefs.checklistDismissed()) return;
      final events = await HiveDB.getBox(HiveDBTags.dayEvents);
      final journals = await HiveDB.getBox(HiveDBTags.guidedJournalAnswers);
      final done = [
        events.isNotEmpty,
        await OnboardingPrefs.firstPracticeDone(),
        journals.isNotEmpty || await OnboardingPrefs.nextStepDone(),
      ];
      if (done.every((d) => d)) return;
      if (mounted) setState(() => _done = done);
    } catch (_) {
      // A nicety — never block the home screen.
    }
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
        padding: getPadding(left: 16, top: 12, right: 6, bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: ColorConstant.cyan700.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('${'onb_steps_title'.tr()} · $count/3',
                      style: AppStyle.txtSFProDisplayRegular11
                          .copyWith(color: ColorConstant.cyan700, letterSpacing: 0.4)),
                ),
                IconButton(
                  tooltip: 'close'.tr(),
                  icon: Icon(Icons.close_rounded, size: getSize(16), color: ColorConstant.gray500),
                  onPressed: () async {
                    await OnboardingPrefs.dismissChecklist();
                    if (mounted) setState(() => _done = null);
                  },
                ),
              ],
            ),
            for (var i = 0; i < steps.length; i++)
              Padding(
                padding: getPadding(top: 4, bottom: 4),
                child: Semantics(
                  label: '${steps[i].tr()}${done[i] ? ', ${'onb_steps_done'.tr()}' : ''}',
                  excludeSemantics: true,
                  child: Row(
                    children: [
                      Icon(
                        done[i] ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: getSize(18),
                        color: done[i] ? ColorConstant.cyan700 : ColorConstant.gray500,
                      ),
                      SizedBox(width: getHorizontalSize(10)),
                      Expanded(
                        child: Text(
                          steps[i].tr(),
                          style: AppStyle.txtSFProDisplayLight16.copyWith(
                            color: done[i] ? ColorConstant.gray500 : ColorConstant.gray800,
                            decoration: done[i] ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
