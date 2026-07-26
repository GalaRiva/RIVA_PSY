import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
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
            Text('desires'.tr().toUpperCase(), style: AppStyle.txtSFProDisplayLight16,),
            SizedBox(height: 20,),
            Text('its_not_about_great_dreams'.tr().toUpperCase(), style: AppStyle.txtSFProDisplayLight12,),

            SizedBox(height: 20,),
            Row(children: [
              Expanded(
                child: CustomButton(
                  text: 'start'.tr().toUpperCase(),
                  onTap: () {
                    context.read<DesiresBloc>().add(DesiresEvent.start());
                  },
                ),
              ),
              SizedBox(width: 10,),
              Expanded(
                child: CustomButton(
                  text: 'more_detailed'.tr().toUpperCase(),
                  onTap: () {
                    context.read<DesiresBloc>().add(DesiresEvent.getDetails(context));
                  },
                ),
              )
            ],),
            SizedBox(height: 10,),
            CustomButton(
              width: size.width / 2 - 20,
              text: 'report'.tr().toUpperCase(),
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
