import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/theme/app_style.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../theme/app_icons.dart';

class WishesDetailDialog extends StatelessWidget {
  final int index;
  final Function()? onStart;
  final Function()? onNext;
   WishesDetailDialog({required this.index, this.onStart, this.onNext});

  final subtitles = ['','','','','recommendation_for_efficiency'];
  List<Widget> content (BuildContext context) => <Widget>[Text('get_start_with_simple_things'.tr(),style: AppStyle.txtSFProDisplayLight12Gray800,), Text('what_concrete'.tr(), style: AppStyle.txtSFProDisplayLight12Gray800,),Text('tastes_and_preferences'.tr(),style: AppStyle.txtSFProDisplayLight12Gray800,),Text('if_difficult'.tr(),style: AppStyle.txtSFProDisplayLight12Gray800,),Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
  Text('set_timer'.tr(),style: AppStyle.txtSFProDisplayLight12Gray800,),
    SizedBox(height: 10,),
    Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Container(width: 148, color: ColorConstant.cyan700, height: 1,),
    ),
    SizedBox(height: 10,),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('or'.tr(),         style: AppStyle.txtSFProDisplayLight12Gray800),
        GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.reminders);
            },
            child: Text( 'reminders_in_app'.tr(),         style: AppStyle.txtSFProDisplayLight12Cyan700,)),
      ],
    ),

    Text.rich(TextSpan(
        style: AppStyle.txtSFProDisplayLight12Gray800,
        children: [
      TextSpan(text: 'in_order_to_pay_attention'.tr()),

    ]))
  ],)];

  final images = List.generate(5, (index) => 'assets/images/desires/desires_detail_${index + 1}.png');
  final ratios = [1/1, 3/2, 1/1, 1/1, 290/180];
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
                    child: Icon(AppIcons.x, color: ColorConstant.blueGray400, size: 20,)),),
                SizedBox(height: 10,),
                Text('desires'.tr().toUpperCase(), style: AppStyle.txtSFProDisplayLight16,),
                SizedBox(height: 10,),
                if(subtitles[index].isNotEmpty)
                  Padding(padding: EdgeInsets.only(bottom: 10), child: Text(
                      subtitles[index].tr(), style: AppStyle.txtSFProDisplayLight12Gray800,
                  ),),
                _buildImage(images[index], ratios[index]),
                SizedBox(height: 20,),

                content(context)[index],
                SizedBox(height: 20,),

                Row(children: [
                  Expanded(child: CustomButton(text: 'start'.tr().toUpperCase(), onTap: onStart,)),
                  SizedBox(width: 10,),
                  Expanded(child: CustomButton(text: 'continue'.tr().toUpperCase(), onTap: onNext,)),

                ],)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage (String asset, double ratio) {
    return AspectRatio(aspectRatio: ratio,
    child: Image.asset(asset, fit: BoxFit.fill,),
    );
  }
}
