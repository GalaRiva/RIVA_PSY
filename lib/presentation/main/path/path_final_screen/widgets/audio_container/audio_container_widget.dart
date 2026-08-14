import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../widgets/audio_card_widget.dart';
import '../exercise_content/controller.dart';

class AudioContainerWidget extends StatelessWidget {
  final AudioCardModel audioCardModel;
  final int index;
  final int Function() currentAudioIndex;
  final AudioPlayer audioPlayer;
  final Duration maxDuration;
  final Function? update;
  final Function(int index) changeAudioIndex;

   AudioContainerWidget(
      {Key? key,
      required this.audioCardModel,
      required this.index,
      required this.audioPlayer,
      required this.maxDuration, required this.currentAudioIndex, required this.update, required this.changeAudioIndex})
      : super(key: key);

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
          index: index,
          audioInstance: audioPlayer,
          maxDuration: maxDuration,
          currentAudioIndex: currentAudioIndex,
          playFun: (val) async {
            changeAudioIndex(index);
            if(DataSourceService.dataSourceIsRemote()) {
              await audioPlayer.setUrl(audioCardModel.audioAsset, initialPosition: val);
            } else
              await audioPlayer.setAudioSource(AudioSource.file(audioCardModel.audioAsset), initialPosition: val);

            await audioPlayer.play();
          },
          stopFun: () async {
            await audioPlayer.pause();
          },
          loadFun: () async {},
          onChange: (Duration duration) async {
            await audioPlayer.seek(duration);
            update!();
          }, changeCurrentAudioIndex: (int index) { changeAudioIndex(index); },
        ),
      ),
    );
  }
}
