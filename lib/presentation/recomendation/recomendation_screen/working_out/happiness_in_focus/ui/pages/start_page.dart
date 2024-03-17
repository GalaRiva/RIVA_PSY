import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';

import '../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../core/utils/image_constant.dart';
import '../../../../../../../theme/app_style.dart';
import '../../../../../../../widgets/custom_button.dart';
import '../widgets/super_quest_message.dart';

class HappinessInFocusStartPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<HappinessInFocusCubit>();
    return  SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: ColorConstant.cyan700,
                  border: Border.all(color: Colors.white, width: 1),
                  boxShadow: [
                    BoxShadow(
                        color: ColorConstant.cardShadow,
                        offset: Offset(0, -0.2))
                  ]
                      ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 1,
                          width: 26,
                          color: Colors.white,
                        ),
                        Text(
                          'СЧАСТЬЕ В ФОКУСЕ',
                          style: AppStyle.txtSFProDisplayLight16
                              .copyWith(color: Colors.white),
                        ),
                        Container(
                          height: 1,
                          width: 26,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '''Сейчас последовательно, одно за другим, посмотрим на 1-3-5 моментов сегодняшнего дня, в которых Вам было хорошо… или... более-менее хорошо''',
                      style: AppStyle.txtSFProDisplayLight16.copyWith(color: Colors.white),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    AspectRatio(
                      aspectRatio: 300 / 240,
                      child: Container(
                        decoration: BoxDecoration(
                            color: ColorConstant.darkWhite,
                            borderRadius: BorderRadius.circular(3)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: Image.asset(ImageConstant.happinessInFocusStart)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Align(
                alignment: Alignment.topCenter,
                child: CustomButton(
                  text: 'Далее'.toUpperCase(),
                  bgColor: Color(0xff66C1BD),
                  fontStyle: ButtonFontStyle.White16,
                  onTap: () => context.read<HappinessInFocusCubit>().goToNextState(HappinessInFocusStage.ThoughtsHappinessInFocusState),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 40),
              child: CustomButton(
                text: 'Супер задание'.toUpperCase(),
                //variant: ButtonVariant.Cyan,
                //fontStyle: ButtonFontStyle.White16,
                textStyle: TextStyle(fontSize: 20, color: ColorConstant.deepPurple500, fontWeight: FontWeight.w300),
                onTap: (){
                  showDialog(context: context, builder: (_) => Center(child: SuperQuestMessage(positiveRecords: cubit.positiveDayEventModels))).then((value) {
                    cubit.goToNextState(HappinessInFocusStage.StartHappinessInFocusState);
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
