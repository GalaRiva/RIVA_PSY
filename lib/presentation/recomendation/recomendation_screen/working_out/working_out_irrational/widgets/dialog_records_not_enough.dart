import 'package:flutter/material.dart';

import '../../../../../../core/models/day_event_model.dart';
import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/image_constant.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../theme/app_style.dart';
import '../../../../../../widgets/custom_button.dart';

class DialogRecordsNotEnough extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Container(
          padding: EdgeInsets.all(15),
          decoration:
          BoxDecoration(border: Border.all(color: Colors.white, width: 1), color: ColorConstant.gray200),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                  aspectRatio: 300 / 200,
                  child: Container(
                    color: ColorConstant.gray300,
                    child:
                    Image.asset(ImageConstant.handImg,),
                  )),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Text(
                  'Проходи Путь, добавляй мысли, эмоции и пересоздавай неприятное в позитивное',
                  style: AppStyle.txtSFProDisplayLight16,
                  overflow: TextOverflow.visible,
                ),
              ),
              CustomButton(
                text: 'НАЧАТЬ',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.whatHappened, arguments: DayEventModel()..howDoYouFeel = 5);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
