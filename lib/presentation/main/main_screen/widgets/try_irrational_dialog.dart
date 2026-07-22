import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_button.dart';

class TryIrrationalDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
         Center(
           child: Card(
              color: Colors.transparent,
              elevation: 0,
              child: Container(
                width: size.width - 30,
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(3)),
                child: Container(
                    margin: EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        color: ColorConstant.gray200,
                        borderRadius: BorderRadius.circular(3)),
                    child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.topRight,
                              child: InkWell(
                                onTap: () => Navigator.pop(context),
                                child: Icon(
                                  Icons.close,
                                  size: 9,
                                  color: ColorConstant.grayLight,
                                ),
                              ),
                            ),
                            Text(
                              'Проработать иррациональное'.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight16,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              child: Text(
                                'путь к здоровой жизни и отношениям)',
                                textAlign: TextAlign.center,
                                style: AppStyle.txtSFProDisplayLight16,
                              ),
                            ),
                            Text(
                              'Проработать иррациональные мысли, изменить дисфункциональное на функциональное)',
                              textAlign: TextAlign.center,
                              style: AppStyle.txtSFProDisplayLight12,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 35, horizontal: 15),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AspectRatio(
                                      aspectRatio: 260 / 200,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: ColorConstant.darkWhite,
                                            borderRadius:
                                                BorderRadius.circular(3)),
                                        child: Container(
                                            margin: EdgeInsets.all(30),
                                            decoration: BoxDecoration(
                                                color: ColorConstant.blueGreen,
                                                borderRadius:
                                                    BorderRadius.circular(3))),
                                      )),
                                  Image.asset(ImageConstant.workingOutImg),
                                  Positioned(
                                      right: 30,
                                      top: -5,
                                      child: Image.asset(ImageConstant.bubbleImg))
                                ],
                              ),
                            ),
                            CustomButton(
                              text: 'Хочу попробовать'.toUpperCase(),
                              fontStyle: ButtonFontStyle.DeepPurple16,
                              onTap: () {
                                AppRoutes.currentRoute = AppRoutes.recommendations;
                                Navigator.pop(context);
                                Navigator.pushNamed(
                                    context,
                                    AppRoutes.recommendations,
                                    arguments: {'initialTab': 1}
                                );

                              }
                            )
                          ],
                        )))),
        ),
         ),
        Image.asset(
          ImageConstant.lineImg,
          fit: BoxFit.fitWidth,
        )
      ],
    );
  }
}
