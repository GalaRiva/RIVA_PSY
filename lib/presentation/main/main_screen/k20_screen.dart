import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart' hide Trans;
import 'package:get/get_core/src/get_main.dart';
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/utils/date_extension.dart';
import 'package:riva_psy/presentation/initial_setup/pill_reminders/pill_reminders_screen.dart';
import 'package:riva_psy/presentation/main/path/first_thougths_screen/repository.dart';
import 'package:riva_psy/widgets/custom_bottom_bar.dart';
import 'package:riva_psy/widgets/custom_button.dart';
import 'package:riva_psy/widgets/custom_text.dart';
import 'package:provider/provider.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../core/models/emotional_state_model.dart';
import '../../../core/user_data/user.dart';
import 'dart:ui';
import '../../../core/models/day_event_model.dart';

import '../../../providers/language_provider.dart';
import '../../../widgets/custom_message_box.dart';
import '../../../widgets/inner_shadow.dart';
import 'controller.dart';
import 'repository.dart';
import 'widgets/try_irrational_dialog.dart';
import '../../../theme/app_colors.dart';

class K20Screen extends GetWidget<K20Controller> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    final _repo = K20Repo();
    int value = 10;
    final controller = Get.put(K20Controller());
    Timer(Duration(seconds: 2), () async{
      await controller.openMessages(context);
    });
    return Builder(
      builder: (context) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SizedBox(
              width: size.width,
              child: SingleChildScrollView(
                child: Padding(
                  padding: getPadding(
                    left: 16,
                    right: 16,
                    bottom: 5,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: getPadding(
                            top: 39,
                          ),
                          child: Text(
                            DateTime.now().weekday.dayInText() +
                                ", " +
                                DateTime.now().day.toString() +
                                " " +
                                DateTime.now().month.monthInText(),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight10Gray800,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: getPadding(
                            top: 20,
                          ),
                          child: CustomText(
                            "hi",
                            args: ["${CurrentUser.user.login!.isNotEmpty ? '' :''} ${CurrentUser.user.login!}"],
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtH1,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: getPadding(
                            top: 11,
                          ),
                          child: CustomText(
                            "how_do_you_feel",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayThin16,
                          ),
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          top: 34,
                        ),
                        child: Center(
                          child: CustomText(
                            "normal",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight16,
                          ),
                        ),
                      ),
                      Center(
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          elevation: 0,
                          margin: getMargin(
                            top: 12,
                          ),
                          color: ColorConstant.gray2007c,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              getHorizontalSize(
                                101,
                              ),
                            ),
                          ),
                          child: Container(
                            height: getSize(
                              202,
                            ),
                            width: getSize(
                              202,
                            ),
                            padding: getPadding(
                              left: 17,
                              top: 19,
                              right: 17,
                              bottom: 19,
                            ),
                            decoration: AppDecoration.fillGray2007c.copyWith(
                              borderRadius: BorderRadiusStyle.circleBorder101,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    margin: getMargin(
                                      left: 3,
                                      right: 3,
                                    ),
                                    padding: getPadding(
                                      left: 22,
                                      right: 22,
                                    ),
                                    decoration: BoxDecoration(),
                                  ),
                                ),
                                SizedBox(
                                  height: getSize(160),
                                  width: getSize(160),
                                  child: GetBuilder(
                                    builder: (K20Controller _c) => SleekCircularSlider(
                                      onChangeEnd: (_value) {
                                        value = _value.toInt();
                                        controller.update();
                                      },
                                      appearance: CircularSliderAppearance(
                                        animationEnabled: true,
                                        infoProperties: InfoProperties(
                                          topLabelText: '',
                                          mainLabelStyle: TextStyle(color: Colors.transparent)
                                        ),
                                          startAngle: 105,
                                          angleRange: 330,
                                          size: 220,
                                          customColors: CustomSliderColors(
                                            trackColor: Colors.white,
                                            dotColor: ColorConstant.fromHex("#768295"),
                                            progressBarColors: [
                                              ColorConstant.fromHex('#403875'),
                                              ColorConstant.fromHex('#7FBDBA'),
                                            ],
                                          ),
                                          customWidths: CustomSliderWidths(
                                              handlerBorderWidth: 9,
                                              progressBarWidth: 15,
                                              handlerSize: 12,
                                              trackWidth: 15)),
                                      min: 0,
                                      max: 10,
                                      initialValue: value.toDouble(),
                                    ),
                                  ),
                                ),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: getSize(95),
                                    height: getSize(95),

                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: const Color(0xFF2A456F).withOpacity(0.6), blurRadius: 1, spreadRadius: 0),
                                          BoxShadow(color:ColorConstant.fromHex('#D7E1E1'), blurRadius: 10, spreadRadius: 5),
                                        ],
                                    ),
                                  ),
                                ),
                                IgnorePointer(
                                  child: Container(

                                    child: CustomImageView(
                                      svgPath: ImageConstant.imgFrame185,
                                      fit: BoxFit.fill,
                                      height: getSize(
                                        155,
                                      ),
                                      width: getSize(
                                        155,
                                      ),
                                      alignment: Alignment.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: getPadding(
                          top: 34,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Padding(
                              padding: getPadding(
                                bottom: 1,
                              ),
                              child: CustomText(
                                "terribly",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight16,
                              ),
                            ),
                            Padding(
                              padding: getPadding(
                                top: 1,
                              ),
                              child: CustomText(
                                "fine",
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: AppStyle.txtSFProDisplayLight16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CustomButton(
                        onTap: ()
                        async {
                          await _repo.updateEvent(EmotionalStateModel(value, DateTime.now()));
                          showDialog(
                            context: context, builder: (BuildContext context) =>
                              CustomMessageBox(
                                title: 'create_record'.tr(),
                                content: 'save_record'.tr(args: [
                                  '${DateTime.now().day} ${DateTime.now().month.monthInText()} ${DateTime.now().year} ${DateTime.now().hour.timeFormatted()}:${DateTime.now().minute.timeFormatted()}'
                                ]),
                              ),);
                        },
                        text: 'save'.tr().toUpperCase(),
                        margin: getMargin(
                          left: 74,
                          top: 38,
                          right: 74,
                        ),
                        variant: ButtonVariant.OutlineBluegray60014,
                      ),
                      CustomButton(

                          onTap: (){
                          Navigator.pushNamed(context, AppRoutes.whatHappened, arguments: DayEventModel().copyWith(howDoYouFeel: value, showInCharts: true));
                          },
                        text: 'complete_path'.tr().toUpperCase(),
                        margin: getMargin(
                          left: 68,
                          top: 27,
                          right: 68,
                        ),
                        variant: ButtonVariant.OutlineBluegray60014,
                        fontStyle: ButtonFontStyle.SFProDisplayRegular12Cyan700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: CustomBottomBar(
            onChanged: (BottomBarEnum type) {},
          ),
        );
      }
    );
  }
}
