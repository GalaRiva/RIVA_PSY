import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

class GratitudePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(3)),
          child: Container(
            margin: EdgeInsets.all(1),
            decoration: BoxDecoration(color: ColorConstant.gray200, borderRadius: BorderRadius.circular(3)),
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                children: [
                  Text('спасибо тебе!'.toUpperCase(), textAlign: TextAlign.center,
                    style: AppStyle.txtSFProDisplayLight16,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Размышляя и записывая альтернативу ежедневно в течении 30 дней, ты заметишь разницу своего состояния.',
                      textAlign: TextAlign.center,
                      style: AppStyle.txtSFProDisplayLight16,),
                  ),
                  Stack(alignment: Alignment.center,children: [
                    Image.asset(ImageConstant.humanGratitudeImg),
                    Positioned(
                      left:  - 31, right:  -31,
                      child:                   Image.asset(ImageConstant.gratitudeLineImg),
                    )
                  ], clipBehavior: Clip.none,),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'Однако, на останавливайся на этом. Чем дольше ведешь, тем шире и богаче становится твоя жизнь',
                      textAlign: TextAlign.center,
                      style: AppStyle.txtSFProDisplayLight16,),
                  ),
                  if(cubit.existMoreDontWorkingOutEvents() && cubit.state.dayEventModel != null)
                  Padding(
                    padding:  EdgeInsets.only(bottom: 15),
                    child: CustomButton(text:'ещё мысль'.toUpperCase(), fontStyle: ButtonFontStyle.DeepPurple16, onTap: () => cubit.goToNextState(WorkingOutIrrationalStage.challengeThought),),
                  ),
                  CustomButton(text:'продолжить позже'.toUpperCase(), fontStyle: ButtonFontStyle.White16, variant: ButtonVariant.Cyan, onTap: () => cubit.goToNextState(WorkingOutIrrationalStage.alternative),),
                ],
              ),

            ),
          ),
        ),
      ),
    );
  }
}
