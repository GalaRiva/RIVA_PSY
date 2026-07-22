import 'package:flutter/material.dart';
import 'package:riva_psy/widgets/custom_image_view.dart';

import '../core/utils/image_constant.dart';
import '../core/utils/size_utils.dart';
import '../theme/app_style.dart';

class CustomPopButton extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final VoidCallback? onPop;
  const CustomPopButton({Key? key, required this.text, this.onPop, this.style}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var onWillPop = true;
        onPop == null ? onWillPop = true : { onWillPop = false, onPop!()};
        return onWillPop;
      },
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomImageView(
                svgPath: ImageConstant
                    .leftArrow,
                height:
                getVerticalSize(
                    8),
                width:
                getHorizontalSize(
                    4),
                margin: getMargin(
                    bottom: 3)),

               Padding(
                    padding:
                    getPadding(
                        left: 6),
                    child: Text(
                        text,
                        overflow:
                        TextOverflow
                            .ellipsis,
                        textAlign:
                        TextAlign
                            .left,
                        style: style ?? AppStyle.txtSFProDisplayLight10)) // or txtSFProDisplayLight10Gray800
          ],
        ),
      ),
    );
  }
}
