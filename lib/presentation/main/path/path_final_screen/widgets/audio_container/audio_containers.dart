import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';
import 'audio_container_widget.dart';
import '../exercise_content/controller.dart';

class AudioContainers extends StatefulWidget {
  final List<AudioCardModel> audios;
  final int startIndex;
  final ExerciseContentController controller;
  const AudioContainers({Key? key, required this.audios, this.startIndex = 0, required this.controller}) : super(key: key);

  @override
  State<AudioContainers> createState() => _AudioContainersState();
}

class _AudioContainersState extends State<AudioContainers> {
  // Created once in initState, not inline in build() — a fresh Future
  // there restarted the whole (delayed) duration probe from scratch on
  // every rebuild the parent triggered, not just when audios actually
  // changed.
  late final Future<List<Duration?>> _durationsFuture = Future<List<Duration?>>.delayed(
    Duration(seconds: widget.startIndex),
    _durations,
  );

  Future<List<Duration?>> _durations() async {
    final List<Duration?> list = [];
    for (var item in widget.audios) {
      // Known ahead of time (Audio.duration_ms, precomputed once and
      // stored in Firestore) — skip the network probe entirely.
      if (item.knownDuration != null) {
        list.add(item.knownDuration);
        continue;
      }
      try {
        if (DataSourceService.dataSourceIsRemote()) {
          list.add(await widget.controller.audioInstance.setAudioSource(
              await AudioCacheManager.sourceFor(item.audioAsset),
              initialPosition: Duration.zero, preload: true));
        } else
          list.add(await widget.controller.audioInstance.setAudioSource(
              AudioSource.file(item.audioAsset),
              initialPosition: Duration.zero));
      } catch (_) {
        list.add(null);
      }
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final audios = widget.audios;
    final controller = widget.controller;

    // Must match AudioContainerWidget's per-row height (103) or later rows
    // in this Wrap get clipped.
    return Container(
      height: getVerticalSize(103 * audios.length.toDouble()),
      width: size.width,
      color:  ColorConstant.fromHex('#E7EAEA'),
      child: FutureBuilder(
        future: _durationsFuture,
        builder: (context, AsyncSnapshot<List<Duration?>>snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(color: ColorConstant.cyan700,)),
            );
          }
          return Padding(
            padding: getPadding( left: 10, right: 10),
            child: Wrap(
              children: List<Widget>.generate(audios.length, (index) => AudioContainerWidget(audioCardModel: audios[index], index: widget.startIndex + index, audioPlayer: controller.audioInstance, maxDuration: (snapshot.data)?[index] ?? Duration.zero, currentAudioIndex: () => controller.currentAudioIndex, update: () => controller.update(), changeAudioIndex: (int index) { controller.currentAudioIndex = index; },)),
            ),
          );
        },
      )
    );
  }
}
