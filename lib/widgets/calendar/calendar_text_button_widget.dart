import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// ignore: must_be_immutable
class CalendarTextButtonWidget extends StatelessWidget {
  final VoidCallback? onPlus;
  final VoidCallback? onMinus;
  String text;
  int fontSize;
  CalendarTextButtonWidget(this.text, this.onPlus, this.onMinus, this.fontSize);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
      width: getHorizontalSize(
      20,
    ),
          child: IconButton(
            icon: CustomImageView(
              svgPath: ImageConstant.imgVector41,
              height: getVerticalSize(
                8,
              ),
              width: getHorizontalSize(
                4,
              ),
              radius: BorderRadius.circular(
                getHorizontalSize(
                  1,
                ),
              ),
              margin: getMargin(
                top: 8,
                bottom: 7,
              ),
            ), onPressed:onPlus,
          ),
        ),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
          style: AppStyle.txtSFProDisplayLight20.copyWith(
            fontSize: fontSize.toDouble(),
            letterSpacing: getHorizontalSize(
              0.8,
            ),
          ),
        ),
        SizedBox(
          width: getHorizontalSize(
            20,
          ),
          child: IconButton(
            onPressed: onMinus,

            icon: CustomImageView(
              svgPath: ImageConstant.imgVector46,
              height: getVerticalSize(
                8,
              ),
              width: getHorizontalSize(
                4,
              ),
              radius: BorderRadius.circular(
                getHorizontalSize(
                  1,
                ),
              ),
              margin: getMargin(
                top: 8,
                bottom: 7,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
