import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:intl/intl.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/day_event_model.dart';
import 'package:riva_psy/presentation/main/path/additional_emotions_screen/k31_screen.dart';
import 'package:riva_psy/presentation/main/path/what_body_parts_screen/k32_screen.dart';
import 'package:riva_psy/presentation/main/path/what_emotion_screen/k27_screen.dart';
import 'package:riva_psy/presentation/main/path/what_happened_screen/k22_screen.dart';
import 'package:riva_psy/presentation/main/path/what_i_do_screen/k37_screen.dart';
import 'package:riva_psy/presentation/main/path/with_who_happened_screen/k26_screen.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/after_working_out_page.dart';

import '../../../../../../../main.dart';
import '../../../../../../../theme/app_style.dart';
import '../../../../../../../widgets/custom_button.dart';
import '../../../../../../charts/charts_screen/controller.dart';
import '../../../../../../main/path/add_emotion_screen/controller.dart';
import '../../../../../../main/path/additional_emotions_screen/controller.dart';
import '../../../../../../main/path/first_thougths_screen/controller.dart';
import '../../../../../../main/path/what_body_parts_screen/controller.dart';
import '../../../../../../main/path/what_emotion_screen/controller.dart';
import '../../../../../../main/path/what_happened_screen/controller.dart';
import '../../../../../../main/path/where_happened_screen/controller.dart';
import '../../../../../../main/path/where_happened_screen/k25_screen.dart';
import '../../../../../../main/path/with_who_happened_screen/controller.dart';
import '../../../../../../records/records_screen/controller.dart';
import '../../bloc/happiness_in_focus_bloc.dart';

class HappinessInFocusThoughtsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HappinessInFocusCubit>();

    return  SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('happiness_in_focus'.tr(), style: AppStyle.txtSFProDisplayLight16,),
                Text(DateFormat('dd.MM.yy').format(DateTime.now()), style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.gray8008c),)
              ],
            ),
            SizedBox(height: 5,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 1,
                  width: 26,
                  color: Colors.white,
                ),
                Container(
                  height: 1,
                  width: 26,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(height: 25,),
            AspectRatio(
                aspectRatio: 300/260,
                child: Container(
                  padding: EdgeInsets.all(35),
                  decoration: BoxDecoration(color: ColorConstant.darkWhite,
                  borderRadius: BorderRadius.circular(3)),
                    child: AspectRatio(
                      aspectRatio: 230/190,
                      child: Image.asset(ImageConstant.happinessInFocusThoughts, fit: BoxFit.cover,),
                    ),
                )),
            Text('write_what_today_gave_pleasant_emotions'.tr(), style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.gray8008c),),
      SizedBox(height: 20,),
            Text('for_example'.tr(), style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.gray8008c),),

            Padding(padding: EdgeInsets.symmetric(vertical: 15),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 60,
                child: TextFormField(
                  controller: cubit.thoughtController,
                  onTapOutside: (_) => FocusScope.of(context).unfocus(),
                  maxLines: 10,
                  minLines: 4,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide.none),
                      fillColor: ColorConstant.grayLight,
                      filled: true,
                      hintText: '',
                      hintStyle: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: ColorConstant.fromHex('#3B3B4A'),
                      )),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              child: Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [

                    CustomButton(
                      bgColor: Colors.white.withOpacity(0.6),

                      text: 'back'.tr().toUpperCase(),
                      width: (size.width - 60 )/ 2,
                      onTap: () => cubit.goToPrevState(context),
                    ),
                    CustomButton(
                      bgColor: Colors.white.withOpacity(0.6),
                      text: 'continue'.tr().toUpperCase(),
                      width: (size.width - 60 )/ 2,
                      //variant: ButtonVariant.Almost,
                      onTap: () {
                        cubit.setDayEventModel = DayEventModel.defaultModel.copyWith( howDoYouFeel: 10, showInCharts: true, firstThoughts: cubit.thoughtController.text);
                        debugPrint(cubit.dayEventModel?.toJson().toString());
                        Navigator.push(context,
                        MaterialPageRoute(builder: (_) => K22Screen(dayEvent: cubit.dayEventModel, onSave: (event) {
                          debugPrint(event.toJson().toString());
                          Navigator.push(context,
                          MaterialPageRoute(builder: (_) => K25Screen(dayEvent: event, onSave: (event) {
                            Navigator.push(context,MaterialPageRoute(builder: (_) => K26Screen(dayEvent: event, onSave: (event) {
                              debugPrint(event.toJson().toString());
                              Navigator.push(context,MaterialPageRoute(builder: (_) => K27Screen(dayEvent: event.copyWith(date: DateTime.now()), emotionsTypes: [EmotionInDayEvent.POSITIVE, EmotionInDayEvent.NEUTRAL], onSave: (event, emotions, category) {
                                debugPrint(event.toJson().toString());
                                Navigator.push(context,MaterialPageRoute(builder: (_) => K31Screen(dayEvent: event,category: category, someEmotions: emotions,  onSave: (event) {
                                  debugPrint(event.toJson().toString());
                                  Navigator.push(context,MaterialPageRoute(builder: (_) => K32Screen(dayEvent: event, onSave: (event) {
                                    debugPrint(event.toJson().toString());
                                    Navigator.push(context,MaterialPageRoute(builder: (_) => K37Screen(dayEvent: event, onSave: (event) {
                                      debugPrint(event.toJson().toString());

                                      Navigator.popUntil(context, (route) => route.settings.name == ModalRoute.of(context)?.settings.name);
                        cubit.setDayEventModel = event;
                                      cubit.thoughtController.text = '';
                        cubit.saveDayEventModel(whenSave: () {
                        showDialog(context: MyApp.navigatorKey.currentContext!, builder: (_) {
                        return HappinessInFocusAfterWorkingOutPage(cubit: cubit,);
                        });
                        });
                        cubit.goToNextState(HappinessInFocusStage.StartHappinessInFocusState);
                        Get.delete<K22Controller>();
                        Get.delete<K24Controller>();
                        Get.delete<K25Controller>();
                        Get.delete<K26Controller>();
                        Get.delete<K27Controller>();
                        Get.delete<K31Controller>();
                        Get.delete<K32Controller>();
                        Get.delete<K38Controller>();
                        Get.delete<K49Controller>();
                        Get.delete<K61Controller>();
                        },)));
                                  },)));
                                },)));
                              },)));
                            },)));
                          },)));
                        },)));
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
