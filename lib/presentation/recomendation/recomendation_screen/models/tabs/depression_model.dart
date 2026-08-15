import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/models/audio/audio.dart';
import '../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../core/services/datasource_service.dart';
import '../../../../../core/services/negative_emotion_tabs.dart';
import '../../../../../../core/utils/image_constant.dart';
import '../../widgets/select_botton_widget.dart';
import 'negative_emotion_tabs/negative_emotions_tab.dart';
import 'package:path_provider/path_provider.dart';

class DepressionModel extends NegativeEmotionsModelTab{
   String imageTitle = ImageConstant.depressionImage;

   String titleText () => 'breathing_relaxation_instruction'.tr();

  DateTime? lastListen () =>null;



   Future<List<AudioCardModel>?> audioAssets () async {

     final prefs = await SharedPreferences.getInstance();
     final langCode = (prefs.getString('locale') ?? 'ru_RU').split('_').first;
     var collection = await FirebaseFirestore.instance.collection('Audio').where('tab', isEqualTo: 'depression').orderBy('order').get();
     final audios = <AudioCardModel>[];
     final String appDocPath = (await getApplicationDocumentsDirectory()).path;
     for (var item in collection.docs) {
       try {
         final audio = Audio.fromJson(item.data());
         final fileName = audio.localizedFileName(langCode);
         String filePath = appDocPath + '/' + '${audio.folder}/${fileName}.${audio.format}';
         if(DataSourceService.dataSourceIsRemote()) {
           filePath = 'https://pub-cd14ca249f1e4d4fbfb07ca99a7efe6d.r2.dev/audio/' + fileName + '.' + audio.format;
         }
         if(audio.tab == 'depression') {
           if(audio.name == 'Введение'){
             audios.insert(0, AudioCardModel(audio.localizedName(langCode), filePath));
           } else
             audios.add(AudioCardModel(audio.localizedName(langCode), filePath));
         }
       } catch (_) {
         print (_);
       }


     }
     return audios;
   }



  List<SelectButtonWidget>? buttons() =>null;

  @override
  String? titleImage() => imageTitle;
}