import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

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

   String titleText () => 'Каждое упражнение заканчивайте глубоким вдохом и выдохом через рот 3 раза. Почувствуйте, как изменилось ощущение в руках, ногах, груди';

  DateTime? lastListen () =>null;



   Future<List<AudioCardModel>?> audioAssets () async {

     var collection = await FirebaseFirestore.instance.collection('Audio').where('tab', isEqualTo: 'depression').get();
     final audios = <AudioCardModel>[];
     final String appDocPath = (await getApplicationDocumentsDirectory()).path;
     for (var item in collection.docs) {
       try {
         final audio = Audio.fromJson(item.data());
         String filePath = appDocPath + '/' + '${audio.folder}/${audio.fileName}.${audio.format}';
         if(DataSourceService.dataSourceIsRemote()) {
           filePath = 'http://95.181.164.171/' + audio.fileName + '.' + audio.format;
         }
         if(audio.tab == 'depression') {
           if(audio.name == 'Введение'){
             audios.insert(0, AudioCardModel(audio.name, filePath));
           } else
             audios.add(AudioCardModel(audio.name, filePath));
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