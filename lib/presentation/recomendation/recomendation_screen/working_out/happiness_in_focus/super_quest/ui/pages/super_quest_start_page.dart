import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/cubit.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/state.dart';

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
                    child: Center(child: Text('три дня без жалоб'.toUpperCase(),style: AppStyle.txtSFProDisplayLight16,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Три дня без единой жалобы. Ни на погоду, ни на здоровье, политику, работу, близкого человека, транспорт, ни тем более на себя- ни о чем!)',style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  Container(
                    child: AspectRatio(
                      aspectRatio: 230/190,
                      child: Image.asset(ImageConstant.happinessInFocusMessage, fit: BoxFit.cover,),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(child: Text('Во время первых попыток могут всплывать подавленные негативные эмоции, обиды- фиксируй их в приложении и проходи аудио сессии.)',style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Задание поистине сложное, будь снисходителен к себе. Ошибки- часть нашего пути.\n\nНе спеши.',
                    style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  CustomButton(
                    text: 'приступить'.toUpperCase(),
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
