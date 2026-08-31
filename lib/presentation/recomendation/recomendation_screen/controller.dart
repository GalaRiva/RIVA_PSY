import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'models/tabs/introduction_model.dart';
import 'models/tabs/medetation_model.dart';
import 'models/tabs/negative_emotions_model.dart';
import 'models/tabs/depression_model.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/utils/size_utils.dart';

class K70Controller extends GetxController {

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    audioInstance.dispose();
  }

  @override
  // TODO: implement onDelete
  InternalFinalCallback<void> get onDelete {
    audioInstance.dispose();
    return super.onDelete;
  }

  NegativeEmotionsModel? negativeEmotionsModel;

  Future initNegativeEmotions () async {
    negativeEmotionsModel = NegativeEmotionsModel(this);
    await negativeEmotionsModel!.getTabBodies().then((value) => negativeEmotionsModel!.tabBodies = value);
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;
    depressionModel.imageTitle = appDocPath + '/' + 'tabs_images/depression.svg';
  }

  Future init (TickerProvider ticker) async {
   tabController = TabController(length: 4, vsync: ticker, initialIndex: currentTab);
   negativeEmotionsModel ??= NegativeEmotionsModel(this);
   tabControllerSecond = TabController(length: negativeEmotionsModel!.tabs.length, vsync: ticker, initialIndex: currentTabSecond);

   update();
  }

  final introductionModel = IntroductionModel();
  final meditationModel = MeditationModel();
  final depressionModel = DepressionModel();


  late AudioPlayer audioInstance = AudioPlayer(
    audioLoadConfiguration: AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        maxBufferDuration: Duration(seconds: 300),
        bufferForPlaybackDuration: Duration(seconds: 5),
        bufferForPlaybackAfterRebufferDuration: Duration(seconds: 10),
      )
    )
  );

  TabController? tabController;
  TabController? tabControllerSecond;

  int currentTab = 0;
  int currentTabSecond = 0;
  int panicTab = 1;
  // Set from route arguments (see K70Screen.didChangeDependencies) when a
  // CTA from "Мой портрет" deep-links into a specific WorkingOutScreen
  // sub-tab (Оспорить мысль/Счастье в фокусе/Желания/Guided Journals) —
  // consumed once by WorkingOutCubit's initial TabController index.
  int? workingOutInitialTab;

  bool loading = true;
  int? currentAudioIndex;

  // Set by a nested module (Guided Journals/Проекция Я/etc.) when the user
  // leaves that module's own library/browsing screen and enters a
  // question/step screen — K70Screen listens to this to hide its own top
  // tab bar + bottom nav so the exercise gets the full screen. Reset to
  // false either by that same module (back to its library) or by
  // CustomTabBar itself when the user switches to a different top-level
  // tab (so a mid-exercise tab left behind doesn't leave stale hidden
  // chrome for whichever tab the user switches to next).
  bool immersiveMode = false;

  void setImmersiveMode(bool value) {
    if (immersiveMode == value) return;
    immersiveMode = value;
    update();
  }

  // The K70 top-level CustomTabBar's own PageView position (0=Справиться с
  // эмоцией, 1=Обретение, 2=Хлебные крошки, 3=Проекция Я) — distinct from
  // `currentTab` above, which tracks a different, older TabController.
  // Kept in sync purely from CustomTabBar.onPageChanged, so it never
  // depends on any nested module's own stage — used to hide the bottom
  // nav bar while "Обретение" is the active tab, regardless of which of
  // its own sub-exercises/stages the user is on (a simpler, lower-risk
  // alternative to per-stage immersive mode for that section — see
  // PROJECT_CONTEXT.md).
  int activeTopLevelTab = 0;

  void setActiveTopLevelTab(int index) {
    if (activeTopLevelTab == index) return;
    activeTopLevelTab = index;
    update();
  }
  double getTabHeight() {
    switch (currentTab) {
      case 0:
        return getVerticalSize(675 + 115);
      case 1:
        return size.height - 239;
      case 2:
        if(currentTabSecond == 2)
          return getVerticalSize(678);
        else return getVerticalSize(523);
      case 3:
        return getVerticalSize(2600);
      default:
        return size.height - getVerticalSize(214);

    }
  }
}