import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'widgets/negative_positive_tab.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_search_view.dart';
import '../../../../../core/utils/size_utils.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../widgets/event_card.dart';
import 'controller.dart';
import 'widgets/neutral_tab.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';

class K27Screen extends GetWidget {
  final DayEventModel? dayEvent;
  final List<EmotionInDayEvent>? emotionsTypes;
  final Function(DayEventModel dayEvent, List<EventModel> events, EmotionInDayEvent emotionCategory)? onSave;

  List<Widget> _tabs (){
    final List<Widget> tabs = [];
    if(emotionsTypes != null) {
      for (var item in emotionsTypes!) {
        late final String text;
        switch (item) {
          case EmotionInDayEvent.NEGATIVE:
            text = 'negative'.tr();
            break;
          case EmotionInDayEvent.POSITIVE:
            text = 'positive'.tr();
            break;
          default:
            text = 'neutral'.tr();
            break;
        }
        tabs.add( Tab(text: text));
      }
    } else {
      return [
        Tab(text: 'negative'.tr()),
        Tab(text: 'positive'.tr()),
        Tab(text: 'neutral'.tr()),];
    }
    return tabs;
  }

  K27Screen({ this.emotionsTypes,  this.dayEvent,  this.onSave});
  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel =
       dayEvent ?? (ModalRoute.of(context)?.settings.arguments ?? DayEventModel())
            as DayEventModel;

    final controller = Get.put(K27Controller());
    controller.initTabController(emotionsTypes == null ? 3 : emotionsTypes!.length);
    if(controller.currentEventListOne != controller.currentEventListOneAfterInit)
      controller.initCurrentEventList(1).then((value) {
      controller.currentEventListOne = value;
      controller.currentEventListOneAfterInit = value;
      controller.update();
    });
    if(controller.currentEventListTwo != controller.currentEventListTwoAfterInit)
    controller.initCurrentEventList(2).then((value) {
      controller.currentEventListTwo = value;
      controller.currentEventListTwoAfterInit = value;

      controller.update();
    });
    if(controller.currentEventListThree != controller.currentEventListThreeAfterInit)
      controller.initCurrentEventList(3).then((value) {
      controller.currentEventListThree = value;
      controller.currentEventListThreeAfterInit = value;

      controller.update();
    });
    final _focus2 = FocusNode();
    final _focus = FocusNode();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,

