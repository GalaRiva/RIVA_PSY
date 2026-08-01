import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../core/user_data/user.dart';
import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_image_view.dart';
import '../../../../core/services/datasource_service.dart';
import '../controller.dart';
import '../models/audio_model.dart';
import '../models/tabs/negative_emotion_tabs/negative_emotions_tab.dart';
import '../../../../widgets/audio_card_widget.dart';
import 'package:audio_session/audio_session.dart';

import '../../../../../widgets/go_to_new_tariff_widget.dart';
import '../../../../core/services/negative_emotion_tabs.dart';

class TabWidget extends StatelessWidget {
  final bool? isStandardCheck;
  final NegativeEmotionsModelTab tab;
  final K70Controller controller;
  final double height;
  final bool? enableScroll;

   TabWidget(
      {Key? key,
      required this.tab,
      required this.controller,
      required this.height, this.enableScroll = true, this.isStandardCheck = true})
      : super(key: key);

  List<Widget> _audios = [];
  int? audioLength;

  @override
  Widget build(BuildContext context) {
    // tab.audioAssets() re-runs a fresh Firestore query every single call
    // (see IntroductionModel etc.) with no orderBy — nothing guarantees two
    // separate calls return the docs in the same order. This used to call
    // it four separate times per build (once per item here, once for
    // audioLength, once for each card's title, once again inside playFun),
    // so the duration list built in one pass could end up matched against
    // a differently-ordered asset list from a later pass — a track's
    // "00:00" (or another track's) duration landing on the wrong card.
    // Fetching once and threading the same resolved list through
    // everything below removes the reordering window entirely.
    Future<List<Duration?>> _durations (List<AudioCardModel> assets) async {
      final List<Duration?> list = [];
      for (var item in assets) {
        try {
          if (DataSourceService.dataSourceIsRemote()) {
            await Future.delayed(Duration(milliseconds: 300), () async {
              list.add(await controller.audioInstance.setUrl(
                  item.audioAsset, initialPosition: Duration.zero, preload: true));
            });
          } else
            list.add(await controller.audioInstance.setAudioSource(
                AudioSource.file(item.audioAsset),
                initialPosition: Duration.zero));
        } catch (_) {
          try {
            await Future.delayed(Duration(milliseconds: 200), () async {
              list.add(await controller.audioInstance.setUrl(
                  item.audioAsset, initialPosition: Duration.zero));
            });
          } catch (_) {
            print('error load - ${item.audioAsset}');
            list.add(Duration.zero);
          }
        }
      }
      return list;
    }
    Future<List<Widget>> _audiosFun (List<AudioCardModel> assets) async {
      List<Widget> list = [];

      controller.audioInstance = AudioPlayer();
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration.speech());
      List<Duration?> dur = await _durations(assets);
      audioLength = assets.length;
       for (int i = 0; i < audioLength!; i++) {
          list.add(AudioCardWidget(
            index: i,
                text: assets[i].title,
                onChange: (Duration duration) {
                  controller.audioInstance.seek(duration);
                  controller.update();
                },
                maxDuration: dur[i] ?? Duration(seconds: 0),
            playFun: (val) async {

              if(DataSourceService.dataSourceIsRemote()) {
                await controller.audioInstance.setUrl(assets[i].audioAsset, initialPosition: val);
              } else
                await controller.audioInstance.setAudioSource(AudioSource.file(assets[i].audioAsset), initialPosition: val);

              await controller.audioInstance.play();
            },
            stopFun: () async {
              await controller.audioInstance.pause();
            },
            loadFun: () async {}, audioInstance: controller.audioInstance, currentAudioIndex: () => controller.currentAudioIndex ?? 0, changeCurrentAudioIndex: (int index) { controller.currentAudioIndex = index; },
            ));

        }

      return list;
    }

    if(audioLength != _audios.length) {
      tab.audioAssets().then((assets) {
        if (assets != null)
          _audiosFun(assets).then((value) {
            _audios = value;
            controller.update();
          });
      });

    }

    return GetBuilder(
      builder: (K70Controller _c) => Container(
           // height: getVerticalSize(height),
            width: size.width,
            color: ColorConstant.grayLight,
            child: Stack(
              children: [
            Padding(
                  padding: getPadding(top: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: tab.titleImage() != null && tab.titleText() != null,
                          child: Padding(
                            padding: getPadding(left: 16, right: 16),
                            child: SizedBox(
                              height: getVerticalSize(100),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  DataSourceService.dataSourceIsRemote() ? SvgPicture.network(
                                    tab.titleImage() ?? '',
                                    height: getVerticalSize(100),
                                    placeholderBuilder: (context) {
                                      return Center(child: CircularProgressIndicator(color: ColorConstant.cyan700,));
                                    },
                                    width: getHorizontalSize(60),
                                    fit: BoxFit.contain,
                                  ) : SvgPicture.file(
                                    File(tab.titleImage() ?? ''),
                                    height: getVerticalSize(100),
                                    width: getHorizontalSize(60),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: getHorizontalSize(10),),
                                  Container(
                                    alignment: Alignment.topLeft,
                                    width: size.width -getHorizontalSize( 140),
                                    height: getVerticalSize(100),
                                    child: Text(
                                      tab.titleText() ?? '',
                                      maxLines: 10,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.left,
                                      style: AppStyle.txtSFProDisplayMedium9.copyWith(
                                          fontSize: 14,
                                          color: ColorConstant.fromHex('#3B3B4A'),
                                        fontWeight: FontWeight.w300
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible:tab.audioAssets() != null,
                            child: Padding(
                          padding: getPadding(top: 23,right: 16, left: 16),
                          child:
                          _audios.isEmpty ? Center(child: CircularProgressIndicator(color: ColorConstant.cyan700,),) :  Wrap(
                              direction: Axis.vertical,
                              spacing: getVerticalSize(33),
                              children: _audios,
                            ),

                        )),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Visibility(
                              visible: tab.buttons() != null,
                              child: Padding(
                                padding: getPadding(left: 16, right: 16, top: 33),
                                child: SizedBox(
                                  width: size.width - 32,
                                  child: Wrap(
                                    spacing: 8,
                                    alignment: WrapAlignment.spaceAround,
                            children: (tab.buttons() ?? []).map((e) => Padding(padding: EdgeInsets.only(bottom: 8), child: e,)).toList(),
                          ),
                                ),
                              )),
                        ),
                        SizedBox(height: 20,)
                      ],
                ),
                  ),
                ),
                Visibility(
                    visible: CurrentUser.user.currentTariff!.name == 'Базовый' && isStandardCheck == true,
                    child: GoToNewTariffWidget(height: height , onSecondButtonTap: () {
                      controller.tabController!.animateTo(0);
                      controller.currentTab = 0;
                    },))

              ],
            ),
      ),
    );
  }
}
