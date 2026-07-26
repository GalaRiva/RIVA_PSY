import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/bloc/bloc.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/desires/widgets/set_date_dialog.dart';
import 'package:riva_psy/presentation/records/calendar_add_screen/k51_screen.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../../../../core/utils/image_constant.dart';
import '../../../../../../theme/app_style.dart';

class DesireStageThirdPage extends StatelessWidget {

  const DesireStageThirdPage({Key? key,})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: Colors.white, width: 1)),
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'desires_stage'.tr(args: ['3']),
                  style: AppStyle.txtSFProDisplayLight16,
                ),
                Text(
                  DateFormat('dd.MM.yy').format(DateTime.now()),
                  style: AppStyle.txtSFProDisplayLight16,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 26,
                  height: 1,
                  color: Colors.white,
                ),
                Container(
                  width: 26,
                  height: 1,
                  color: Colors.white,
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'i_can_fulfill_this_desire'.tr().toUpperCase(),
              style: AppStyle.txtSFProDisplayLight12,
            ),
            SizedBox(
              height: 20,
            ),
            AspectRatio(
                aspectRatio: 300 / 316,
                child: Image.asset(
                  ImageConstant.desires3PNG,
                  fit: BoxFit.fill,
                )),
            SizedBox(
              height: 20,
            ),

            Text(
              'if_love_apples'.tr().toUpperCase(),
              style: AppStyle.txtSFProDisplayLight12,
            ),

            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'executed'.tr().toUpperCase(),
                    onTap: () {
                      context.read<DesiresBloc>().add(DesiresEvent.executeNewDesire());
                    },
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: CustomButton(
                    text: 'later'.tr().toUpperCase(),
                    onTap: () {
                    
                      showDialog(context: context, builder: (_) => SetDateDialog(
                        confirm: () {
                          context.read<DesiresBloc>().add(DesiresEvent.executeNewDesire());
                          Navigator.pop(context);

                        }, setDate: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) =>  K51Screen(title: 'schedule_desire'.tr(), widget: SvgPicture.asset(ImageConstant.desireHeartSVG), onTap: (_) {
                          Navigator.pop(context, _);
                        },))).then((value){
                          if(value != null) {
                            context.read<DesiresBloc>().add(DesiresEvent.executeNewDesire(dateTime: value));
                            Navigator.pop(context);
                          }
                        });
                      },
                      ));
                    },
                  ),
                )
              ],
            ),
            SizedBox(height: 10,),
            CustomButton(
              width: double.infinity,
              text: 'save_desire'.tr().toUpperCase(),
              onTap: () {
                context.read<DesiresBloc>().add(DesiresEvent.executeNewDesire());

              },
            )
          ],
        ),
      ),
    );
  }
}
