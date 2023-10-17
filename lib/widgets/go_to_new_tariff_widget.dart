import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

import '../core/models/tariff_model.dart';
import 'custom_button.dart';

class GoToNewTariffWidget extends StatelessWidget {
  final VoidCallback? onSecondButtonTap;
  final double? height;
  const GoToNewTariffWidget({Key? key, this.height, this.onSecondButtonTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? size.height - (240 + 53),
      width: size.width,
decoration: BoxDecoration(
  gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
    ColorConstant.fromHex('#E7EAEA').withOpacity(0.5),
    ColorConstant.fromHex('#E7EAEA'),
    ColorConstant.fromHex('#E7EAEA'),
  ])

),      child: Container(
  margin: getMargin(bottom: 40),
  child: Column(
mainAxisAlignment: MainAxisAlignment.end,          children: [
            SizedBox(
              width: getHorizontalSize(
                288,
              ),
              child: Text(
                'Для полного доступа к рекомендациям, статистике и аудио переходите на тариф Стандарт',
                textAlign: TextAlign.center,
                style: AppStyle.txtSFProDisplayLight10Gray800,
              ),
            ),
            SizedBox(height: 4,),
            CustomButton(
              height: getVerticalSize(
                54,
              ),
              width: getHorizontalSize(
                288,
              ),
              text: "Перейти на тариф стандарт".toUpperCase(),
              onTap: () async {
                Navigator.pushNamed(context, AppRoutes.buySubscription,
                    arguments: TariffModel.ORION_TARIFF);
              },
              fontStyle: ButtonFontStyle.SFProDisplayRegular12Cyan700,
              alignment: Alignment.center,
            ),
            CustomButton(
              height: getVerticalSize(
                54,
              ),
              width: getHorizontalSize(
                288,
              ),
              margin: getMargin(top: 40),
              suffixWidget: Padding(
                padding: getPadding(left: 10),
                child: Icon(Icons.arrow_forward_ios_sharp, size: getSize(10), color: ColorConstant.deepPurple600,),
              ),
              text: "к  бесплатным рекомендациям".toUpperCase(),
              onTap: () async {
                if (onSecondButtonTap == null) {
                  Navigator.pushNamed(context, AppRoutes.recommendations);
                  AppRoutes.currentRoute = AppRoutes.recommendations;
                } else onSecondButtonTap!();
              },
              alignment: Alignment.center,
            ),
            SizedBox(height: 40,)
          ],
        ),
),
    );
  }
}
