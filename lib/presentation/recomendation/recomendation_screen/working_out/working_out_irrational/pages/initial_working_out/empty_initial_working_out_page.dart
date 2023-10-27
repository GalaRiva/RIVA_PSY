import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../../../../../core/models/day_event_model.dart';
import '../../bloc/cubit.dart';
import '../../bloc/state.dart';
import '../../widgets/relax_dialog/relax_dialog.dart';
import '../working_out_widget.dart';

class EmptyInitialWorkingOutPage extends WorkingOutWidget {

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
                  aspectRatio: 300 / 200,
                  child: Container(
                    color: ColorConstant.gray300,
                    child:
                        Image.asset(ImageConstant.handImg,),
                  )),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Проходи Путь, добавляй мысли, эмоции и пересоздавай неприятное в позитивное',
                  style: AppStyle.txtSFProDisplayLight16,
                  overflow: TextOverflow.visible,
                ),
              ),
              CustomButton(
                text: 'НАЧАТЬ',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.whatHappened, arguments: DayEventModel()..howDoYouFeel = 5);
                },
              ),
              SizedBox(height: 50,)

            ],
          ),
        ),
      ),
    );
  }

  @override
  WorkingOutIrrationalStage stage() => WorkingOutIrrationalStage.initialStage;
}
