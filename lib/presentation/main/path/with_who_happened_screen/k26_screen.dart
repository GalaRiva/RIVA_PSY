import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_search_view.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../core/models/event_model.dart';
import '../../../../widgets/event_card.dart';
import 'controller.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';

class K26Screen extends GetWidget {
  final DayEventModel? dayEvent;
  final Function(DayEventModel dayEvent)? onSave;

  K26Screen({  this.dayEvent, this.onSave});

  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel = dayEvent ?? (ModalRoute.of(context)?.settings.arguments ?? DayEventModel()) as DayEventModel;

    final controller = Get.put(K26Controller());
    if(controller.currentEventList != controller.eventListAfterInit)
      controller.initCurrentEventList().then((value) {
        controller.currentEventList = value;
        controller.eventListAfterInit = value;
        controller.update();
      });
    final _focus = FocusNode();
    final _focus2 = FocusNode();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          width: size.width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: getPadding(
                    left: 16,
                    right: 4,
                    bottom: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: getPadding(
                          top: 20,
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
                          top: 8,
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
                      Padding(
                        padding: getPadding(
                          top: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  behavior: HitTestBehavior.opaque,
                                  child: Padding(
                                    padding: getPadding(right: 4),
                                    child: Icon(Icons.chevron_left_rounded,
                                        size: getSize(32), color: ColorConstant.gray800),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'with_whom_it_happened'.tr(),
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.left,
                                    style: AppStyle.txtH1.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width - 32,
                              child: CustomSearchView(
                                focusNode: _focus,
                                onChange: (text) {
                                  controller.changeCurrentEventList(text);
                                  controller.update();
                                },
                                onSubmit: (t) => _focus.unfocus(),
                                controller: controller.searchController,
                                hintText: 'find_person'.tr(),
                                variant: SearchViewVariant.FillGray200,
                                margin: getMargin(
                                  top: 16,
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
                                hintText: 'add_person'.tr(),
                                variant: SearchViewVariant.FillGray200,
                                margin: getMargin(
                                  top: 14,
                                  right: 16,
                                ),
                                onSubmit: (t)async {
                                  _focus2.unfocus();
                                  var result = (await Navigator.pushNamed(
                                      context, AppRoutes.addEmotion,
                                      arguments: {
                                        'initialValue':
                                        controller.addEventController.text,
                                        'title': 'add_person'.tr()
                                      }))
                                  as EventModel;
                                  if (result != null) {
                                    controller.currentEventList =
                                    await controller
                                        .updateCurrentEventList(result);
                                    controller.changeCurrentEventList(
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
                                                'title': 'add_person'.tr()
                                              }))
                                          as EventModel;
                                          if (result != null) {
                                            controller.currentEventList =
                                            await controller
                                                .updateCurrentEventList(result);
                                            controller.changeCurrentEventList(
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
                            Padding(
                                padding: getPadding(
                                  top: 24,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width - 32,
                                    child: GetBuilder(
                                      builder: (K26Controller _c) => Wrap(
                                        spacing: 16,
                                        runSpacing: 16,
                                        runAlignment: WrapAlignment.center,
                                        children: controller.currentEventList
                                            .map((el) => Padding(
                                          padding:
                                          const EdgeInsets.only(
                                              bottom: 10),
                                          child: EventCard(
                                            cardWidth:
                                            size.width / 2 - 30,
                                            iconSizeOverride: 50, neomorphic: true, borderRadiusOverride: 16,
                                            fontSizeOverride: 16,
                                            model: el, onTap: () {
                                                controller.whoDidHappen = el;
                                                controller.update();
                                              }, isSelect: controller.contain(el),),
                                            ))
                                            .toList(),
                                      ),
                                    ),
                                  ),
                                )),
                            GetBuilder(
                              builder: (K26Controller _c) => Visibility(
                                visible: controller.currentEventList.isEmpty,
                                child: Center(
                                  child: Container(
                                    width: getHorizontalSize(
                                      144,
                                    ),
                                    margin: getMargin(
                                      top: 37,
                                    ),
                                    child: Text(
                                      'person_not_found_add_your_own'.tr(),
                                      maxLines: null,
                                      textAlign: TextAlign.center,
                                      style:
                                      AppStyle.txtSFProDisplayLight14Gray800a01,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: getVerticalSize(40),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: getPadding(left: 16, top: 14, bottom: 10, right: 16),
                  child: GetBuilder(
                      builder: (K26Controller _c) => CustomButton(
                              height: getVerticalSize(40),
                              width: MediaQuery.of(context).size.width - 32,
                              bgColor: ColorConstant.cyan700,
                              showBorder: false,
                              borderRadius: 14,
                              glossy: true,
                              showShadow: false,
                              textStyle: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white, fontWeight: FontWeight.w600),

                              onTap: controller.currentEventList.isNotEmpty
                                  ? () {
                                if(controller.whoDidHappen == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('choose_person_or_create_new'.tr())));
                                } else {
                                  if(onSave!=null)
                                    onSave!(dayEventModel.copyWith(whoDidItHappen: controller.whoDidHappen));
                                    else
                                        Navigator.pushNamed(
                                            context, AppRoutes.whatEmotion,
                                            arguments: dayEventModel.copyWith(whoDidItHappen: controller.whoDidHappen));
                                      }
                                    }
                                  : () {
                                controller.searchController.text = '';
                                controller.changeCurrentEventList(
                                    controller.searchController.text);
                                controller.update();
                              },
                              text: 'continue'.tr().toUpperCase(),
                              margin: getMargin(
                                bottom: 10,
                              ),
                            ),
                    ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}