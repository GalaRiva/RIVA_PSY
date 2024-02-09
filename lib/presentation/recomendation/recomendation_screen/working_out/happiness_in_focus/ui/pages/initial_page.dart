import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_bloc.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/bloc/happiness_in_focus_state.dart';

import '../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../core/utils/image_constant.dart';
import '../../../../../../../theme/app_style.dart';
import '../../../../../../../widgets/custom_button.dart';

class HappinessInFocusInitialPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            decoration:
            BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AspectRatio(
                      aspectRatio: 300 / 185,
                      child: Container(
                        color: ColorConstant.darkWhite,
                        child: Image.asset(ImageConstant.happinessInFocusInitial)
                      )),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Text(
                      'счастье в фокусе'.toUpperCase(),
                      style: AppStyle.txtSFProDisplayLight16,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      '''Вернуть свою жизнь себе. Задышать полной грудью. Стать спокойным, легким, уверенным, привлекательным человеком.
    
    Изучение себя- это не только про негативное, но и про приятное.
    
    Изучите себя с разных сторон.
    
    Постепенно, в графиках будут появляться новые данные, которые, в свою очередь, могут открыть новое в себе)''',
                      style: AppStyle.txtSFProDisplayLight12,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15,),
                    child: CustomButton(
                      text: 'НАЧАТЬ',
                      onTap: () {
                        context.read<HappinessInFocusCubit>().goToNextState(HappinessInFocusStage.StartHappinessInFocusState);
                      },
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 50,)
      ],
    );
  }
}
