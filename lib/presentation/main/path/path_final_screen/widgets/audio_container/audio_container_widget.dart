import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../widgets/audio_card_widget.dart';
import '../exercise_content/controller.dart';

class AudioContainerWidget extends StatelessWidget {
  final AudioCardModel audioCardModel;
  final int index;
  final int currentAudioIndex;
  final AudioPlayer audioPlayer;
  final Duration maxDuration;
  final Function? update;

  const AudioContainerWidget(
      {Key? key,
      required this.audioCardModel,
      required this.index,
      required this.audioPlayer,
      required this.maxDuration, required this.currentAudioIndex, required this.update})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: getVerticalSize(95),
      child: Center(
        child: AudioCardWidget(
          text: audioCardModel.title,
          index: index,
          audioInstance: audioPlayer,
          maxDuration: maxDuration,
          currentAudioIndex: currentAudioIndex,
          playFun: (val) async {

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
          },
        ),
      ),
    );
  }
}
