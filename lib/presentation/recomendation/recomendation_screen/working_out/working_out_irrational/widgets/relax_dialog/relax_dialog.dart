import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/relax_dialog/controller.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../../../core/models/audio/audio.dart';
import '../../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../../core/services/datasource_service.dart';
import '../../../../../../main/path/path_final_screen/widgets/audio_container/audio_container_widget.dart';

class RelaxDialog extends StatelessWidget {
  const RelaxDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RelaxDialogController());
    return Center(
      child:  Card(
        elevation: 0, color: Colors.transparent,
        child: Container(
          width: size.width - 30,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(3)),
          child:Container(
            margin: EdgeInsets.all(1),
            decoration: BoxDecoration(color: ColorConstant.gray200,
                borderRadius: BorderRadius.circular(3)),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close, size: 9, color: ColorConstant.grayLight,),
                        ),
                      ),
                      Text('Чемпион! Отдохни немного.'.toUpperCase(), textAlign: TextAlign.center,
                        style: AppStyle.txtSFProDisplayLight16,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Позволь мыслям уложиться и приняться в тебе и возвращайся завтра. Так полезнее)',
                          textAlign: TextAlign.center,
                          style: AppStyle.txtSFProDisplayLight16,),
                      ),
                      AspectRatio(
                          aspectRatio: 320/240,
                          child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'Если в течении дня ты возвращаешься к определенным, конкретным негативным мыслям, зафиксируй их в Пути, а если нет возможности пройти здесь и сейчас:)',
                          style: AppStyle.txtSFProDisplayLight16,),
                      ),
                      Padding(padding: EdgeInsets.only(bottom: 15),
                        child: FutureBuilder(
                          future: controller.loadAudios(),
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
                            return FutureBuilder(future: controller.durations(audios),
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
                                  return GetBuilder(
                                    builder: (RelaxDialogController _c) => Container(
                                      height: getVerticalSize(80 * audios.length.toDouble()),
                                      width: size.width - 60,
                                      color:  ColorConstant.grayLight,
                                      child:  Wrap(
                                        children: List<Widget>.generate(
                                          audios.length, (index) =>
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: FittedBox(
                                                  fit: BoxFit.scaleDown ,
                                                  child:AudioContainerWidget(
                                                    audioCardModel: audios[index],
                                                    index: index,
                                                    audioPlayer: controller.audioInstance,
                                                    maxDuration: (snapshot.data)?[index] ??
                                                        Duration.zero,
                                                    currentAudioIndex: () => controller.currentAudioIndex,
                                                    update: (){
                                                      controller.update();
                                                    }, changeAudioIndex: (int index) {controller.currentAudioIndex = index;  },)),
                                            ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          },
                        ),
                      ),
                      CustomButton(text: 'OK', height: 47, onTap: () => Navigator.pop(context),)

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: SizedBox(child: Image.asset(ImageConstant.humanRelaxImg,)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
