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
  // Uniform size multiplier, applied to the box AND to every marker's
  // margin together — a native bigger render instead of an external
  // Transform.scale, which was fitting BoxFit.contain against the wrong
  // (unscaled) box size and letting the outline's feet paint outside it.
  final double scale;

  const BodyWidget({Key? key, this.list, this.index = 1, this.circleColors, this.scale = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _circleIndex = 0;
    final boxHeight = getVerticalSize(380) * scale;
    final boxWidth = (size.width - 32) / 2 * scale;
    return SizedBox(
      height: boxHeight,
      width: boxWidth,
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
                  height: boxHeight,
                  width: boxWidth,
                  fit: BoxFit.contain,
                )
              : SvgPicture.asset(
                  CurrentUser.user.male!
                      ? 'assets/images/body_outline_male_back.svg'
                      : 'assets/images/body_outline_female_back.svg',
                  height: boxHeight,
                  width: boxWidth,
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
                              height: getSize(39) * scale,
                              width: getSize(39) * scale,
                              margin: getMargin(
                                  top: (e.marginTop ?? 0) * scale,
                                  left: (e.marginLeft ?? 0) * scale)));
                    })
                .toList(),
          ),
        ],
      ),
    );
  }
}
