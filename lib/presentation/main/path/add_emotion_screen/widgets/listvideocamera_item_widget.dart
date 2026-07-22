import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

// ignore: must_be_immutable
class ListvideocameraItemWidget extends StatelessWidget {
  ListvideocameraItemWidget();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CustomImageView(
            svgPath: ImageConstant.imgVideocamera,
            height: getVerticalSize(
              33,
            ),
            width: getHorizontalSize(
              73,
            ),
            radius: BorderRadius.circular(
              getHorizontalSize(
                3,
              ),
            ),
            margin: getMargin(
              right: 6,
            ),
          ),
        ),
        Expanded(
          child: CustomImageView(
            svgPath: ImageConstant.imgVideocamera,
            height: getVerticalSize(
              33,
            ),
            width: getHorizontalSize(
              73,
            ),
            radius: BorderRadius.circular(
              getHorizontalSize(
                3,
              ),
            ),
            margin: getMargin(
              left: 6,
              right: 6,
            ),
          ),
        ),
        Expanded(
          child: CustomImageView(
            svgPath: ImageConstant.imgVideocamera,
            height: getVerticalSize(
              33,
            ),
            width: getHorizontalSize(
              73,
            ),
            radius: BorderRadius.circular(
              getHorizontalSize(
                3,
              ),
            ),
            margin: getMargin(
              left: 6,
              right: 6,
            ),
          ),
        ),
        Expanded(
          child: CustomImageView(
            svgPath: ImageConstant.imgVideocamera,
            height: getVerticalSize(
              33,
            ),
            width: getHorizontalSize(
              73,
            ),
            radius: BorderRadius.circular(
              getHorizontalSize(
                3,
              ),
            ),
            margin: getMargin(
              left: 6,
            ),
          ),
        ),
      ],
    );
  }
}
