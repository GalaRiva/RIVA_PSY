import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import '../../../core/utils/color_constant.dart';
import '../../../core/utils/size_utils.dart';
import '../../../theme/app_decoration.dart';
import '../../../theme/app_style.dart';
import '../../../widgets/custom_image_view.dart';

class EventCard extends StatelessWidget {
  final EventModel model;
  final double? cardWidth;
  final double? cardHeight;
  final VoidCallback? onTap;
  final String? suffix;
  final Color? iconColor;
  final bool isSelect;
  final bool? textIsFitted;
  // Explicit overrides for callers that want an icon/font size independent
  // of the cardHeight-proportional default (e.g. the main Path screens
  // wanting a modest bump without inflating the whole card). Leave null to
  // keep the normal proportional-to-cardHeight behavior.
  final double? iconSizeOverride;
  final double? fontSizeOverride;
  const EventCard({Key? key, required this.model, this.onTap, this.suffix = '', this.cardHeight = 150, this.iconColor, required this.isSelect, this.textIsFitted, this.cardWidth, this.iconSizeOverride, this.fontSizeOverride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3.6;
    // Icon width is capped to the card's own width (minus padding) rather
    // than a flat screen-width fraction, so doubling the icon size below
    // doesn't overflow narrower cards.
    final iconWidth = (cardWidth ?? width) - 20;
    // Icon height scales with cardHeight (66 at the default 150) instead of
    // being a flat constant — compact cards (cardHeight: 44, used by
    // neutral_tab.dart and exercise_content_widget.dart) were getting the
    // same 66px icon as a full-size 150-tall card and blowing way past
    // their own bounds, wrecking the whole grid.
    final iconHeight = iconSizeOverride ?? ((cardHeight ?? 150) * 66 / 150);
    return InkWell(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        width:
          cardWidth ?? width
        ,
        decoration: BoxDecoration(
          color: ColorConstant.fromHex('#F6F5F6').withOpacity(0.77),
          borderRadius: BorderRadius.circular(
            getHorizontalSize(
              3,
            ),
        ),
          border: Border.all(
            color: isSelect ? ColorConstant.cyan700 : ColorConstant.fromHex('#403875').withOpacity(0.22),
            width: 1
          )
      ),
        padding: EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CustomImageView(
              alignment: Alignment.center,
              svgPath: model.svgPath,
              color: iconColor ?? ColorConstant.cyan700,
              fit: BoxFit.scaleDown,
              height: getVerticalSize(
                iconHeight,
              ),
              width:
              iconWidth,
              radius: BorderRadius.circular(
                getHorizontalSize(
                  3,
                ),
              ),
            ),
            SizedBox(
              height: getVerticalSize(model.localizedName.isEmpty ? 23 : 5),
            ),
            Visibility(
              visible: model.localizedName.isNotEmpty,
              child: text(),
            ),
          ],
        ),
      ),
    );
  }
  Widget text () {
    if(textIsFitted != null && textIsFitted! )
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
            model.localizedName + suffix!,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: AppStyle
                .txtSFProDisplayLight11Gray800
                .copyWith(fontSize: getFontSize(fontSizeOverride ?? 15))
        ),
      );
    else return Text(
        model.localizedName + suffix!,
        textAlign: TextAlign.center,
        maxLines: 3,
        style: AppStyle
            .txtSFProDisplayLight11Gray800
            .copyWith(fontSize: getFontSize(fontSizeOverride ?? 15))

    );
  }

}
