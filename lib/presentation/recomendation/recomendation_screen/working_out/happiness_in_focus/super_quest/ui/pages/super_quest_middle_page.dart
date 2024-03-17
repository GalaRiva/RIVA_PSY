import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/cubit.dart';

import '../../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../../core/utils/image_constant.dart';
import '../../../../../../../../theme/app_style.dart';
import '../../../../../../../../widgets/custom_button.dart';

class SuperQuestMiddlePage extends StatelessWidget {

  String _image(int progress) {
    final images = [
      ImageConstant.superQuestMiddle1,
      ImageConstant.superQuestMiddle2,
      ImageConstant.superQuestMiddle3,

    ];
    return progress > 3 ? images[2] : images[progress -1 ];
  }

  String _text (int progress) {
    final images = [
      'Ты будешь гордиться собой, потому что выполнив, вероятно, поймешь насколько это сложно. То, что ты получишь будет ценнее любых звездочек на экране.\n\nКак выполнишь- поставь здесь галочку',
      '“..в принципе нам следует подготовиться к потрясающим последствиям, которые наступят, если мы перестанем ссылаться на социальную несправедливость.\nА. Маслоу',
      '“Я не в силах предвидеть, я в силах созидать. Будущее создают. Если у меня рука ваятеля, то прекрасным лицом станут дробные черты моего времени и то, чего я хочу, осуществится.\nЦитадель. Антуан де Сент-Экзюпери',
    ];
    return progress > 3 ? images[2] : images[progress - 1 ];
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SuperQuestCubit>();
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
                    child: Center(child: Text('без жалоб. Ни в словах, ни в мыслях',style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  AspectRatio(
                    aspectRatio: 230/105,
                    child: Image.asset(_image(cubit.state.dayQuantityAfterStart == 0 ? 1 : cubit.state.dayQuantityAfterStart), fit: BoxFit.cover,),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Center(child: Text(_text(cubit.state.dayQuantityAfterStart == 0 ? 1 : cubit.state.dayQuantityAfterStart),style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: GestureDetector(
                      onTap: () {
                        cubit.confirm();
                      },
                      child: Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: ColorConstant.darkWhite),
                        child: Center(
                          child: SvgPicture.asset(ImageConstant.okeyIcon, color: cubit.state.confirm ? ColorConstant.cyan700 : ColorConstant.gray200, width: 24,),
                        ),
                      ),
                    )),
                  ),
                  CustomButton(
                    text: 'cохранить'.toUpperCase(),
                    variant: ButtonVariant.Cyan,
                    fontStyle: ButtonFontStyle.White16,
                    onTap: (){
                      cubit.save();
                    },
                  ),
                  SizedBox(height: 10,),

                  CustomButton(
                    text: 'отменить результат'.toUpperCase(),
                    variant: ButtonVariant.Cyan,
                    fontStyle: ButtonFontStyle.White16,
                    onTap: (){
                      cubit.goToPrevState(context);
                    },
                  ),
                ],
              ))),
    );
  }
}
