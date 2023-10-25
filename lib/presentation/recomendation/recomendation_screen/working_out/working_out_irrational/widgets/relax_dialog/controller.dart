import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../core/models/audio/audio.dart';
import '../../../../../../../core/models/audio/audio_card_model.dart';
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
              ? 'http://95.181.164.171/' +
              e.fileName +
              '.' +
              e.format
              : '${(await getApplicationDocumentsDirectory()).path}/${e
              .folder}/${e.fileName}.${e.format}'));
    }
    return list;
  }

  Future<List<Duration?>> durations(List<AudioCardModel> audios) async {
    final List<Duration?> list = [];
    for (var item in audios) {
      print(item.audioAsset.replaceAll(' ', '%20'));
      try {
        if (DataSourceService.dataSourceIsRemote()) {
          list.add(await audioInstance.setUrl(
              item.audioAsset.replaceAll(' ', '%20'),
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