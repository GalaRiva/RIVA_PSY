import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/bloc/state.dart';
import 'package:riva_psy/widgets/custom_button.dart';

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
                  Text('thank_you'.tr().toUpperCase(), textAlign: TextAlign.center,
                    style: AppStyle.txtSFProDisplayLight16,),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'thinking_and_recording'.tr(),
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
                      'but_not_stopped'.tr(),
                      textAlign: TextAlign.center,
                      style: AppStyle.txtSFProDisplayLight16,),
                  ),
                  if(cubit.existMoreDontWorkingOutEvents() && cubit.state.dayEventModel != null)
                  Padding(
                    padding:  EdgeInsets.only(bottom: 15),
                    child: CustomButton(text:'one_more_thought'.tr().toUpperCase(), fontStyle: ButtonFontStyle.DeepPurple16, onTap: () => cubit.goToNextState(WorkingOutIrrationalStage.challengeThought),),
                  ),
                  CustomButton(text:'continue_later'.tr().toUpperCase(), fontStyle: ButtonFontStyle.White16, variant: ButtonVariant.Cyan, onTap: () => cubit.goToNextState(WorkingOutIrrationalStage.alternative),),
                  SizedBox(height: 50,)
                ],
              ),

            ),
          ),
        ),
      ),
    );
  }
}
