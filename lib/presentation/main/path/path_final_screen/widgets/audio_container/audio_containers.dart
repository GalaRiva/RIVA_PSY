import 'package:flutter/material.dart';

import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../core/services/audio/app_audio_track.dart';
import '../../../../../../core/utils/audio_cover_map.dart';
import '../../../../../../theme/app_colors.dart';
import '../../../../../../widgets/soft_audio_card.dart';

class AudioContainers extends StatefulWidget {
  final List<AudioCardModel> audios;
  final int startIndex;
  const AudioContainers({Key? key, required this.audios, this.startIndex = 0}) : super(key: key);

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
      // stored in Firestore) — skip the network probe entirely. Falls
      // back to a one-off, disposable-player probe (not the shared
      // AppAudioService) for the rare track without one.
      list.add(item.knownDuration ?? await AudioCacheManager.probeDuration(item.audioAsset));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final audios = widget.audios;

    // Natural height: the soft cards grow with their titles, so there is no
    // fixed row height to keep in lockstep any more.
    return Container(
      width: size.width,
      color: AppColors.screenWarm,
      child: FutureBuilder(
        future: _durationsFuture,
        builder: (context, AsyncSnapshot<List<Duration?>>snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: Padding(
                padding: getPadding(top: 24, bottom: 24),
                child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(color: ColorConstant.cyan700,)),
              ),
            );
          }
          return Padding(
            padding: getPadding(left: 12, right: 12, top: 12, bottom: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List<Widget>.generate(audios.length, (index) => SoftAudioCard(
                text: audios[index].title,
                track: AppAudioTrack.forUrl(
                  audios[index].audioAsset,
                  title: audios[index].title,
                  coverAsset: audioCoverAsset(audios[index].ruTitle),
                ),
                maxDuration: (snapshot.data)?[index] ?? Duration.zero,
              )),
            ),
          );
        },
      )
    );
  }
}
