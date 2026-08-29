import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/core/models/event_model.dart';
import 'package:riva_psy/presentation/main/path/first_thougths_screen/repository.dart';

import '../../bloc/guided_journals_cubit.dart';
import '../../bloc/guided_journals_state.dart';
import '../../widgets/guided_journal_audio_player.dart';

class GuidedJournalInsightPage extends StatefulWidget {
  const GuidedJournalInsightPage({Key? key}) : super(key: key);

  @override
  State<GuidedJournalInsightPage> createState() => _GuidedJournalInsightPageState();
}

class _GuidedJournalInsightPageState extends State<GuidedJournalInsightPage> {
  bool _saved = false;
  bool _saving = false;

  Future<void> _saveAsDiaryEntry(String topicTitle, List<String> questions, List<String> answers) async {
    setState(() => _saving = true);
    final entryText = List.generate(
      questions.length,
      (i) => '${questions[i]}\n${answers.length > i ? answers[i] : ''}',
    ).join('\n\n');
    final repo = K38Repo();
    final events = await repo.getEvent();
    // The Records screen, record-edit screen, PDF report, and Charts tab
    // all read whatHappened/whereHappened/whoDidItHappen/whatEmotion with
    // a bare `!` (no null guard) — a DayEventModel that only sets
    // firstThoughts crashes the very first screen it's opened from. Empty
    // placeholders (EventModel with no key, so localizedName just returns
    // the empty name — no .tr() lookup) satisfy those non-null reads
    // without inventing fake "what happened"/"where" content.
    events.add(DayEventModel(
      date: DateTime.now(),
      firstThoughts: '$topicTitle\n\n$entryText',
      showInCharts: true,
      whatHappened: EventModel(topicTitle, ''),
      whereHappened: EventModel('', ''),
      whoDidItHappen: EventModel('', ''),
      whatEmotion: [EventModel(topicTitle, '')],
      whatBodyParts: const [],
    ));
    await repo.updateEvent(events);
    if (mounted) setState(() { _saving = false; _saved = true; });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GuidedJournalsCubit, GuidedJournalsState>(
      builder: (context, state) {
        final topic = state.selectedTopic;
        if (topic == null) return const SizedBox.shrink();
        final cubit = context.read<GuidedJournalsCubit>();
        return SingleChildScrollView(
          child: Padding(
            padding: getPadding(left: 16, right: 16, top: 4, bottom: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic.title, style: AppStyle.txtH1),
                SizedBox(height: getVerticalSize(20)),
                Container(
                  width: double.infinity,
                  padding: getPadding(left: 16, right: 16, top: 18, bottom: 18),
                  decoration: BoxDecoration(
                    color: ColorConstant.grayLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    topic.insight,
                    style: AppStyle.txtSFProDisplayLight16.copyWith(height: 1.5),
                  ),
                ),
                SizedBox(height: getVerticalSize(20)),
                if (state.resolvingAudio)
                  Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: ColorConstant.cyan700),
                    ),
                  )
                else if ((state.audioUrl ?? '').isNotEmpty)
                  GuidedJournalAudioPlayer(url: state.audioUrl!),
                SizedBox(height: getVerticalSize(28)),
                CustomButton(
                  text: (_saved ? 'guided_journal_saved_to_diary' : 'guided_journal_save_to_diary')
                      .tr()
                      .toUpperCase(),
                  width: double.infinity,
                  height: 47,
                  fontStyle: ButtonFontStyle.SFProDisplayRegular12Cyan700,
                  onTap: (_saved || _saving)
                      ? null
                      : () => _saveAsDiaryEntry(topic.title, topic.questions, state.answers),
                ),
                SizedBox(height: getVerticalSize(12)),
                CustomButton(
                  text: 'guided_journal_back_to_library'.tr().toUpperCase(),
                  width: double.infinity,
                  height: 47,
                  showBorder: false,
                  bgColor: Colors.transparent,
                  textStyle: AppStyle.txtSFProDisplayLight16DeepPurple,
                  onTap: cubit.backToLibrary,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
