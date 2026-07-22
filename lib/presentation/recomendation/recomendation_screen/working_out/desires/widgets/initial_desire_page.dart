import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/bloc/bloc.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../../../core/utils/image_constant.dart';
import '../../../../../../core/utils/size_utils.dart';
import '../../../../../../theme/app_style.dart';

class InitialDesirePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white, width: 1)
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            AspectRatio(aspectRatio: 3/1.5,
            child: Image.asset(ImageConstant.desiresStartPNG, fit: BoxFit.fill ,)),
            SizedBox(height: 20,),
            Text('желания'.toUpperCase(), style: AppStyle.txtSFProDisplayLight16,),
            SizedBox(height: 20,),
            Text('''Это не про великие мечты, цели и гонки, а самые простые желания.

Желания касаются простых вещей. Упражнение для того, чтобы научиться слышать себя и свои истинные желания.

Пишите то, что Вы любите или нравится и то, что Вы хотите.
Какое именно?

Что я хочу сейчас? Какую-нибудь мелочь здесь и сейчас.
Я хочу пить/лечь/сесть/спать, рыбу, яблоко, фильм, книгу, - любое и какое именно.
'''.toUpperCase(), style: AppStyle.txtSFProDisplayLight12,),

            SizedBox(height: 20,),
            Row(children: [
              Expanded(
                child: CustomButton(
                  text: 'НАЧАТЬ',
                  onTap: () {
                    context.read<DesiresBloc>().add(DesiresEvent.start());
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: CustomButton(
                  text: 'ПОДРОБНЕЕ',
                  onTap: () {
                    context.read<DesiresBloc>().add(DesiresEvent.getDetails(context));
                  },
                ),
              )
            ],),
            SizedBox(height: 10,),
            CustomButton(
              width: size.width / 2 - 20,
              text: 'ОТЧЁТ',
              onTap: () {
                context.read<DesiresBloc>().add(DesiresEvent.goToReport());
              },
            ),
          ],
        ),
      ),

    );
  }
}
