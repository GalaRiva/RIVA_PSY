import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/widgets/tab_widget.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../controller.dart';

class ExercisesTabBody extends StatelessWidget {
  final K70Controller controller;

  const ExercisesTabBody({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: getPadding(top: 30),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: getVerticalSize(50),
              width: MediaQuery.of(context).size.width,
              child: TabBar(
                controller:  controller.tabController,
                isScrollable: true,
                onTap: (val) async {
                  controller.currentAudioIndex = null;
                  controller.currentTab = val;
                  if(controller.audioInstance.playing)await controller.audioInstance.pause();
                  controller.update();
                },
                indicatorColor: ColorConstant.fromHex('#1499A1'),
                unselectedLabelColor: ColorConstant.gray800,
                labelStyle: TextStyle(
                  color: ColorConstant.gray800,
                  fontSize: getFontSize(
                    14,
                  ),
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w300,
                ),
                labelColor: ColorConstant.cyan700,
                tabs: [
                  Tab(
                    text: 'Введение',
                  ),
                  Tab(
                    text: 'Медитации',
                  ),
                  Tab(
                    text: 'Негативные эмоции',
                  ),
                  Tab(
                    text: 'Депрессия',
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: size.height - getVerticalSize(419),
          width: size.width,
          child: TabBarView(
            controller:  controller.tabController,
            children: [
              TabWidget(
                  isStandardCheck: false,
                  enableScroll: false,
                  tab: controller.introductionModel,
                  controller: controller,
                  height: getVerticalSize(675 + 115)),
              TabWidget(
                  enableScroll: false,

                  tab: controller.meditationModel,
                  controller: controller,
                  height: getVerticalSize(523)
              ),
              Container(
                color: ColorConstant.grayLight,
                child: Column(
                  children: [
                    Padding(
                      padding: getPadding(top: 30),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: getVerticalSize(50),
                          width: MediaQuery.of(context)
                              .size
                              .width,
                          child: TabBar(
                              controller:  controller.tabControllerSecond,
                              isScrollable: true,
                              onTap: (val) async {
                                controller.currentAudioIndex = null;
                                controller.currentTabSecond =
                                    val;
                                if(controller.audioInstance.playing) await controller.audioInstance.pause();

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
                                'SF Pro Display',
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
                  height: getVerticalSize(2515)),
            ],
          ),
        ),

      ],
    );
  }
}
