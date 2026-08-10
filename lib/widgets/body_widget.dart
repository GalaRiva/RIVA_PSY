import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:riva_psy/core/app_export.dart';

import '../core/models/body_parts_model.dart';
import '../core/user_data/user.dart';
import '../core/utils/size_utils.dart';
import 'body_zone_colors.dart';
import 'circular_container_widget.dart';

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
          // Outline first, markers on top — was the other way round, so the
          // back-view silhouette (which has an opaque white fill, unlike
          // the front one) completely hid its own markers underneath it.
          index == 1
              ? SvgPicture.asset(
                  CurrentUser.user.male!
                      ? 'assets/images/body_outline_male.svg'
                      : 'assets/images/body_outline_female.svg',
                  height: getVerticalSize(380),
                  width: (size.width - 32) / 2,
                  fit: BoxFit.contain,
                )
              : SvgPicture.asset(
                  CurrentUser.user.male!
                      ? 'assets/images/body_outline_male_back.svg'
                      : 'assets/images/body_outline_female_back.svg',
                  height: getVerticalSize(380),
                  width: (size.width - 32) / 2,
                  fit: BoxFit.contain,
                ),
          Stack(
            children: list!
                // Front view shows every zone except "спина"; back view
                // shows only "спина" — each sensation appears on exactly
                // one of the two silhouettes, never both.
                .where((e) => index == 1 ? e.identity != 'back' : e.identity == 'back')
                .map((e)
            {
              _circleIndex++;
                      // Zone colors are keyed by body-part identity (spec:
                      // голова и лицо — голубой, горло — синий, грудная
                      // клетка — бордовый, плечи и руки — красный, живот —
                      // зеленый, ноги — желтый, спина — фиолетовый) rather
                      // than by list position, so they can't drift out of
                      // sync if the list order ever changes.
                      final fallbackColor = circleColors != null &&
                              _circleIndex - 1 < circleColors!.length
                          ? circleColors![_circleIndex - 1]
                          : ColorConstant.teal200;
                      return Visibility(
                          visible: e.marginLeft != null && e.marginTop != null,
                          child: CircularContainerWidget(
                              color: bodyZoneColor(e.key, fallbackColor),
                              margin: getMargin(
                                  top: e.marginTop ?? 0,
                                  left: e.marginLeft ?? 0)));
                    })
                .toList(),
          ),
        ],
      ),
    );
  }
}
