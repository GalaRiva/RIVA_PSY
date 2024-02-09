import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/models/day_event_model.dart';
import 'package:listenmebaby71_s_application17/presentation/main/path/additional_emotions_screen/k31_screen.dart';
import 'package:listenmebaby71_s_application17/presentation/main/path/what_body_parts_screen/k32_screen.dart';
import 'package:listenmebaby71_s_application17/presentation/main/path/what_emotion_screen/k27_screen.dart';
import 'package:listenmebaby71_s_application17/presentation/main/path/what_happened_screen/k22_screen.dart';
import 'package:listenmebaby71_s_application17/presentation/main/path/with_who_happened_screen/k26_screen.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/pages/after_working_out_page.dart';

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
  final controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return  Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Счастье в фокусе', style: AppStyle.txtSFProDisplayLight16,),
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
          Text('Напишите, что сегодня доставило приятные эмоции, состояния, ощущения или что впервые за долгое время полезного для себя заметили, осознали', style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.gray8008c),),
    SizedBox(height: 20,),
          Text('''Например,
     • я понял…
     • я наконец почувствовал..
     • я впервые за долгое время увидел красоту..
     • я впервые смог вдохнуть полной грудью..
     • было приятно….
     • здорово, что я сделал…
     • сегодня я почувствовал…
     • читаю интересную книгу..''', style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.gray8008c),),

          Padding(padding: EdgeInsets.symmetric(vertical: 15),
            child: SizedBox(
              width: MediaQuery.of(context).size.width - 60,
              child: TextFormField(
                controller: controller,
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
                      fontFamily: 'SF Pro Display',
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: ColorConstant.fromHex('#3B3B4A'),
                    )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Align(
              alignment: Alignment.topCenter,
              child: CustomButton(
                text: 'Далее',
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: () {
                  final cubit = context.read<HappinessInFocusCubit>();
                  cubit.setDayEventModel = DayEventModel.defaultModel.copyWith(firstThoughts: controller.text);
                  Navigator.push(context,
                  MaterialPageRoute(builder: (_) => K22Screen(dayEvent: cubit.dayEventModel, onSave: (event) {
                    Navigator.push(context,
                    MaterialPageRoute(builder: (_) => K25Screen(dayEvent: event, onSave: (event) {
                      Navigator.push(context,MaterialPageRoute(builder: (_) => K26Screen(dayEvent: event, onSave: (event) {
                        Navigator.push(context,MaterialPageRoute(builder: (_) => K27Screen(dayEvent: event, emotionsTypes: [EmotionInDayEvent.POSITIVE, EmotionInDayEvent.NEUTRAL], onSave: (event, emotions, category) {
                          Navigator.push(context,MaterialPageRoute(builder: (_) => K31Screen(dayEvent: event,category: category, someEmotions: emotions,  onSave: (event) {
                            Navigator.push(context,MaterialPageRoute(builder: (_) => K32Screen(dayEvent: event, onSave: (event) {
                              Navigator.pop(context);
                              cubit.setDayEventModel = event;
                              cubit.saveDayEventModel(whenSave: () {
                                showDialog(context: context, builder: (_) {
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
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
