import 'package:flutter/material.dart';

import '../../../core/models/event_model.dart';
import '../../../core/utils/color_constant.dart';
import '../../../core/utils/size_utils.dart';
import '../../../theme/app_style.dart';
import '../../../widgets/custom_image_view.dart';

class SecondVariantEventCard extends StatelessWidget {
  final List<Widget>? content;
  const SecondVariantEventCard({Key? key, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
              constraints: BoxConstraints(
                minHeight: getSize(
                    17
                ),
              ),
              decoration: BoxDecoration(
                  color: ColorConstant.fromHex('#F6F5F6').withOpacity(0.77),
                  borderRadius: BorderRadius.circular(
                    getHorizontalSize(
                      3,
                    ),
                  ),
                  border: Border.all(
                      color: ColorConstant.fromHex('#403875').withOpacity(0.22),
                      width: 1
                  )
              ),
      child: Row(
        children: content == null ? [SizedBox()] : content!.map((e) => Padding(padding: getPadding(left: 4, right: 4), child: e,)).toList(),
      ),
    );
  }
}
/**/