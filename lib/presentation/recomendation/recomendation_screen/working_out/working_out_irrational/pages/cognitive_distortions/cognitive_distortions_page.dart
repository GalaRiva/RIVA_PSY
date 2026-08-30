import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../guided_journals/widgets/guided_journal_audio_player.dart';
import 'cognitive_distortion_option.dart';
import 'recommended_distortion_audio.dart';

// Optional naming step between "Оспорить мысль" and writing out why —
// lets the user attach standard CBT vocabulary (Beck/Burns) to the
// automatic thought they just confirmed, before explaining it. Entirely
// skippable; nothing here blocks the exercise.
class CognitiveDistortionsPage extends StatefulWidget {
  @override
  State<CognitiveDistortionsPage> createState() =>
      _CognitiveDistortionsPageState();
}

class _CognitiveDistortionsPageState extends State<CognitiveDistortionsPage> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final cubit = context.read<WorkingOutIrrationalCubit>();
    _selected = Set<String>.from(
        cubit.state.spendRecordModel?.cognitiveDistortions ?? const <String>[]);
  }

  void _continue({required bool skip}) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    cubit.fillSpendRecordModel(
      cognitiveDistortions: skip ? const <String>[] : _selected.toList(),
    );
    cubit.goToNextState(WorkingOutIrrationalStage.recordThought);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('cognitive_distortions_title'.tr(), style: AppStyle.txtH1),
            SizedBox(height: 8),
            Text('cognitive_distortions_subtitle'.tr(),
                style: AppStyle.txtSFProDisplayLight14Gray800),
            SizedBox(height: 20),
            ..._buildOptionWidgets(),
            if (_selected.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Text(
                  'cognitive_distortions_warm_note'.tr(),
                  style: AppStyle.txtSFProDisplayLight14Gray800
                      .copyWith(fontStyle: FontStyle.italic),
                ),
              )
            else
              SizedBox(height: 16),
            CustomButton(
              text: 'continue'.tr().toUpperCase(),
              width: double.infinity,
              height: 47,
              variant: ButtonVariant.Cyan,
              fontStyle: ButtonFontStyle.White16,
              onTap: () => _continue(skip: false),
            ),
            SizedBox(height: 6),
            CustomButton(
              text: 'cognitive_distortions_skip'.tr().toUpperCase(),
              fontStyle: ButtonFontStyle.DeepPurple16,
              onTap: () => _continue(skip: true),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOptionWidgets() {
    final widgets = <Widget>[];
    String? lastGroup;
    for (final option in CognitiveDistortionOption.all) {
      if (option.groupKey != null && option.groupKey != lastGroup) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Text(
            'cognitive_distortion_group_${option.groupKey}'.tr(),
            style: AppStyle.txtSFProDisplayLight12
                .copyWith(color: ColorConstant.gray800),
          ),
        ));
      }
      lastGroup = option.groupKey;
      widgets.add(_buildCard(option));
    }
    return widgets;
  }

  Widget _buildCard(CognitiveDistortionOption option) {
    final selected = _selected.contains(option.key);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(3),
        onTap: () => setState(() {
          if (selected) {
            _selected.remove(option.key);
          } else {
            _selected.add(option.key);
          }
        }),
        child: Container(
          decoration: BoxDecoration(
            color: ColorConstant.cardShadow,
            borderRadius: BorderRadius.circular(3),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: selected,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _selected.add(option.key);
                    } else {
                      _selected.remove(option.key);
                    }
                  }),
                  checkColor: Colors.white,
                  activeColor: ColorConstant.cyan700,
                  side: BorderSide(color: ColorConstant.gray800),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('cognitive_distortion_${option.key}_title'.tr(),
                        style: AppStyle.txtSFProDisplayLight16),
                    SizedBox(height: 4),
                    Text('cognitive_distortion_${option.key}_definition'.tr(),
                        style: AppStyle.txtSFProDisplayLight14Gray800),
                    SizedBox(height: 4),
                    Text(
                      '«${'cognitive_distortion_${option.key}_example'.tr()}»',
                      style: AppStyle.txtSFProDisplayLight12.copyWith(
                          color: ColorConstant.gray800,
                          fontStyle: FontStyle.italic),
                    ),
                    if (selected &&
                        RecommendedDistortionAudio.hasRecommendation(option.key))
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _RecommendedAudio(distortionKey: option.key),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A direct, specific audio recommendation for the one or two distortions
// that have one (currently just catastrophizing -> "Возврат в сейчас") —
// shown once the card is checked, not for every distortion.
class _RecommendedAudio extends StatelessWidget {
  final String distortionKey;
  const _RecommendedAudio({required this.distortionKey});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: RecommendedDistortionAudio.urlFor(distortionKey),
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null || url.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'cognitive_distortion_recommended_audio'.tr(),
              style: AppStyle.txtSFProDisplayLight12
                  .copyWith(color: ColorConstant.gray800),
            ),
            SizedBox(height: 6),
            GuidedJournalAudioPlayer(url: url),
          ],
        );
      },
    );
  }
}
