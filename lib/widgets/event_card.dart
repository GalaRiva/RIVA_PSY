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
  const EventCard({Key? key, required this.model, this.onTap, this.suffix = '', this.cardHeight = 78, this.iconColor, required this.isSelect, this.textIsFitted, this.cardWidth}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width / 3.6;
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
                33,
              ),
              width:
              width,
              radius: BorderRadius.circular(
                getHorizontalSize(
                  3,
                ),
              ),
            ),
            SizedBox(
              height: getVerticalSize(model.name.isEmpty ? 23 : 5),
            ),
            Visibility(
              visible: model.name.isNotEmpty,
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
            model.name + suffix!,
            textAlign: TextAlign.center,
            maxLines: 3,
            style: AppStyle
                .txtSFProDisplayLight11Gray800
        ),
      );
    else return Text(
        model.name + suffix!,
        textAlign: TextAlign.center,
        maxLines: 3,
        style: AppStyle
            .txtSFProDisplayLight11Gray800

    );
  }

}
