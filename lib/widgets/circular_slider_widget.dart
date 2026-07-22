import 'package:flutter/material.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

import '../core/utils/color_constant.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../theme/app_decoration.dart';
import 'custom_image_view.dart';
import 'inner_shadow.dart';

class CircularSliderWidget extends StatelessWidget {
  double value;
  Function(double value)? onChange;

  CircularSliderWidget({Key? key, required this.value, this.onChange}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: SleekCircularSlider(
              onChange: (_value) {
                onChange!(_value);
              },
              appearance: CircularSliderAppearance(
                  animationEnabled: false,
                  infoProperties: InfoProperties(
                      topLabelText: '',
                      mainLabelStyle: TextStyle(color: Colors.transparent)),
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
              initialValue: value,
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
    );
  }
}
