import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/db/firebase_firestore/data/repository.dart';
import 'package:riva_psy/core/user_data/user.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text_form_field.dart';

import '../../../core/models/tariff_model.dart';

class K4Screen extends StatelessWidget {
  TextEditingController group993Controller = TextEditingController();

  TextEditingController group995Controller = TextEditingController();

  @override Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                padding: getPadding(left: 11,
                    top: 27,
                    right: 11,
                    bottom: 27),
                decoration: AppDecoration.outlineWhiteA700
                    .copyWith(
                    borderRadius: BorderRadiusStyle
                        .roundedBorder3),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment
                        .start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(alignment: Alignment.centerLeft,
                              child: Text("Подписка",
                                  overflow: TextOverflow
                                      .ellipsis,
                                  textAlign: TextAlign.left,
                                  style: AppStyle.txtH1)),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.close, color: ColorConstant.gray800,))
                        ],
                      ),
                      Padding(padding: getPadding(
                          top: 10, right: 5),
                          child: Text(
                              "Помощь и поддержка могут потребоваться  в любой момент\n\nПолучайте полный доступ к рекомендациям, сессиям, аналитике, упражнениям весь год.\n\nЗаботьтесь о себе\n\nКачественная помощь днем и ночью",
                              maxLines: null,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtH2)),
                      CustomImageView(
                        imagePath: ImageConstant.imgOreon,
                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      CustomButton(
                          height: getVerticalSize(32),
                          width: getHorizontalSize(178),
                          text: "пробный период (14 дней)".toUpperCase(),
                          margin: getMargin(
                              top: 14, bottom: 6),
                          variant: ButtonVariant
                              .OutlineBluegray60014,
                          fontStyle: ButtonFontStyle
                          .SFProDisplayRegular12Cyan700,
                          onTap: () => onTapOne(context)),
                      CustomButton(
                          height: getVerticalSize(32),
                          width: getHorizontalSize(178),
                          text: "подписаться".toUpperCase(),
                          margin: getMargin(
                              top: 14, bottom: 6),
                          variant: ButtonVariant
                              .OutlineBluegray60014,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AppRoutes.buySubscription, arguments: [
                              if(!CurrentUser.usedOreonTrials)
                                TariffModel.ORION_TARIFF_14_DAYS,
                              TariffModel.ORION_TARIFF_MONTH,
                              TariffModel.ORION_TARIFF_YEAR
                            ]);

                          })
                    ])),
          ),
        ],
      ),
    );
  }

  onTapOne(BuildContext context) async{
    try {
      Navigator.pop(context);
      await FireStoreRepositoryImpl().useTrial(trialName: 'Oreon');
      await CurrentUser.repo.setLocalUserData(currentTariff: TariffModel.ORION_TARIFF_14_DAYS);
      FireStoreRepositoryImpl().updateUser(userId: CurrentUser.repo.userId(), currentTariff: TariffModel.ORION_TARIFF_14_DAYS);

      Navigator.pushNamed(context, AppRoutes.tariffActivated);

    } catch (_) {

    }
  }
}
