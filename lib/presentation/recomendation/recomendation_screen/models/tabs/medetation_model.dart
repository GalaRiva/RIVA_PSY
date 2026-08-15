import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../core/services/datasource_service.dart';
import '../../widgets/select_botton_widget.dart';
import 'negative_emotion_tabs/negative_emotions_tab.dart';

import '../../../../../core/models/audio/audio.dart';
import '../../../../../core/services/negative_emotion_tabs.dart';
import 'package:path_provider/path_provider.dart';
class MeditationModel extends NegativeEmotionsModelTab{

  Future<List<AudioCardModel>?> audioAssets () async {

    final prefs = await SharedPreferences.getInstance();
    final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
    var collection = await FirebaseFirestore.instance.collection('Audio').where('tab', isEqualTo:'meditation').get();
    final audios = <AudioCardModel>[];
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    for (var item in collection.docs) {
      try {
        final audio = Audio.fromJson(item.data());
        final fileName = audio.localizedFileName(langCode);
        String filePath = appDocPath + '/' + '${audio.folder}/${fileName}.${audio.format}';
        if(DataSourceService.dataSourceIsRemote()) {
          filePath = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/' + audio.folder + '/' + fileName + '.' + audio.format;
        }
        if(audio.tab == 'meditation')
          audios.add(AudioCardModel(audio.localizedName(langCode), filePath));
      }catch (_) {
        print (_);

      }


    }
    return audios;
  }

  @override
  List<SelectButtonWidget>? buttons() =>null;

  @override
  DateTime? lastListen() =>null;

  @override
  String? titleImage() =>null;

  @override
  String? titleText() =>null;
}