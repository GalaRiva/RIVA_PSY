import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../../../../core/models/event_model.dart';
import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/image_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../widgets/custom_image_view.dart';
import '../../../../widgets/custom_message_box.dart';
import '../../../../widgets/inner_shadow.dart';
import 'repository.dart';

class K27Controller extends GetxController {

  final _repo = K27Repo();

  final searchController = TextEditingController();
  final addEventController = TextEditingController();

  late List<EventModel> currentEventListOne = _repo.standardEventListOne;
  late List<EventModel> currentEventListTwo = _repo.standardEventListTwo;
  late List<EventModel> currentEventListThree = _repo.standardEventListThree;
  late List<EventModel> currentEventListOneAfterInit = [];
  late List<EventModel> currentEventListTwoAfterInit = [];
  late List<EventModel> currentEventListThreeAfterInit = [];
  EventModel? emotion;
  int emotionIntensity = 10;

  int currentTab = 1;

  bool contain (EventModel _event) {
    if(emotion != null && emotion!.identity == _event.identity) {
      return true;
    }
    return false;
  }

  late List<EventModel> currentEventList = _repo.standardEventListOne;

  List<EventModel> getCurrentListByNumber (int number) => number == 1 ? currentEventListOne :  number == 2 ? currentEventListTwo : currentEventListThree;

  Future<List<EventModel>> changeCurrentEventList (String text) async {
    var list = getCurrentListByNumber(currentTab);
    if(text.isNotEmpty) {
      if (list.isNotEmpty)
        list = [];
      for (final event in await initCurrentEventList(1) + await initCurrentEventList(2) + await initCurrentEventList(3)) {
        if (event.name.toLowerCase().contains(text.toLowerCase())) list.add(event);
      }
    } else {
      list = await initCurrentEventList(currentTab);
    }
    currentTab == 1 ? currentEventListOne = list :  currentTab == 2 ? currentEventListTwo = list: currentEventListThree= list;
    currentTab == 1 ? currentEventListOneAfterInit = list :  currentTab == 2 ? currentEventListTwoAfterInit = list: currentEventListThreeAfterInit= list;

    return list;
  }

  double getTabHeight () {
    final double minimumHeight = currentTab == 3 ? 350 : 100;
    final list = getCurrentListByNumber(currentTab);
    final listLength = currentTab == 3 ? (list.length / 4) * 2 : (list.length / 3);
    if (list.length > 4) {
      if (list.length < 8) return ((listLength * 80) + minimumHeight + 80);
      print(listLength);
      return ((listLength * 80) + minimumHeight);
    } else if (list.length > 1){
      return (400);
    } else {
      return (400);
    }
  }

  Future<List<EventModel>> updateCurrentEventList (EventModel model, int numberList) async {
    final listToUpdate = numberList == 1 ? await initCurrentEventList(1) :  numberList == 2 ? await initCurrentEventList(2) : await initCurrentEventList(3);
    if(currentTab == 3) {
      listToUpdate.add(model..name += ' +');
      listToUpdate.add(model..name += ' -');
    }else listToUpdate.add(model);
        await _repo.updateEvent(listToUpdate, _repo.getTag(numberList));
    return listToUpdate;
  }

  Future<List<EventModel>> initCurrentEventList (int numberList) async {
        return _repo.getEvent(_repo.getTag(numberList));
  }

  Future showEmotionIntensityDialog(BuildContext context, K27Controller controller, String emotion) => showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return GetBuilder(
          builder: (K27Controller _c) => CustomMessageBox(
            title: emotion,
            onPop: () {

            },
            height: 261,
            content: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'rate_emotion_intensity'.tr(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        fontFamily: 'Manrope'),
                  ),
                  Center(
                    child: Card(
                      clipBehavior: Clip.antiAlias,
                      elevation: 0,
                      margin: getMargin(
                        top: 12,
                      ),
                      color: ColorConstant.gray2007c,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          getHorizontalSize(
                            101,
                          ),
                        ),
                      ),
                      child: Container(
                        height: getSize(
                          202,
                        ),
                        width: getSize(
                          202,
                        ),
                        padding: getPadding(
                          left: 17,
                          top: 19,
                          right: 17,
                          bottom: 19,
                        ),
                        decoration: AppDecoration.fillGray2007c.copyWith(
                          borderRadius: BorderRadiusStyle.circleBorder101,
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: getMargin(
                                  left: 3,
                                  right: 3,
                                ),
                                padding: getPadding(
                                  left: 22,
                                  right: 22,
                                ),
                                decoration: BoxDecoration(),
                              ),
                            ),
                            SizedBox(
                              height: 220,
                              width: 220,
                              child:  SleekCircularSlider(
                                  onChangeEnd: (_value) {
                                    emotionIntensity = _value.toInt();
                                    controller.update();
                                  },
                                  appearance: CircularSliderAppearance(
                                      animationEnabled: false,
                                      infoProperties: InfoProperties(
                                          topLabelText: '',
                                          mainLabelStyle: TextStyle(color: Colors.transparent)
                                      ),
                                      startAngle: 105,
                                      angleRange: 330,
                                      size: 220,
                                      customColors: CustomSliderColors(
                                        trackColor: Colors.white,
                                        dotColor: ColorConstant.fromHex("#768295"),
                                        progressBarColors: [
                                          ColorConstant.fromHex('#403875'),
                                          ColorConstant.fromHex('#7FBDBA'),
                                        ],
                                      ),
                                      customWidths: CustomSliderWidths(
                                          handlerBorderWidth: 9,
                                          progressBarWidth: 15,
                                          handlerSize: 12,
                                          trackWidth: 15)),
                                  min: 0,
                                  max: 10,
                                  initialValue: 10,
                                ),
                            ),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: getSize(95),
                                height: getSize(95),

                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(color: const Color(0xFF2A456F).withOpacity(0.6), blurRadius: 1, spreadRadius: 0),
                                    BoxShadow(color:ColorConstant.fromHex('#D7E1E1'), blurRadius: 10, spreadRadius: 5),
                                  ],
                                ),
                              ),
                            ),
                            IgnorePointer(
                              child: CustomImageView(
                                svgPath: ImageConstant.imgFrame185,
                                fit: BoxFit.fill,
                                height:
                                  145
                                ,
                                width: getHorizontalSize(
                                  120,
                                ),
                                alignment: Alignment.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
