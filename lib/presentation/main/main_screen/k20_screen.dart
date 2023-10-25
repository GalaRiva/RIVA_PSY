import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';
import 'package:listenmebaby71_s_application17/core/utils/date_extension.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_bottom_bar.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import '../../../core/models/emotional_state_model.dart';
import '../../../core/user_data/user.dart';
import 'dart:ui';
import '../../../core/models/day_event_model.dart';

import '../../../widgets/custom_message_box.dart';
import '../../../widgets/inner_shadow.dart';
import 'controller.dart';
import 'repository.dart';
import 'widgets/try_irrational_dialog.dart';

class K20Screen extends GetWidget<K20Controller> {
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    final _repo = K20Repo();
    int value = 5;
    final controller = Get.put(K20Controller());
    Timer(Duration(seconds: 2), () async{
      await controller.openMessages(context);
    });
    return SafeArea(
      child: Scaffold(
        backgroundColor: ColorConstant.gray300,
        body: SizedBox(
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
                      child: Text(
                        "Привет, " + CurrentUser.user.login!,
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
                      child: Text(
                        "как ты себя чувствуешь?",
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
                      child: Text(
                        "Нормально",
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
                            InnerShadow(
                              blur: 5,
                              color: const Color(0xFF2A456F).withOpacity(0.08),
                              offset: const Offset(5, 5),
                              child: Container(
                                width: getSize(95),
                                height: getSize(95),

                                decoration: BoxDecoration(

                                    color: ColorConstant.fromHex('#D7E1E1'),
                                    borderRadius: BorderRadius.circular(getHorizontalSize(
                                      60,
                                    ),)
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
                          child: Text(
                            "Ужасно",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight16,
                          ),
                        ),
                        Padding(
                          padding: getPadding(
                            top: 1,
                          ),
                          child: Text(
                            "Прекрасно",
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtSFProDisplayLight16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CustomButton(
                    height: getVerticalSize(
                      32,
                    ),
                    onTap: ()
                    async {
                      await _repo.updateEvent(EmotionalStateModel(value, DateTime.now()));
                      showDialog(
                        context: context, builder: (BuildContext context) =>
                          CustomMessageBox(
                            title: 'Создана запись',
                            content:
                            'Запись ${DateTime
                                .now()
                                .day} ${DateTime
                                .now()
                                .month
                                .monthInText()} ${DateTime
                                .now()
                                .year} г ${DateTime
                                .now()
                                .hour
                                .timeFormatted()}:${DateTime
                                .now()
                                .minute
                                .timeFormatted()} сохранена',
                          ),);
                    },
                    text: "Сохранить".toUpperCase(),
                    margin: getMargin(
                      left: 74,
                      top: 38,
                      right: 74,
                    ),
                    variant: ButtonVariant.OutlineBluegray60014,
                  ),
                  CustomButton(
                    height: getVerticalSize(
                      32,
                    ),
                      onTap: (){
                      Navigator.pushNamed(context, AppRoutes.whatHappened, arguments: DayEventModel()..howDoYouFeel = value);
                      },
                    text: "Пройти путь".toUpperCase(),
                    margin: getMargin(
                      left: 68,
                      top: 47,
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
        bottomNavigationBar: CustomBottomBar(
          onChanged: (BottomBarEnum type) {},
        ),
      ),
    );
  }
}
