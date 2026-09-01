import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/services/audio/app_audio_track.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../widgets/audio_card_widget.dart';

class AudioContainerWidget extends StatelessWidget {
  final AudioCardModel audioCardModel;
  final Duration maxDuration;

  const AudioContainerWidget({
    Key? key,
    required this.audioCardModel,
    required this.maxDuration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      // 80 (AudioCardWidget content) + 23 (its own bottom spacing, ~1.5x
      // the old implicit 15px gap) — must stay in lockstep with the
      // AudioContainers total-height formula below, or later rows clip.
      height: getVerticalSize(103),
      child: Center(
        child: AudioCardWidget(
          text: audioCardModel.title,
          track: AppAudioTrack.forUrl(audioCardModel.audioAsset, title: audioCardModel.title),
          maxDuration: maxDuration,
        ),
      ),
    );
  }
}
