import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/cubit.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/state.dart';

import '../../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../../core/utils/image_constant.dart';
import '../../../../../../../../theme/app_style.dart';
import '../../../../../../../../widgets/custom_button.dart';

class SuperQuestStartPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
              padding: EdgeInsets.all(12),
              decoration:
              BoxDecoration(
                  color: ColorConstant.gray200,
                  border: Border.all(color: Colors.white, width: 1)),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: SvgPicture.asset(
                        ImageConstant.imgCloseGray200,
                        width: 10,
                        height: 10,
                        color: ColorConstant.blueGray400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(child: Text('three_days_without_complaints'.tr().toUpperCase(),style: AppStyle.txtSFProDisplayLight16,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('three_days_without_one_complaints'.tr(),style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  Container(
                    child: AspectRatio(
                      aspectRatio: 230/190,
                      child: Image.asset(ImageConstant.happinessInFocusMessage, fit: BoxFit.cover,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(child: Text('${'during_the_first_attempts'.tr()})',style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('quest_very_difficult'.tr(),
                    style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  CustomButton(
                    text: 'start2'.tr().toUpperCase(),
                    variant: ButtonVariant.Cyan,
                    fontStyle: ButtonFontStyle.White16,
                    onTap: (){
                      context.read<SuperQuestCubit>().goToNextState(SuperQuestStage.middle);
                    },
                  ),
                ],
              ))),
    );
  }
}
