import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/notifications/reengagement_scheduler.dart';
import '../../../core/user_data/user.dart';
import '../../../theme/app_colors.dart';
import '../../recomendation/recomendation_screen/working_out/guided_journals/data/guided_journals_repository.dart';
import '../../recomendation/recomendation_screen/working_out/guided_journals/guided_journal_topic_screen.dart';
import '../../recomendation/recomendation_screen/working_out/guided_journals/models/guided_journal_topic.dart';
import 'onboarding_concern.dart';

// Home-screen card that follows the onboarding answer: "Your next step" =
// the "Хлебные крошки" topic matched to what the person said was hardest.
// Hidden when there was no answer, the answer has no topic ("не знаю"), the
// topic was already completed, or the person dismissed it.
class NextStepCard extends StatefulWidget {
  const NextStepCard({Key? key}) : super(key: key);

  @override
  State<NextStepCard> createState() => _NextStepCardState();
}

class _NextStepCardState extends State<NextStepCard> {
  GuidedJournalTopic? _topic;
  // True when the topic would be paywalled in the library — the card then
  // says it is open for free once, and the launcher is given the free pass.
  bool _freeOnce = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (await OnboardingPrefs.nextStepHidden()) return;
      final concern = await OnboardingPrefs.concern();
      final topicId = concern?.journalTopicId;
      if (topicId == null) return;
      final topics = await GuidedJournalsRepository().getTopics();
      final index = topics.indexWhere((t) => t.id == topicId);
      if (index < 0 || !mounted) return;
      // Cached so the local 3-day "come back" notification can name a real,
      // unfinished topic without a network call (ReengagementScheduler).
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ReengagementScheduler.topicTitlePrefsKey, topics[index].title);
      setState(() {
        _topic = topics[index];
        _freeOnce = index >= kGuidedJournalFreeTopicCount && !CurrentUser.tariffIsOrion();
      });
    } catch (_) {
      // Card is a nicety — never block the home screen on it.
    }
  }

  @override
  Widget build(BuildContext context) {
    final topic = _topic;
    if (topic == null) return const SizedBox.shrink();
    return Padding(
      padding: getPadding(top: 12, bottom: 4),
      child: Semantics(
        button: true,
        label: '${'onb_next_step_eyebrow'.tr()}: ${topic.title}',
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => GuidedJournalTopicScreen(topicId: topic.id, freePass: true)),
            );
            if (!mounted) return;
            if (await OnboardingPrefs.nextStepHidden() && mounted) {
              setState(() => _topic = null);
            }
          },
          child: Container(
            width: double.infinity,
            padding: getPadding(left: 16, top: 14, right: 8, bottom: 14),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColorConstant.cyan700.withOpacity(0.35), width: 1.2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('onb_next_step_eyebrow'.tr().toUpperCase(),
                          style: AppStyle.txtSFProDisplayRegular11
                              .copyWith(color: ColorConstant.cyan700, letterSpacing: 0.6)),
                      SizedBox(height: getVerticalSize(4)),
                      Text(topic.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyle.txtSFProDisplayLight16
                              .copyWith(color: ColorConstant.gray800, fontWeight: FontWeight.w600)),
                      SizedBox(height: getVerticalSize(2)),
                      Text(
                          _freeOnce ? 'onb_next_step_free'.tr() : 'onb_next_step_subtitle'.tr(),
                          style: AppStyle.txtSFProDisplayRegular11Gray800),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'close'.tr(),
                  icon: Icon(Icons.close_rounded, size: getSize(18), color: ColorConstant.gray500),
                  onPressed: () async {
                    await OnboardingPrefs.dismissNextStep();
                    if (mounted) setState(() => _topic = null);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
