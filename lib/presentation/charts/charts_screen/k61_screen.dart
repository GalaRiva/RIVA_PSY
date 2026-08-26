import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'widgets/admission_schedule/admission_schedule_widget.dart';
import 'widgets/diagnosis_of_the_condition_widget.dart';
import 'widgets/energy_matrix_widget.dart';
import 'widgets/social_battery_widget.dart';
import 'widgets/synergy_heatmap_widget.dart';
import 'widgets/what_emotion_widget.dart';
import 'widgets/where_in_body_widget.dart';

import '../../../core/utils/color_constant.dart';
import '../../../core/utils/size_utils.dart';
import '../../../theme/app_style.dart';
import '../../../widgets/custom_bottom_bar.dart';
import 'controller.dart';
import 'widgets/where_and_what_emotions_widget.dart';
import '../../../theme/app_colors.dart';

class K61Screen extends GetWidget{
  const K61Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(K61Controller());
    controller.init();
    controller.initTabController();
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        // NestedScrollView instead of one big SingleChildScrollView around
        // a manually-switched tab body: gives TabBarView a bounded height
        // (the remaining space below the header/tab-bar slivers) so swiping
        // between tabs works, while each tab's own SingleChildScrollView
        // (see _buildTabContents) still lets its content scroll and grow
        // freely without being clipped — same fix as before, just per-tab
        // instead of whole-page.
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: getPadding(top: 39, left: 16, right: 16),
                    child: Text(
                      'charts'.tr(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtSFProDisplayLight10Gray800,
                    ),
                  ),
                  Padding(
                    padding: getPadding(top: 8, left: 16, right: 16),
                    child: Divider(
                      height: getVerticalSize(1),
                      thickness: getVerticalSize(1),
                      color: ColorConstant.gray50,
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: getPadding(top: 4),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: getVerticalSize(70),
                    width: MediaQuery.of(context).size.width - 32,
                    child: TabBar(
                      controller: controller.tabController,
                      isScrollable: true,
                      // Tabs sit closer together: narrower fixed width per
                      // tab plus tighter labelPadding (default is 16px each
                      // side, on top of the box width).
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      // Soft pill instead of an underline — quiet-luxury
                      // brief: the active tab reads as a gentle tinted
                      // capsule, not a hard line.
                      indicator: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      unselectedLabelColor: ColorConstant.gray800.withOpacity(0.6),
                      labelStyle: TextStyle(
                        fontSize: getFontSize(12),
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: getFontSize(12),
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w300,
                      ),
                      labelColor: AppColors.primary,
                      tabs: _tabs(),
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: controller.loading == true
              ? Center(
                  child: CircularProgressIndicator(
                    color: ColorConstant.cyan700,
                  ),
                )
              : GetBuilder(
                  builder: (K61Controller _c) => TabBarView(
                    controller: controller.tabController,
                    children: _buildTabContents(controller),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }

  List<Widget> _tabs() {
    const keys = [
      'state_diagnosis',
      'what_emotions_am_I_feeling',
      'tab_body_map',
      'tab_places',
      'tab_medication_dynamics',
      'energy_matrix',
      'synergy_heatmap',
      'social_battery',
    ];
    return keys
        .map((key) => SizedBox(
              width: getHorizontalSize(104),
              height: getVerticalSize(70),
              child: Tab(
                height: getVerticalSize(70),
                child: Center(
                  child: Text(
                    key.tr(),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _buildTabContents(K61Controller controller) {
    Widget scrollable(Widget child) => SingleChildScrollView(child: child);
    return [
      scrollable(DiagnosticOfTheConditionWidget(
        start: controller.dateStart,
        end: controller.dateEnd,
        dataForChart: controller.dataForChart,
        controller: controller,
      )),
      scrollable(WhatEmotionWidget(
        start: controller.dateStart,
        controller: controller,
        end: controller.dateEnd,
        emotions: controller.emotions,
        emotionsTypes: controller.emotionsTypes,
      )),
      scrollable(WhereInBodyWidget(
        start: controller.dateStart,
        controller: controller,
        end: controller.dateEnd,
        neutralType: controller.neutralType,
        emotionsInBody: controller.emotionsInBody,
        positiveType: controller.positiveType,
        negativeType: controller.negativeType,
      )),
      scrollable(WhereAndWhatEmotionsWidget(controller: controller)),
      scrollable(AdmissionScheduleWidget()),
      scrollable(EnergyMatrixWidget(points: controller.energyMatrixPoints)),
      scrollable(SynergyHeatmapWidget(events: controller.allDayEvents)),
      scrollable(SocialBatteryWidget(events: controller.allDayEvents)),
    ];
  }
}
