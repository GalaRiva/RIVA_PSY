import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/utils/color_constant.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/working_out_irrational/widgets/count_bar.dart';

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
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 130, child: Text('Альтернативные мысли')),
                  CountBar(
                      currentCount: workingOutQuantity,
                      inTotalCount: notWorkingOutQuantity),
                  Text('($workingOutQuantity/$notWorkingOutQuantity)')
                ],
              ),
              SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 130, child: Text('Альтернативные действия')),
                  CountBar(
                      currentCount: workingOutQuantity,
                      inTotalCount: notWorkingOutQuantity),
                  Text('($workingOutQuantity/$notWorkingOutQuantity)')
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
