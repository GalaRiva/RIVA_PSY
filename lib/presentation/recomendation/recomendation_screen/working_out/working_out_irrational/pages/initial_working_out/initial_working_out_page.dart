import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../bloc/cubit.dart';
import '../../bloc/state.dart';
import '../working_out_widget.dart';

class InitialWorkingOutPage extends WorkingOutWidget {

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WorkingOutIrrationalCubit>();
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
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
                      'work_out_irrational'.tr().toUpperCase(),
                      style: AppStyle.txtSFProDisplayLight16,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      'please_remember'.tr(),
                      style: AppStyle.txtSFProDisplayLight12,
                    ),
                  ),
                  Text(
                    'recommended_to_take_per_day'.tr(),
                    style: AppStyle.txtSFProDisplayLight12,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 10),
                    child: CustomButton(
                      text: 'alternative'.tr().toUpperCase(),
                      onTap: () {
                        cubit.goToNextState(WorkingOutIrrationalStage.alternative);
                      },
                    ),
                  ),
                  CustomButton(
                    text: 'start'.tr().toUpperCase(),
                    onTap: () {
                      cubit.goToNextState(WorkingOutIrrationalStage.challengeThought);
                    },
                  ),

                ],
              ),
            ),
          ),
          SizedBox(height: 50,)
        ],
      ),
    );
  }

  @override
  WorkingOutIrrationalStage stage() => WorkingOutIrrationalStage.initialStage;
}
