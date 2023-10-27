import 'package:flutter/material.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../core/models/day_event_model.dart';


class K37Screen extends StatelessWidget {
  final fieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel =
    (ModalRoute.of(context)?.settings.arguments ?? DayEventModel())
    as DayEventModel;
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.gray300,
        body: SizedBox(
          height: size.height,
          width: size.width,
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: getPadding(
                    left: 15,
                    right: 16,
                    bottom: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomImageView(
                        svgPath: ImageConstant.imgMusic,
                        height: getVerticalSize(
                          1,
                        ),
                        width: getHorizontalSize(
                          28,
                        ),
                        margin: getMargin(
                          left: 5,
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          top: 39,
                        ),
                        child: Text(
                          "Эмоция сейчас",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtSFProDisplayLight10Gray800,
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          top: 12,
                        ),
                        child: Divider(
                          height: getVerticalSize(
                            1,
                          ),
                          thickness: getVerticalSize(
                            1,
                          ),
                          color: ColorConstant.gray50,
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          left: 1,
                          top: 14,
                        ),
                        child: Text(
                          "Что я делал?",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtH1,
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          left: 5,
                          top: 30,
                        ),
                        child: Text(
                          "Например: Ушел, хлопнул дверью",
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtSFProDisplayLight14Gray800,
                        ),
                      ),
                      Padding(
                        padding:
                        getPadding(left: 0, top: 18, right: 0),
                        child: SizedBox(
                          height: 57,
                          width: MediaQuery.of(context).size.width - 32,
                          child: TextFormField(
                            controller: fieldController,
                            maxLines: 30,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: BorderSide.none
                                ),
                                fillColor: ColorConstant.grayLight,
                                filled: true,
                                hintText: 'Ваши действия',

                                hintStyle: TextStyle(fontFamily: 'SF Pro Display', fontWeight: FontWeight.w300, fontSize: 14, color: ColorConstant.fromHex('#3B3B4A'),)
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: getPadding(right: 16, bottom:10, left: 16 ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        height: getVerticalSize(
                          32,
                        ),
                        width: getHorizontalSize(
                          171,
                        ),
                        variant: ButtonVariant.Base,

                        onTap: ()=>Navigator.pop(context),
                        text: "Эмоции в теле".toUpperCase(),
                        padding: ButtonPadding.PaddingT8,
                        prefixWidget: CustomImageView(
                          margin: getMargin(right: 12),
                          svgPath: ImageConstant.leftArrow,
                        ),
                      ),
                      CustomButton(
                        height: getVerticalSize(
                          32,
                        ),
                        width: getHorizontalSize(
                          140,
                        ),
                        variant: ButtonVariant.Base,
                        text: "далее".toUpperCase(),
                        onTap: () async {
                          Navigator.pushNamed(context, AppRoutes.first_thougths, arguments: dayEventModel..whatIDo = fieldController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
        bottomNavigationBar: CustomBottomBar(
          onChanged: (BottomBarEnum type) {},
        ),
      ),
    );
  }
}
