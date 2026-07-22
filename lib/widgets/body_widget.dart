import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

import '../core/models/body_parts_model.dart';
import '../core/user_data/user.dart';
import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import 'circular_container_widget.dart';
import 'custom_image_view.dart';

class BodyWidget extends StatelessWidget {
  final int index;
  final List<BodyPartsModel>? list;
  final List<Color>? circleColors;

  const BodyWidget({Key? key, this.list, this.index = 1, this.circleColors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _circleIndex = 0;
    return SizedBox(
      height: getVerticalSize(380),
      width: (size.width - 32) / 2,
      child: Stack(
        children: [
          Stack(
            children: list!
                .map((e)
            {
              _circleIndex++;
                      return Visibility(
                          visible: e.marginLeft != null && e.marginTop != null,
                          child: CircularContainerWidget(
                              color: circleColors?[_circleIndex - 1] ?? ColorConstant.teal200,
                              margin: getMargin(
                                  top: e.marginTop ?? 0,
                                  left: e.marginLeft ?? 0)));
                    })
                .toList(),
          ),
          index == 1
              ? CustomImageView(
                  height: getVerticalSize(380),
                  width: (size.width - 32) / 2,
                  svgPath: CurrentUser.user.male!
                      ? ImageConstant.eventMan
                      : ImageConstant.eventWoman,
                )
              : CustomImageView(
                  height: getVerticalSize(380),
                  width: (size.width - 32) / 2,
                  svgPath: CurrentUser.user.male!
                      ? ImageConstant.eventMan2
                      : ImageConstant.eventWoman2,
                ),
        ],
      ),
    );
  }
}
