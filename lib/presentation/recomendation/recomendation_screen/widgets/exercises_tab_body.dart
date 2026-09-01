import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/presentation/recomendation/recomendation_screen/widgets/tab_widget.dart';

import '../../../../core/services/audio/app_audio_service.dart';
import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../controller.dart';

class ExercisesTabBody extends StatelessWidget {
  final K70Controller controller;

  const ExercisesTabBody({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 14),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 38,
                width: size.width,
                child: TabBar(
                  dividerHeight: 0,
                  controller:  controller.tabController,
                  isScrollable: true,
                  onTap: (val) async {
                    controller.currentTab = val;
                    await AppAudioService.instance.pause();
                    controller.update();
                  },
                  indicatorColor: ColorConstant.fromHex('#1499A1'),
                  unselectedLabelColor: ColorConstant.gray800,
                  labelStyle: TextStyle(
                    color: ColorConstant.gray800,
                    fontSize: getFontSize(
                      14,
                    ),
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w300,
                  ),
                  labelColor: ColorConstant.cyan700,
                  tabs: [
                    Tab(
                      text: 'introduction'.tr(),
                    ),
                    Tab(
                      text: 'meditations'.tr(),
                    ),
                    Tab(
                      text: 'negative_emotions'.tr(),
                    ),
                    Tab(
                      text: 'depression'.tr(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TabBarView(
                controller:  controller.tabController,
                children: [
                  TabWidget(
                      isStandardCheck: false,
                      enableScroll: false,
                      tab: controller.introductionModel,
                      controller: controller,
                      height: (875)),
                  TabWidget(
                      enableScroll: false,

                      tab: controller.meditationModel,
                      controller: controller,
                      height: (523)
                  ),
                  Container(
                    color: ColorConstant.grayLight,
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: (25),
                              width: MediaQuery.of(context)
                                  .size
                                  .width,
                              child: TabBar(
                                  controller:  controller.tabControllerSecond,
                                  isScrollable: true,
                                  onTap: (val) async {
                                    controller.currentTabSecond =
                                        val;
                                    await AppAudioService.instance.pause();

                                    controller.update();
                                  },
                                  indicatorColor:
                                  ColorConstant.fromHex(
                                      '#1499A1'),
                                  unselectedLabelColor:
                                  ColorConstant.gray800,
                                  labelStyle: TextStyle(
                                    color:
                                    ColorConstant.gray800,
                                    fontSize: getFontSize(
                                      14,
                                    ),
                                    fontFamily:
                                    'Manrope',
                                    fontWeight:
                                    FontWeight.w300,
                                  ),
                                  labelColor:
                                  ColorConstant.cyan700,
                                  tabs: controller
                                      .negativeEmotionsModel!
                                      .tabs),
                            ),
                          ),
                        ),

                        GetBuilder(
                          builder: (K70Controller _c) => Expanded(
                            child: TabBarView(
                                clipBehavior: Clip.none,
                                controller:  controller.tabControllerSecond,
                                children: controller
                                    .negativeEmotionsModel!
                                    .tabBodies),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TabWidget(

                      tab: controller.depressionModel,
                      controller: controller,
                      height: (2515)),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
