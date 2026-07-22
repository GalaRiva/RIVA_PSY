import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/desire/desire.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_message_box.dart';

import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';

class DesireDialog extends StatelessWidget {
  final Function()? onTap;
  final Desire desire;

  const DesireDialog({Key? key, this.onTap, required this.desire}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomMessageBox(
          bgColor: ColorConstant.darkBg,
            width: size.width - 20,
            height: 600,
            title: DateFormat('dd.MM.yy').format(desire.createdAt), content: Padding(

          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, left: 5, bottom: 20),
                child: AspectRatio(aspectRatio: 295/227,
                child: Image.asset(ImageConstant.desireItemPNG, fit: BoxFit.fill,),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text(desire.simpleDesires, style: AppStyle.txtSFProDisplayLight14.copyWith(fontSize: 15, overflow: TextOverflow.ellipsis), maxLines: 10,)),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text(desire.desireDetails, style: AppStyle.txtSFProDisplayLight14.copyWith(fontSize: 15, overflow: TextOverflow.ellipsis), maxLines: 10)),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              CustomButton(width: 244,
              height: 50,
              onTap: onTap,
              prefixWidget: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: ColorConstant.cyan700, width: 1)
                  ),
                ),
              ),
              centralWidget: () {
                if (desire.completed) {
                  return Text('Исполнил ${DateFormat('dd.MM.yyyy').format(
                      desire.dateOfExecution)}'.toUpperCase(),
                    style: AppStyle.txtSFProDisplayLight16Cyan700,);
                } else if (DateTime.now().isBefore(desire.dateOfExecution)) {
                  return Row(children: [
                      Text('исполню '.toUpperCase(),
                style: AppStyle.txtSFProDisplayLight16DeepPurple,),
                    Text('${DateFormat('dd.MM.yyyy').format(
                        desire.dateOfExecution)}'.toUpperCase(),
                      style: AppStyle.txtSFProDisplayLight16Cyan700,)
                  ],);
                }
                return Text('Желание пропало'.toUpperCase(),
                  style: AppStyle.txtSFProDisplayLight16DeepPurple,);
              }())
    ],
          ),
        ))
      ),
    );  }
}
