import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/relax_dialog/controller.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../../main/path/path_final_screen/widgets/audio_container/audio_container_widget.dart';
import '../../../../../../../theme/app_icons.dart';

class RelaxDialog extends StatelessWidget {
  const RelaxDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RelaxDialogController());
    return Center(
      child:  Card(
        elevation: 0, color: Colors.transparent,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: size.width - 30,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(3)),
              child:Container(
                width: size.width,

                margin: EdgeInsets.all(1),
                decoration: BoxDecoration(color: ColorConstant.gray200,
                    borderRadius: BorderRadius.circular(3)),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            AppIcons.x, size: 9, color: ColorConstant.grayLight,),
                        ),
                      ),
                      Text('champion'.tr().toUpperCase(), textAlign: TextAlign.center,
                        style: AppStyle.txtSFProDisplayLight16,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          'let_your_thoughts'.tr(),
                          textAlign: TextAlign.center,
                          style: AppStyle.txtSFProDisplayLight16,),
                      ),
                      AspectRatio(
                          aspectRatio: 320/240,
                          child: SizedBox()),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Text(
                          '${'if_during_the_day'.tr()})',
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
                                  return Container(
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
                                                  maxDuration: (snapshot.data)?[index] ??
                                                      Duration.zero,
                                                )),
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
              ),
            ),
            Positioned(
              right: -75,
              left: -25,

              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: SizedBox(
                    width: size.width + 60,
                    child: AspectRatio(
                        aspectRatio: 400/240,
                        child: Image.asset(ImageConstant.humanRelaxImg,fit: BoxFit.contain,))),
              ),
            )
          ],
        ),
      ),
    );
  }
}
