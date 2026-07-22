  import 'package:get/get.dart';
import 'widgets/screen_body_widget.dart';

import '../../../../core/models/day_event_model.dart';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import 'widgets/voice_button.dart';
import 'controller.dart';

class K39Screen extends GetWidget {

  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel = (ModalRoute.of(context)?.settings.arguments! ?? DayEventModel()) as DayEventModel;

    final controller = Get.put(K39Controller(dayEventModel));
    controller.currentState = ButtonState.BeforeRecording;
    controller.initRecorder();
    return WillPopScope(
      onWillPop: () async{
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorConstant.gray300,
        body: SafeArea(
          child: SizedBox(
            width: size.width,
            child: Stack(            alignment: Alignment.bottomCenter,

              children: [
                SingleChildScrollView(

                   child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           mainAxisAlignment: MainAxisAlignment.start,
                           children: [
                             Padding(
                               padding: getPadding(
                                 left: 15,
                                 right: 10,
                                 top: 39,
                               ),
                               child: Text(
                                 "Эмоция сейчас",
                                 overflow: TextOverflow.ellipsis,
                                 textAlign: TextAlign.left,
                                 style: AppStyle.txtSFProDisplayLight10Gray800,
                               ),
                             ),
                             Padding(
                               padding: getPadding(
                                 top: 12,
                                 left: 10,
                                 right: 10,
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
                                 left: 16,
                                 right: 10,
                                 top: 15,
                               ),
                               child: Text(
                                 "Как прожить эмоции",
                                 overflow: TextOverflow.ellipsis,
                                 textAlign: TextAlign.left,
                                 style: AppStyle.txtH1,
                               ),
                             ),
                             Padding(
                                 padding: getPadding(left: 10, right: 10),
                                 child: GetBuilder(builder: (K39Controller _c) => VoiceButton(currentState: controller.currentState, controller: controller,))),
                             Padding(
                               padding: getPadding(
                                 top: 30,
                               ),
                               child: ScreenBodyWidget(isNegative: dayEventModel.emotionInDayEvent == EmotionInDayEvent.NEGATIVE, dayEventModel: dayEventModel,)
                             ),
                             SizedBox(
                               height: getVerticalSize(140),
                             )
                           ],
                         ),
                       ),
          Container(
            width: size.width,
            height: getVerticalSize(60),
            margin: getMargin(
              bottom: 0,
            ),
              alignment: Alignment.bottomCenter,

              color: ColorConstant.gray300,
            child: Center(
          child: Padding(
            padding: getPadding(left: 26, bottom: 10, right: 26),
            child: CustomButton(
              width: getHorizontalSize(
                148,
              ),
              text: "гОТОВО".toUpperCase(),
              onTap: () async {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.main, (route) => false);
                controller.deleteAllController();
              },
              alignment: Alignment.bottomCenter,
            ),
          ),
      )
          )
              ],
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          onChanged: (BottomBarEnum type) {},
        ),
      ),
    );
  }

  ///Handling page based on route

}
