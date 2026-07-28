import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../../core/models/audio/audio.dart';
import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/models/day_event_model.dart';
import '../../../../../../core/models/event_model.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../../core/utils/ru_canonical_name.dart';
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

    // Match against each emotion's canonical Russian name (read from
    // ru-RU.json by stable key via RuCanonicalName), not the live-locale
    // .name — Firestore's Audio.emotions field still tags audio tracks with
    // Russian emotion names, and .name reflects whatever locale the user's
    // Hive data happened to be seeded in (see PROJECT_CONTEXT.md). Falls
    // back to .name for custom emotions, which have no stable key.
    final mainEmotionRuName =
        await RuCanonicalName.forKey(mainEmotion!.key) ?? mainEmotion!.name;
    final additionalEmotionsRuNames = <String>[
      for (var item in additionalEmotions!)
        await RuCanonicalName.forKey(item.key) ?? item.name
    ];

    for (var audio in audios) {
      try {
        if ((audio.emotions ?? [])
            .map((e) => e.toLowerCase())
            .contains(mainEmotionRuName.toLowerCase())) {
          mainAudios.add(AudioCardModel(
              audio.name,
              DataSourceService.dataSourceIsRemote()
                  ? 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/' +
                  audio.fileName +
                  '.' +
                  audio.format
                  : '${(await getApplicationDocumentsDirectory()).path}/${audio.folder}/${audio.fileName}.${audio.format}'));
        }
        if (additionalEmotions != null) {
          for (var i = 0; i < additionalEmotions!.length; i++) {
            if ((audio.emotions ?? [])
                    .map((e) => e.toLowerCase())
                    .toList()
                    .contains(additionalEmotionsRuNames[i].toLowerCase()) &&
                !additionalAudios
                    .map((e) => e.title.toLowerCase())
                    .toList()
                    .contains(audio.name.toLowerCase())) {
              additionalAudios.add(AudioCardModel(
                  audio.name,
                  DataSourceService.dataSourceIsRemote()
                      ? 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/' +
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
