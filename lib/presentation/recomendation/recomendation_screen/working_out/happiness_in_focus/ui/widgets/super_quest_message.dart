import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:listenmebaby71_s_application17/presentation/recomendation/recomendation_screen/working_out/happiness_in_focus/super_quest/ui/super_quest_page.dart';

import '../../../../../../../core/utils/color_constant.dart';
import '../../../../../../../core/utils/image_constant.dart';
import '../../../../../../../theme/app_style.dart';
import '../../../../../../../widgets/custom_button.dart';

class SuperQuestMessage extends StatelessWidget {
  final int positiveRecords;

  const SuperQuestMessage({Key? key, required this.positiveRecords});

  @override
  Widget build(BuildContext context) {
    if (positiveRecords < 100)
      return Container(
        width: 270,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: ColorConstant.gray200,
            border: Border.all(color: Colors.white, width: 1)),
        child: Column(
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
              'Сделай 100 осознанных записей, и тебе откроется супер задание'
                  .toUpperCase(),
              style: AppStyle.txtSFProDisplayLight16
                  .copyWith(color: ColorConstant.gray80038),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 26,
            ),
            SelectableText.rich(
              TextSpan(children: [
                TextSpan(text: 'Осталось внести'),
                TextSpan(
                    text: '${100 - positiveRecords}',
                    style: AppStyle.txtSFProDisplayLight16
                        .copyWith(color: ColorConstant.cyan700)),
                TextSpan(text: 'записей'),
              ], style: AppStyle.txtSFProDisplayLight16),
            )
          ],
        ),
      );
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Container(
        width: 270,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: ColorConstant.gray200,
            border: Border.all(color: Colors.white, width: 1)),
        child: Column(
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
              'Приступай только когда готов к нему...'.toUpperCase(),
              style: AppStyle.txtSFProDisplayLight16
                  .copyWith(color: ColorConstant.gray80038),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 15,
            ),
            AspectRatio(aspectRatio:300/260,child: Container(
              color: ColorConstant.darkWhite,
              padding: EdgeInsets.all(35),

              child: AspectRatio(
                aspectRatio: 230/190,
                child: Image.asset(ImageConstant.happinessInFocusMessage, fit: BoxFit.cover,),
              ),
            ),),
            SizedBox(
              height: 15,
            ),
            CustomButton(
              text: 'Понятно'.toUpperCase(),
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
              text: 'Супер задание'.toUpperCase(),
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
    );
  }
}
