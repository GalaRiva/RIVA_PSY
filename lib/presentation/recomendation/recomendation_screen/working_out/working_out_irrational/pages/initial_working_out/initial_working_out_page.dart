import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../bloc/cubit.dart';
import '../../bloc/state.dart';
import '../working_out_widget.dart';

class InitialWorkingOutPage extends WorkingOutWidget {

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration:
              BoxDecoration(border: Border.all(color: Colors.white, width: 1)),
          child: Column(
            children: [
              AspectRatio(
                  aspectRatio: 300 / 230,
                  child: Container(
                    color: ColorConstant.darkWhite,
                    child: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 38, right: 38, top: 38, bottom: 28),
                            child: Container(
                              color: ColorConstant.blueGreen,
                            ),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(left: size.width / 100 * 14),
                              child: Image.asset(ImageConstant.workingOutImg),
                            )),
                        Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding:
                                  EdgeInsets.only(right: size.width / 100 * 14),
                              child:
                                  Image.asset(ImageConstant.bubbleImg),
                            ))
                      ],
                    ),
                  )),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Отработать иррациональное'.toUpperCase(),
                  style: AppStyle.txtSFProDisplayLight16,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text(
                  'Пожалуйста, помни, что это видишь только ты  и выгода быть честным с собой- твоя. Наша поддержка и тепло с тобой!',
                  style: AppStyle.txtSFProDisplayLight12,
                ),
              ),
              Text(
                'Рекомендуется проходить в день 2- 3 записи. Не спеши. Мы за качество, а не количество. Пусть новое и прекрасное обживается и стабилизируется.',
                style: AppStyle.txtSFProDisplayLight12,
              ),
              Padding(
                padding: EdgeInsets.only(top: 15, bottom: 10),
                child: CustomButton(
                  text: 'АЛЬТЕРНАТИВА',
                  onTap: () {
                    cubit.goToNextState(WorkingOutIrrationalStage.alternative);
                  },
                ),
              ),
              CustomButton(
                text: 'НАЧАТЬ',
                onTap: () {
                  cubit.goToNextState(WorkingOutIrrationalStage.challengeThought);
                },
              ),
              SizedBox(height: 50,)

            ],
          ),
        ),
      ),
    );
  }

  Widget backdropFilterExample(BuildContext context, Widget child) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        child,
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 5.0,
            sigmaY: 5.0,
          ),
          child: Container(
            color: Colors.transparent,
          ),
        )
      ],
    );
  }

  @override
  WorkingOutIrrationalStage stage() => WorkingOutIrrationalStage.initialStage;
}
