  import 'package:easy_localization/easy_localization.dart';
import 'package:get/get.dart' hide Trans;
import 'widgets/screen_body_widget.dart';

import '../../../../core/models/day_event_model.dart';

import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import 'widgets/voice_button.dart';
import 'widgets/exercise_content/controller.dart';
import 'controller.dart';
import '../../../../theme/app_colors.dart';

class K39Screen extends GetWidget {

  // ExerciseContentController owns the shared AudioPlayer for this screen's
  // practices carousel. Nothing was ever deleting it on the way out — via
  // either the back button or "Завершить практику" — so a track left
  // playing kept playing indefinitely with no UI left to reach a pause
  // button. Get.delete() runs the controller's onClose(), which disposes
  // the player.
  void _stopExerciseAudio() {
    if (Get.isRegistered<ExerciseContentController>()) {
      Get.delete<ExerciseContentController>();
    }
  }

  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel = (ModalRoute.of(context)?.settings.arguments! ?? DayEventModel()) as DayEventModel;

    final controller = Get.put(K39Controller(dayEventModel));
    controller.currentState = ButtonState.BeforeRecording;
    controller.initRecorder();
    return WillPopScope(
      onWillPop: () async{
        _stopExerciseAudio();
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SizedBox(
            width: size.width,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SingleChildScrollView(

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
                                 'current_emotion'.tr(),
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
                                 'how_to_live_through_emotions'.tr(),
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
                ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: getPadding(left: 26, top: 14, bottom: 10, right: 26),
              child: CustomButton(
                height: getVerticalSize(32),
                // 'finish_practice' ("Завершить практику" / "Finish the
                // practice") runs longer than the old "Готово" — a fixed
                // 148 clipped it. Width now tracks the screen instead.
                width: MediaQuery.of(context).size.width - getHorizontalSize(52),
                variant: ButtonVariant.Base,
                textIsFitted: true,
                text: 'finish_practice'.tr().toUpperCase(),
                onTap: () async {
                  _stopExerciseAudio();
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.main, (route) => false);
                  controller.deleteAllController();
                },
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
      ),
    );
  }

  ///Handling page based on route

}
