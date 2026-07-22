import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:listenmebaby71_s_application17/core/app_export.dart';

// ignore: must_be_immutable
class ListglobeItemWidget extends StatelessWidget {
  final String? svgPath;
  final File? svgFile;
  final String? svgUrl;
  final String title;
  final Map? params;
  ListglobeItemWidget( this.title, {this.params, this.svgPath, this.svgFile, this.svgUrl});

  @override
  Widget build(BuildContext context) {
    return
      Container(
        height: getVerticalSize(118),
        width: size.width - 20,
        padding: getPadding(
          left: 17,
          top: 23,
          right: 17,
          bottom: 23,
        ),
        decoration: AppDecoration.outlineBluegray600143.copyWith(
          color: ColorConstant.grayLight,

          borderRadius: BorderRadiusStyle.roundedBorder3,
        ),
        child: InkWell(
          onTap: (){
            Navigator.pushNamed(context, AppRoutes.recommendations, arguments: params);

          },

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: getVerticalSize(
                71,
              ),
              width: getHorizontalSize(
                51,
              ),
              child: svgPath != null ? CustomImageView(
                svgPath: svgPath,
                height: getVerticalSize(
                  71,
                ),
                width: getHorizontalSize(
                  51,
                ),
              ) : svgFile != null ? SvgPicture.file(
                svgFile!,
                height: getVerticalSize(100),
                width: getHorizontalSize(60),
                fit: BoxFit.contain,
              ) : svgUrl != null ? SvgPicture.network(
                svgUrl!,
                height: getVerticalSize(100),
                placeholderBuilder: (context) {
                  return Center(child: CircularProgressIndicator(color: ColorConstant.cyan700,));
                },
                width: getHorizontalSize(60),
                fit: BoxFit.contain,
              ) : Container(),
            ),
            Padding(
              padding: getPadding(
                left: 23,
                top: 27,
                bottom: 27,
              ),
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: AppStyle.txtSFProDisplayLight14Cyan700,
              ),
            ),
            Spacer(),
            CustomImageView(
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
                top: 32,
                right: 1,
                bottom: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
