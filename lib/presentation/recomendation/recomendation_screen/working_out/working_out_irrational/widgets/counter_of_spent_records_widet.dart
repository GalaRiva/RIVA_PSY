import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/utils/color_constant.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/count_bar.dart';
import 'package:riva_psy/theme/app_style.dart';

import '../../../../../../core/utils/size_utils.dart';

class CounterOfSpentRecordsWidget extends StatelessWidget {
  final int workingOutQuantity;
  final int notWorkingOutQuantity;

  const CounterOfSpentRecordsWidget(
      {Key? key,
      required this.workingOutQuantity,
      required this.notWorkingOutQuantity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width - 32,
      color: Colors.white,
      child: Container(
        margin: EdgeInsets.all(1),
        color: ColorConstant.gray300,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 130, child: Text('Альтернативные мысли', style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.grayTextColor, fontSize: 16),)),
                  CountBar(
                      currentCount: workingOutQuantity,
                      inTotalCount: notWorkingOutQuantity),
                  Text('($workingOutQuantity/$notWorkingOutQuantity)',style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.grayTextColor, fontSize: 16),)
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 130, child: Text('Альтернативные действия',style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.grayTextColor, fontSize: 16),)),
                  CountBar(
                      currentCount: workingOutQuantity,
                      inTotalCount: notWorkingOutQuantity),
                  Text('($workingOutQuantity/$notWorkingOutQuantity)',style: AppStyle.txtSFProDisplayLight16.copyWith(color: ColorConstant.grayTextColor, fontSize: 16),)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
