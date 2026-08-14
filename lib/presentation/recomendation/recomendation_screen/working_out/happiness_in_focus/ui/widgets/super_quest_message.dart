import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riva_psy/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/ui/super_quest_page.dart';

import '../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../core/utils/image_constant.dart';
import '../../../../../../../theme/app_style.dart';
import '../../../../../../../widgets/custom_button.dart';

class SuperQuestMessage extends StatelessWidget {
  final int positiveRecords;

  const SuperQuestMessage({Key? key, required this.positiveRecords});

  @override
  Widget build(BuildContext context) {
    final remainedParts = 'remained_fill'.tr().split('{}');
    if (positiveRecords < 0)
      return Material(
        child: Container(
          width: 270,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: ColorConstant.gray200,
              border: Border.all(color: Colors.white, width: 1)),
          child: Column(
            mainAxisSize: MainAxisSize.min,

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
              Text(
                'do_x_records'.tr(args: ['100']).toUpperCase(),
                style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.black900),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 26,
              ),
              SelectableText.rich(
                TextSpan(children: [
                  TextSpan(text: remainedParts[0]),
                  TextSpan(
                      text: '${100 - positiveRecords}',
                      style: AppStyle.txtSFProDisplayLight16Gray
                          .copyWith(color: ColorConstant.cyan700)),
                  TextSpan(text: remainedParts.length > 1 ? remainedParts[1] : ''),
                ], style: AppStyle.txtSFProDisplayLight16Gray.copyWith(color: ColorConstant.black900)),
              )
            ],
          ),
        ),
      );
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Material(
        child: Container(
          // Was a fixed 270 — hard-capped the image inside a narrow dialog
          // regardless of device size. Now scales with the screen (minus
          // the 15px outer Padding on each side) like the rest of this
          // feature's full-width pages already do.
          width: MediaQuery.of(context).size.width - 30,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: ColorConstant.gray200,
              border: Border.all(color: Colors.white, width: 1)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              Text(
                'get_started'.tr().toUpperCase(),
                style: AppStyle.txtSFProDisplayLight16Gray
                    .copyWith(color: ColorConstant.gray80038),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 15,
              ),
              // Was a 35px-padded Container nested inside an outer
              // AspectRatio(300/260), shrinking the actual image well
              // below the dialog's own width. One AspectRatio matching the
              // asset's real proportions, no padding, fills the space.
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: AspectRatio(
                  aspectRatio: 230/190,
                  child: Image.asset(ImageConstant.happinessInFocusMessage, fit: BoxFit.cover,),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              CustomButton(
                text: 'understand'.tr().toUpperCase(),
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: (){
                  Navigator.pop(context);
                },
              ),
              SizedBox(
                height: 15,
              ),
              CustomButton(
                text: 'super_quest'.tr().toUpperCase(),
                variant: ButtonVariant.Cyan,
                fontStyle: ButtonFontStyle.White16,
                onTap: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                  showDialog(context: context, builder: (_) => SuperQuestPage());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
