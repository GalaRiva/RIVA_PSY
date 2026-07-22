import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/ui/widgets/super_quest_message.dart';

import '../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../widgets/custom_button.dart';

class HappinessInFocusAfterWorkingOutPage extends StatelessWidget {
  final HappinessInFocusCubit cubit;
  const HappinessInFocusAfterWorkingOutPage({Key? key, required this.cubit});

  Widget _title (int progress) {
    late final String text;
    switch (progress) {
      case 1:
        text = 'ЗДОРОВО!';
        break;
      case 2:
        text = 'Ты имеешь право чувствовать счастье.';
        break;
      case 3:
        text = 'Ты имеешь право на мысли и эмоции.';
        break;
      case 4:
        text = 'Вселенная сегодня такая, благодаря тому, что ты есть';
        break;
      default:
        text = 'Спасибо тебе, что ты есть!';
        break;
    }
    return Text(text.toUpperCase(), style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.gray8008c), textAlign: TextAlign.center,);
  }

  Widget _image (int progress) {
    final images = [
      ImageConstant.happinessInFocusAfter1,
      ImageConstant.happinessInFocusAfter2,
      ImageConstant.happinessInFocusAfter3,
      ImageConstant.happinessInFocusAfter4,
      ImageConstant.happinessInFocusAfter5,

    ];
    final String image = images[progress > 4 ? 5 : progress];
    return AspectRatio(aspectRatio: 230/190,
      child: Image.asset(image, fit: BoxFit.cover,),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(15),
        child: Material(
          child: Container(
              padding: EdgeInsets.all(12),
              decoration:
              BoxDecoration(
                  color: ColorConstant.gray200,
                  border: Border.all(color: Colors.white, width: 1)),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(child: _title(cubit.todayWorkingOut > 4 ? 5 : cubit.todayWorkingOut)),
                    ),
                    Container(
                      padding: EdgeInsets.all(35),
                      child: AspectRatio(
                        aspectRatio: 300/260,
                        child: _image(cubit.todayWorkingOut),
                      ),
                    ),
                    CustomButton(
                      text: 'Далее'.toUpperCase(),
                      variant: ButtonVariant.Cyan,
                      fontStyle: ButtonFontStyle.White16,
                      onTap: (){
                        Navigator.pop(context);
                        cubit.goToNextState(HappinessInFocusStage.StartHappinessInFocusState);
                      },
                    ),
                    CustomButton(
                      text: 'Продолжу позже'.toUpperCase(),
                      variant: ButtonVariant.Cyan,
                      fontStyle: ButtonFontStyle.White16,
                      onTap: (){
                        Navigator.pop(context);
                        cubit.goToNextState(HappinessInFocusStage.InitialHappinessInFocusState);
                      },
                    ),
                    Container(
                      padding: EdgeInsets.all(35),
                      child: AspectRatio(
                        aspectRatio: 300/260,
                        child: AspectRatio(
                          aspectRatio: 230/190,
                          child: Image.asset(ImageConstant.happinessInFocusSuperQuest, fit: BoxFit.cover,),
                        ),
                      ),
                    ),
                    CustomButton(
                      text: 'Супер задание'.toUpperCase(),
                      variant: ButtonVariant.Cyan,
                      fontStyle: ButtonFontStyle.White16,
                      onTap: (){
                        showDialog(context: context, builder: (_) => Center(child: SuperQuestMessage(positiveRecords: cubit.positiveDayEventModels))).then((value) {
                          cubit.goToNextState(HappinessInFocusStage.StartHappinessInFocusState);
                        });
                      },
                    ),
                  ].map((e) => Padding(padding: EdgeInsets.only(bottom: 15), child: e,)).toList(),
                ),
              )),
        ));
  }
}