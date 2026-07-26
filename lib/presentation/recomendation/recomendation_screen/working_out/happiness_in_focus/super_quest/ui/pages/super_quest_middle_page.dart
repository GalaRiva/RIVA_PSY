import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/cubit/cubit.dart';

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
      'you_will_pride'.tr(),
      'in_principe_we_should'.tr(),
      'i_cant_anticipate'.tr(),
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
                    child: Center(child: Text('three_days_without_complaints'.tr().toUpperCase(),style: AppStyle.txtSFProDisplayLight16,)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('without_complaints'.tr(),style: AppStyle.txtSFProDisplayLight16, textAlign: TextAlign.center,)),
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
                    text: 'save'.tr().toUpperCase(),
                    variant: ButtonVariant.Cyan,
                    fontStyle: ButtonFontStyle.White16,
                    onTap: (){
                      cubit.save();
                    },
                  ),
                  SizedBox(height: 10,),

                  CustomButton(
                    text: 'cancel_result'.tr().toUpperCase(),
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
