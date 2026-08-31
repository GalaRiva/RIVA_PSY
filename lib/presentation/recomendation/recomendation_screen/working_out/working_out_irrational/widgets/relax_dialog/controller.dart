import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../core/models/audio/audio.dart';
import '../../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../../../core/services/datasource_service.dart';

class RelaxDialogController extends GetxController {
  int currentAudioIndex = 0;

  AudioPlayer audioInstance = AudioPlayer(
      audioLoadConfiguration: AudioLoadConfiguration(
          androidLoadControl: AndroidLoadControl(

          )));

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
          knownDuration: e.localizedDuration('ru')));
    }
    return list;
  }

  Future<List<Duration?>> durations(List<AudioCardModel> audios) async {
    final List<Duration?> list = [];
    for (var item in audios) {
      // Known ahead of time (Audio.duration_ms, precomputed once and
      // stored in Firestore) — skip the network probe entirely.
      if (item.knownDuration != null) {
        list.add(item.knownDuration);
        continue;
      }
      try {
        if (DataSourceService.dataSourceIsRemote()) {
          list.add(await audioInstance.setAudioSource(
              await AudioCacheManager.sourceFor(item.audioAsset.replaceAll(' ', '%20')),
              initialPosition: Duration.zero, preload: true));
        } else
          list.add(await audioInstance.setAudioSource(
              AudioSource.file(item.audioAsset),
              initialPosition: Duration.zero));
      } catch (_) {
        list.add(null);
      }
    }

    return list;
  }
}