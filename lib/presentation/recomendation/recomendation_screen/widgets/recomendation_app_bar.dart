import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../core/utils/size_utils.dart';

class RecomendationAppBar extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: getVerticalSize(94),
      child: Column(
        children: [
          CustomButton(text: 'Помощь при панике и аффекте', width: size.width - 32, height: getVerticalSize(37),),
          Padding(padding: EdgeInsets.only(top: 11),
            child: TabBar(tabs: [
              tab('Справится с эмоцией')
            ],),
          )
        ],
      ),
    );
  }

  Widget tab (String text) {
    return Container(
        height: 46,
        decoration: BoxDecoration(
            color: ColorConstant.gray300,
            border: Border(top: BorderSide(width: 1, color: ColorConstant.cyan700), right: BorderSide(width: 1, color: ColorConstant.cyan700), left: BorderSide(width: 1, color: ColorConstant.cyan700))
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: Tab(text: text,)),
        ));
  }
}
