import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';

import '../../../../core/models/day_event_model.dart';
import '../../../../theme/app_colors.dart';


class K37Screen extends StatelessWidget {
  final DayEventModel? dayEvent;
  final Function(DayEventModel dayEvent)? onSave;
  final fieldController = TextEditingController();

  K37Screen({Key? key, this.dayEvent, this.onSave}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DayEventModel? dayEventModel =
    dayEvent ?? (ModalRoute.of(context)?.settings.arguments ?? DayEventModel())
    as DayEventModel;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SizedBox(
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
                          'current_emotion'.tr(),
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
                          'what_did_I_do'.tr(),
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
                          'for_example_left_slammed_door'.tr(),
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: AppStyle.txtSFProDisplayLight14Gray800,
                        ),
                      ),
                      Padding(
                        padding:
                        getPadding(left: 0, top: 18, right: 0),
                        child: SizedBox(
                          height: 114,
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
                                hintText: 'your_actions'.tr(),

                                hintStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w300, fontSize: 14, color: ColorConstant.fromHex('#3B3B4A'),)
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
                  padding: getPadding(left: 16, top: 14, bottom: 10, right: 16),
                  child: Row(
                    // Was spaceEvenly (reserves equal gaps at both outer
                    // edges too) with a 171-wide back button — too narrow
                    // for the Spanish "EMOCIONES EN EL CUERPO" label even
                    // with textIsFitted scaling it down, so it visually
                    // crowded into the "SIGUIENTE" button next to it.
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomButton(
                        height: getVerticalSize(
                          32,
                        ),
                        width: getHorizontalSize(
                          195,
                        ),
                        variant: ButtonVariant.Base,

                        onTap: ()=>Navigator.pop(context),
                        text: 'emotions_in_body'.tr().toUpperCase(),
                        textIsFitted: true,
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
                          125,
                        ),
                        variant: ButtonVariant.Base,
                        text: 'continue'.tr().toUpperCase(),
                        onTap: () async {

                            onSave?.call(dayEventModel.copyWith(whatIDo: fieldController.text));
                            if(onSave == null)
                          Navigator.pushNamed(context, AppRoutes.first_thougths, arguments: dayEventModel.copyWith(whatIDo: fieldController.text));
                        },
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        onChanged: (BottomBarEnum type) {},
      ),
    );
  }
}
