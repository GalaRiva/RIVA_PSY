import 'package:flutter/material.dart';

import '../../../../core/models/body_parts_model.dart';
import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_style.dart';
import '../../../main/path/what_body_parts_screen/k32_model.dart';
import '../controller.dart';


class BodyPartWidget extends StatelessWidget {
  String title;
  final BodyPartsModel model;
  final K54Controller controller;
  final bool? visible;
  final Color? color;
  final double? cwidth;

  BodyPartWidget({
    Key? key,
    this.visible = true,
    required this.model,
    required this.title,
    required this.controller,
    this.color, this.cwidth,
  }) : super(key: key);

  bool isContain() {
    bool result = false;
    for (var item in controller.selectedBodyParts) {
      if (item.bodyPartsModel.identity == model.identity) {
        result = true;
        break;
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    bool nonVisible = isContain();
    final double width = title.length + 40;

    return Stack(
      children: [
        Container(
          height: getVerticalSize(
            30,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: getHorizontalSize(20),),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.transparent,
                  fontSize: getFontSize(
                    10,
                  ),
                  fontFamily: 'SF Pro Display',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(width: getHorizontalSize(20),),
            ],
          ),
        ),
        Visibility(
          visible: !nonVisible,
          child: InkWell(
            onTap: title == model.bodyPart
                ? () {
              if(model.whatHurts.isNotEmpty)
                controller.showSelectWhatHartDialog(
                    context, model);
              else controller.selectedBodyParts.add(K32Model(model, title));
              controller.dayEventModel.whatBodyParts = controller.selectedBodyParts;
              nonVisible = false;
              controller.update();
            }
                : () {
              controller.selectedBodyParts.add(K32Model(model, title));
              controller.dayEventModel.whatBodyParts = controller.selectedBodyParts;
              nonVisible = false;
              Navigator.pop(context);
              controller.update();
            },
            child: Container(
              height: getVerticalSize(50),
              width: cwidth ?? size.width / 2 - 60,
              decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                        color:
                        ColorConstant.fromHex('#5F6B80').withOpacity(0.2),
                        offset: Offset(0, 6),
                        blurRadius: 5)
                  ]),
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppStyle.txtSFProDisplayLight16,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
