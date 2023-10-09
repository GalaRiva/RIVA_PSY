import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../../core/models/audio/audio.dart';
import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/models/day_event_model.dart';
import '../../../../../../core/models/event_model.dart';
import '../../../../../../core/services/datasource_service.dart';
import 'package:path_provider/path_provider.dart';

class ExerciseContentController extends GetxController {
  ExerciseContentController();

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    audioInstance.dispose();
  }

  int currentAudioIndex = 0;

  AudioPlayer audioInstance = AudioPlayer(
      audioLoadConfiguration: AudioLoadConfiguration(
          androidLoadControl: AndroidLoadControl(

  )));

  List<AudioCardModel> mainAudios = [];
  EventModel? mainEmotion;
  List<AudioCardModel> additionalAudios = [];
  List<EventModel>? additionalEmotions;
  DayEventModel? dayEvent;

  Future getAudios() async {
    audioInstance = AudioPlayer(

        audioLoadConfiguration: AudioLoadConfiguration(
            androidLoadControl: AndroidLoadControl(
              maxBufferDuration: Duration(seconds: 300),
              bufferForPlaybackDuration: Duration(seconds: 5),
              bufferForPlaybackAfterRebufferDuration: Duration(seconds: 10),
            )
        ));
    mainAudios = [];
    var collectionAudio =
        await FirebaseFirestore.instance.collection('Audio').get();
    var audios =
        collectionAudio.docs.map((e) => Audio.fromJson(e.data())).toList();
    mainEmotion = dayEvent!.whatEmotion![0];
    print(dayEvent!.whatEmotion!.map((e) => e.name).toList());
    additionalEmotions = dayEvent!.whatEmotion!
        .getRange(1, dayEvent!.whatEmotion!.length)
        .toList();
    additionalAudios = [];
    for (var audio in audios) {
      try {
        if ((audio.emotions ?? [])
            .map((e) => e.toLowerCase())
            .contains(mainEmotion!.name.toLowerCase())) {
          mainAudios.add(AudioCardModel(
              audio.name,
              DataSourceService.dataSourceIsRemote()
                  ? 'http://95.181.164.171/' +
                  audio.fileName +
                  '.' +
                  audio.format
                  : '${(await getApplicationDocumentsDirectory()).path}/${audio.folder}/${audio.fileName}.${audio.format}'));
        }
        if (additionalEmotions != null) {
          for (var item in additionalEmotions!) {
            if ((audio.emotions ?? [])
                    .map((e) => e.toLowerCase())
                    .toList()
                    .contains(item.name.toLowerCase()) &&
                !additionalAudios
                    .map((e) => e.title.toLowerCase())
                    .toList()
                    .contains(audio.name.toLowerCase())) {
              additionalAudios.add(AudioCardModel(
                  audio.name,
                  DataSourceService.dataSourceIsRemote()
                      ? 'http://95.181.164.171/' +
                          audio.fileName +
                          '.' +
                          audio.format
                      : '${(await getApplicationDocumentsDirectory()).path}/${audio.folder}/${audio.fileName}.${audio.format}'));
            }
          }
        }
      } catch (_) {
        print(_);
      }
    }
    print(additionalAudios.length);
    print(mainAudios.length);
  }
}
