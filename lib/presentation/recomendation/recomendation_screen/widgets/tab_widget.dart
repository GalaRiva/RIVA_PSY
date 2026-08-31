import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../../core/models/audio/audio_card_model.dart';
import '../../../../../core/services/audio/audio_cache_manager.dart';
import '../../../../../core/user_data/user.dart';
import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_decoration.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_image_view.dart';
import '../../../../core/services/audio/post_audio_checkin_gate.dart';
import '../../../../core/services/datasource_service.dart';
import '../controller.dart';
import '../models/audio_model.dart';
import '../models/tabs/medetation_model.dart';
import '../models/tabs/negative_emotion_tabs/negative_emotions_tab.dart';
import '../../../../widgets/audio_card_widget.dart';
import 'post_audio_checkin_sheet.dart';
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
        // Known ahead of time (Audio.duration_ms, precomputed once and
        // stored in Firestore) — skip the network probe entirely. This is
        // the common case for every track already in the catalog; only a
        // brand-new track added without a duration backfill falls through
        // to the live probe below.
        if (item.knownDuration != null) {
          list.add(item.knownDuration);
          continue;
        }
        try {
          if (DataSourceService.dataSourceIsRemote()) {
            list.add(await controller.audioInstance.setAudioSource(
                await AudioCacheManager.sourceFor(item.audioAsset),
                initialPosition: Duration.zero, preload: true));
          } else
            list.add(await controller.audioInstance.setAudioSource(
                AudioSource.file(item.audioAsset),
                initialPosition: Duration.zero));
        } catch (_) {
          try {
            list.add(await controller.audioInstance.setAudioSource(
                await AudioCacheManager.sourceFor(item.audioAsset),
                initialPosition: Duration.zero));
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
                await controller.audioInstance.setAudioSource(
                    await AudioCacheManager.sourceFor(assets[i].audioAsset),
                    initialPosition: val);
              } else
                await controller.audioInstance.setAudioSource(AudioSource.file(assets[i].audioAsset), initialPosition: val);

              await controller.audioInstance.play();

              // Warm the next track's cache in the background while this
              // one plays — matches how Spotify preloads the next queued
              // song, so advancing to it doesn't hit a network wait.
              if (DataSourceService.dataSourceIsRemote() && i + 1 < assets.length) {
                unawaited(AudioCacheManager.prefetch(assets[i + 1].audioAsset));
              }
            },
            stopFun: () async {
              await controller.audioInstance.pause();
            },
            loadFun: () async {}, audioInstance: controller.audioInstance, currentAudioIndex: () => controller.currentAudioIndex ?? 0, changeCurrentAudioIndex: (int index) { controller.currentAudioIndex = index; },
            onNaturalCompletion: tab is MeditationModel
                ? () {
                    if (!PostAudioCheckinGate.canShow) return;
                    PostAudioCheckinGate.markShown();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => PostAudioCheckinSheet(trackTitle: assets[i].title),
                    );
                  }
                : null,
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
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  (tab.titleImage() ?? '').startsWith('assets/')
                                    ? Image.asset(
                                        tab.titleImage()!,
                                        height: getVerticalSize(100),
                                        width: getHorizontalSize(60),
                                        fit: BoxFit.contain,
                                      )
                                    : DataSourceService.dataSourceIsRemote() ? SvgPicture.network(
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
                                  // No fixed height here — was clipping
                                  // translations longer than the Russian
                                  // original (e.g. Spanish "Termina cada
                                  // ejercicio..."). The Row/Column above
                                  // grows to fit instead.
                                  Container(
                                    alignment: Alignment.topLeft,
                                    width: size.width -getHorizontalSize( 140),
                                    child: Text(
                                      tab.titleText() ?? '',
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
                    // Used to start 100px down, to clear this tab's own
                    // header/instruction text — but that gap also left the
                    // first audio card's real, working play/scrub controls
                    // exposed and usable on the free tier. The teaser
                    // overlay is already semi-transparent (you can see
                    // there's real content under it), so covering the
                    // header too is a small loss next to leaving actual
                    // playback reachable without a subscription.
                    // No `height:` here — this used to inherit tabHeight,
                    // which is derived from this tab's own audio count and
                    // collapses to ~200px when that list is empty. The
                    // overlay's own promo content (title/image/buttons/
                    // disclaimer) needs far more than that, so a low-audio
                    // tab clipped it down to an apparently blank gray box.
                    // Omitting height lets the widget fall back to its own
                    // sensible full-screen-ish default.
                    child: GoToNewTariffWidget(onSecondButtonTap: () {
                      controller.tabController!.animateTo(0);
                      controller.currentTab = 0;
                    })),
                // Temporary on-screen diagnostic (debug builds only) — a
                // blank tab here has had two different suspected causes
                // already; this shows the actual values live instead of
                // guessing a third time.
                if (kDebugMode)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: Colors.black87,
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'tariff=${CurrentUser.user.currentTariff?.name} std=$isStandardCheck audios=${_audios.length} audioLen=$audioLength',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
              ],
            ),
      ),
    );
  }
}