          children: [
            Padding(
              padding: getPadding(
                left: 16,
                right: 4,
                bottom: 40,
              ),
              // NestedScrollView so the header (current_emotion/title/search
              // fields) scrolls away together with the tab content, matching
              // every other Path screen, instead of staying pinned while
              // only the tab body scrolls underneath it.
              child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: getPadding(
                        top: 39,
                      ),
                      child: Text(
                        'current_emotion'.tr(),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: AppStyle.txtSFProDisplayLight10Gray800,
                      ),
                    ),
                    Padding(
                      padding: getPadding(
                        top: 12,
                      ),
                      child: Divider(
                        height: getVerticalSize(
                          1,
                        ),
                        thickness: getVerticalSize(
                          1,
                        ),
                        color: ColorConstant.gray50,
                      ),
                    ),
                    Container(height: 14,),
                    Text(
                      'which_emotion_felt'.tr(),
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      style: AppStyle.txtH1,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      child: CustomSearchView(
                        focusNode: _focus,
                        onChange: (text)async {
                          await controller.changeCurrentEventList(text);
                          controller.update();
                        },
                        onSubmit: (text) => _focus.unfocus(),
                        controller: controller.searchController,
                        hintText: 'find_emotion'.tr(),
                        variant: SearchViewVariant.FillGray200,
                        margin: getMargin(
                          top: 28,
                          right: 16,
                        ),
                        suffix: Container(
                          margin: getMargin(
                            left: 30,
                            top: 1,
                            right: 10,
                            bottom: 9,
                          ),
                          child: CustomImageView(
                            svgPath: ImageConstant.imgSearch,
                          ),
                        ),
                        suffixConstraints: BoxConstraints(
                          maxHeight: getVerticalSize(
                            26,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 32,
                      child: CustomSearchView(
                        focusNode: _focus2,
                        controller: controller.addEventController,
                        hintText: 'add_emotion'.tr(),
                        variant: SearchViewVariant.FillGray200,
                        margin: getMargin(
                          top: 25,
                          right: 16,
                        ),
                        onSubmit:(text) async{
                          _focus2.unfocus();
                          var result = (await Navigator.pushNamed(
                              context, AppRoutes.addEmotion,
                              arguments: {
                                'initialValue':
                                controller.addEventController.text,
                                'title': 'add_emotion'.tr()
                              }))
                          as EventModel;
                          if (result != null) {
                            await controller
                                .updateCurrentEventList(
                                result, controller.currentTab);
                            controller.currentEventList= await controller.changeCurrentEventList(
                                controller.searchController.text);
                            controller.update();
                          }
                        },
                        suffix: Container(
                            margin: getMargin(
                              left: 30,
                              top: 1,
                              right: 10,
                              bottom: 9,
                            ),
                            child: SizedBox(
                              width: getHorizontalSize(26),
                              height: getVerticalSize(26),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  AppIcons.plus,
                                  size: getSize(18),
                                ),
                                onTap: () async {
                                  var result = (await Navigator.pushNamed(
                                          context, AppRoutes.addEmotion,
                                          arguments: {
                                            'initialValue':
                                            controller.addEventController.text,
                                            'title': 'add_emotion'.tr()
                                          }))
                                      as EventModel;
                                  if (result != null) {
                                     await controller
                                        .updateCurrentEventList(
                                            result, controller.currentTab);
                                     controller.currentEventList= await controller.changeCurrentEventList(
                                         controller.searchController.text);
                                    controller.update();
                                  }
                                },
                              ),
                            )),
                        suffixConstraints: BoxConstraints(
                          maxHeight: getVerticalSize(
                            26,
                          ),
                        ),
                      ),
                    ),
                  ],
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: getPadding(top: 40),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width - 32,
                            child: TabBar(
                              controller: controller.tabController,
                              indicatorColor: ColorConstant.fromHex('#1499A1'),
                              unselectedLabelColor: ColorConstant.gray800A0,
                              labelStyle: TextStyle(
                                color: ColorConstant.gray800A0,
                                fontSize: getFontSize(
                                  14,
                                ),
                                fontFamily: 'Manrope',
                                fontWeight: FontWeight.w300,
                                height: getVerticalSize(
                                  1.21,
                                ),
                              ),
                              labelColor: ColorConstant.cyan700,
                              tabs:  _tabs()
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  body: GetBuilder(
                    builder: (K27Controller _c) => TabBarView(
                      controller: controller.tabController,
                      children: emotionsTypes != null ? List.generate(emotionsTypes!.length, (index) => emotionsTypes![index] == EmotionInDayEvent.NEGATIVE ? NegativePositiveTab(
                        dayEventModel: dayEventModel,
                        number: 1,
                        list: controller.currentEventListOne, controller: controller,
                      ) : emotionsTypes![index] == EmotionInDayEvent.POSITIVE ? NegativePositiveTab(
                        dayEventModel: dayEventModel,
                        number: 2,
                        controller: controller, list: controller.currentEventListTwo,
                      ) : NegativePositiveTab(
                        dayEventModel: dayEventModel,
                        number: 3,
                        controller: controller, list: controller.currentEventListThree.where((element) => element.isNeutralPositive).toList(),
                      )) : [
                        NegativePositiveTab(
                          dayEventModel: dayEventModel,
                          number: 1,
                          list: controller.currentEventListOne, controller: controller,
                        ),
                        NegativePositiveTab(
                          dayEventModel: dayEventModel,
                          number: 2,
                          controller: controller, list: controller.currentEventListTwo,
                        ),
                        NeutralTab(
                          dayEventModel: dayEventModel,
                          number: 3,
                          controller: controller, list: controller.currentEventListThree,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: getPadding(left: 16, top: 14, bottom: 10, right: 16),
                child: GetBuilder(
                  builder: (K27Controller _c) => Container(
                    width: double.maxFinite,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomButton(
                          height: getVerticalSize(
                            32,
                          ),
                          width: getHorizontalSize(
                            177,
                          ),
                          onTap: () => Navigator.pop(context),
                          text: 'choosing_person'.tr().toUpperCase(),
                          variant: ButtonVariant.Base,

                          padding: ButtonPadding.PaddingT8,
                          prefixWidget: CustomImageView(
                            margin: getMargin(right: 12),
                            svgPath: ImageConstant.leftArrow,
                          ),
                        ),
                        GetBuilder(
                          builder: (K27Controller _c) => CustomButton(
                            height: getVerticalSize(
                              32,
                            ),
                            width: getHorizontalSize(
                              140,
                            ),
        bgColor: ColorConstant.cyan700,
                            textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                            onTap: controller.getCurrentListByNumber(controller.currentTab).isNotEmpty
                                ? () async {
                              if(controller.emotion == null) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('choose_emotion_or_create_new'.tr())));
                              } else {
                                List<EventModel> list = [];
                                if(controller.currentTab == 1) list = await controller.initCurrentEventList(1);
                                else if(controller.currentTab == 2) list = await controller.initCurrentEventList(2);
                                else if(controller.currentTab == 3) list = await controller.initCurrentEventList(3);
                                for (int i = 0; i < list.length; i++) {
                                  if (controller.emotion!.identity == list[i].identity) {
                                    list.removeAt(i);
                                    break;
                                  }
                                }
                                final EmotionInDayEvent category = emotionsTypes != null ? emotionsTypes![(controller.currentTab - 2).abs()] : (controller.currentTab == 1 ? EmotionInDayEvent.NEGATIVE : controller.currentTab == 2 ? EmotionInDayEvent.POSITIVE : EmotionInDayEvent.NEUTRAL);
                                if(onSave != null)
                                  onSave!(dayEventModel.copyWith(whatEmotion: [controller.emotion!], date: DateTime.now(),
                                      emotionInDayEvent: category), list, category);
                                  else {
                                    debugPrint(category.toString());
                                          Navigator.pushNamed(context,
                                              AppRoutes.additionalEmotions,
                                              arguments: {
                                                'emotionCategory': category,
                                                'dayEventModel': dayEventModel
                                                    .copyWith(
                                                        whatEmotion: [
                                                      controller.emotion!
                                                    ],
                                                        date: DateTime.now(),
                                                        emotionInDayEvent: category),
                                                'someEmotions': list
                                              });
                                        }
                                      }
                              // Navigator.pushNamed(context, AppRoutes.k26Screen, arguments: dayEventModel..whereHappened = controller.whereHappened);
                            }
                                : () async{
                              controller.searchController.text = '';
                              controller.currentEventList= await controller.changeCurrentEventList(
                                  controller.searchController.text);
                              controller.update();
                            },
                            text: controller.getCurrentListByNumber(controller.currentTab).isNotEmpty
                                ? 'continue'.tr().toUpperCase() : 'cancel'.tr().toUpperCase(),
                            margin: getMargin(
                              bottom: 10,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}
