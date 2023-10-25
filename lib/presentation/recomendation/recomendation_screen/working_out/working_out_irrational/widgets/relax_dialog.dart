import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../core/models/audio/audio.dart';
import '../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../core/services/datasource_service.dart';
import '../../../../../main/path/path_final_screen/widgets/audio_container/audio_container_widget.dart';


class RelaxDialog extends StatefulWidget {

  @override
  State<RelaxDialog> createState() => _RelaxDialogState();
}

class _RelaxDialogState extends State<RelaxDialog> {

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

  Future<List<Duration?>> _durations(List<AudioCardModel> audios) async {
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

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: size.width - 30,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(3)),
        child: Container(
          margin: EdgeInsets.all(1),
          decoration: BoxDecoration(color: ColorConstant.gray200,
              borderRadius: BorderRadius.circular(3)),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close, size: 9, color: ColorConstant.grayLight,),
                  ),
                ),
                Text('Чемпион! Отдохни немного.', textAlign: TextAlign.center,
                  style: AppStyle.txtSFProDisplayLight16,),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Позволь мыслям уложиться и приняться в тебе и возвращайся завтра. Так полезнее)',
                    textAlign: TextAlign.center,
                    style: AppStyle.txtSFProDisplayLight16,),
                ),
                SizedBox(
                    width: size.width - 60,
                    child: Stack(children: [Image.asset(ImageConstant.humanRelaxImg, fit: BoxFit.cover,)],clipBehavior: Clip.none,)),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  child: Text(
                    'Если в течении дня ты возвращаешься к определенным, конкретным негативным мыслям, зафиксируй их в Пути, а если нет возможности пройти здесь и сейчас:)',
                    style: AppStyle.txtSFProDisplayLight16,),
                ),
                Padding(padding: EdgeInsets.only(bottom: 15),
                  child: FutureBuilder(
                    future: loadAudios(),
                    builder: (context,
                        AsyncSnapshot<List<AudioCardModel>>_snapshot) {
                      if(_snapshot.connectionState == ConnectionState.waiting){
                        return Center(
                          child: SizedBox(
                              height: 50,
                              width: 50,
                              child: CircularProgressIndicator(color: ColorConstant.cyan700,)),
                        );
                      }
                      final audios = _snapshot.data!;
                      return FutureBuilder(future: _durations(audios),
                          builder: (context, AsyncSnapshot<
                              List<Duration?>>snapshot) {
                            if(snapshot.connectionState == ConnectionState.waiting){
                              return Center(
                                child: SizedBox(
                                    height: 50,
                                    width: 50,
                                    child: CircularProgressIndicator(color: ColorConstant.cyan700,)),
                              );
                            }
                            return Wrap(
                              children: List<Widget>.generate(
                                  audios.length, (index) =>
                                  AudioContainerWidget(
                                      audioCardModel: audios[index],
                                      index: index,
                                      audioPlayer: audioInstance,
                                      maxDuration: (snapshot.data)?[index] ??
                                          Duration.zero,
                                      currentAudioIndex: currentAudioIndex,
                                      update: () => setState((){}))),
                            );
                          });
                    },
                  ),
                ),
                CustomButton(text: 'OK', height: 47, onTap: () => Navigator.pop(context),)

              ],
            ),
          ),
        ),
      ),
    );
  }
}

