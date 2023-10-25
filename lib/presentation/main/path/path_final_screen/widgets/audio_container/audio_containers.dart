import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';
import 'audio_container_widget.dart';
import '../exercise_content/controller.dart';

class AudioContainers extends StatelessWidget {
  final List<AudioCardModel> audios;
  final int startIndex;
  final ExerciseContentController controller;
  const AudioContainers({Key? key, required this.audios, this.startIndex = 0, required this.controller}) : super(key: key);

  Future<List<Duration?>> _durations () async {
    final List<Duration?> list = [];
    for (var item in audios) {
      print(item.audioAsset.replaceAll(' ', '%20'));
      try {
        if (DataSourceService.dataSourceIsRemote()) {
          list.add(await controller.audioInstance.setUrl(
              item.audioAsset.replaceAll(' ', '%20'), initialPosition: Duration.zero, preload: true));
        } else
          list.add(await controller.audioInstance.setAudioSource(
              AudioSource.file(item.audioAsset),
              initialPosition: Duration.zero));} catch (_) {
        list.add(null);
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: getVerticalSize(95 * audios.length.toDouble()),
      width: size.width,
      color:  ColorConstant.fromHex('#E7EAEA'),
      child: FutureBuilder(
        future: Future<List<Duration?>>.delayed(Duration(seconds: startIndex,) ,() {
          return _durations();
        }),
        builder: (context, AsyncSnapshot<List<Duration?>>snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(color: ColorConstant.cyan700,)),
            );
          }
          print(audios);
          return Padding(
            padding: getPadding( left: 10, right: 10),
            child: Wrap(
              children: List<Widget>.generate(audios.length, (index) => AudioContainerWidget(audioCardModel: audios[index], index: startIndex + index, audioPlayer: controller.audioInstance, maxDuration: (snapshot.data)?[index] ?? Duration.zero, currentAudioIndex: controller.currentAudioIndex, update: () => controller.update())),
            ),
          );
        },
      )
    );
  }
}
