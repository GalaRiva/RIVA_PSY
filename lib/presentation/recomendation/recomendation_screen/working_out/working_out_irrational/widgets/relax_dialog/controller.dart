import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../core/models/audio/audio.dart';
import '../../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../../../core/services/datasource_service.dart';

class RelaxDialogController extends GetxController {
  Future<List<AudioCardModel>> loadAudios() async {
    var collectionAudio =
        (await FirebaseFirestore.instance.collection('Audio').where(
            'name', isEqualTo: 'Мыльный пузырь').get()).docs;
    var scollectionAudio =
        (await FirebaseFirestore.instance.collection('Audio').where(
            'name', isEqualTo: 'Стоп мысль').get()).docs;
    var audios =
    (collectionAudio + scollectionAudio)
        .map((e) => Audio.fromJson(e.data()))
        .toList();
    final List<AudioCardModel> list = [];
    for (var e in audios) {
      list.add(AudioCardModel(
          e.name,
          DataSourceService.dataSourceIsRemote()
              ? 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/' +
              e.fileName +
              '.' +
              e.format
              : '${(await getApplicationDocumentsDirectory()).path}/${e
              .folder}/${e.fileName}.${e.format}',
          ruTitle: e.name,
          knownDuration: e.localizedDuration('ru')));
    }
    return list;
  }

  Future<List<Duration?>> durations(List<AudioCardModel> audios) async {
    final List<Duration?> list = [];
    for (var item in audios) {
      // Known ahead of time (Audio.duration_ms, precomputed once and
      // stored in Firestore) — skip the network probe entirely. Falls
      // back to a one-off, disposable-player probe for the rare track
      // without one.
      list.add(item.knownDuration ?? await AudioCacheManager.probeDuration(item.audioAsset.replaceAll(' ', '%20')));
    }

    return list;
  }
}
