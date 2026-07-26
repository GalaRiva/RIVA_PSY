import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../theme/app_style.dart';
import '../../../../../../widgets/custom_button.dart';

class SetDateDialog extends StatelessWidget {
  final Function()? confirm;
  final Function()? setDate;

  const SetDateDialog({Key? key, this.confirm, this.setDate}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Material(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(3),
              color: ColorConstant.darkBg,
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(alignment: Alignment.topRight, child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, color: ColorConstant.blueGray400, size: 20,)),),
                SizedBox(height: 10,),
                Text('desires'.tr().toUpperCase(), style: AppStyle.txtSFProDisplayLight16,),
                SizedBox(height: 10,),
                 Text('if_desire_concerns'.tr(), style: AppStyle.txtSFProDisplayLight12,),
                SizedBox(height: 10,),

                  AspectRatio(aspectRatio: 1/1, child: Image.asset(ImageConstant.desireCreateCompletePNG, fit: BoxFit.fill,),),
                SizedBox(height: 20,),
                CustomButton(text: 'done'.tr().toUpperCase(), onTap: confirm,),
                SizedBox(width: 10,),
                CustomButton(text: 'schedule_later'.tr().toUpperCase(), onTap: setDate,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
