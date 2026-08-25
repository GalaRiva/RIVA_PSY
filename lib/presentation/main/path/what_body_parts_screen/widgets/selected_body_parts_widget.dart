import 'package:flutter/material.dart';

import '../../../../../core/models/body_parts_model.dart';
import '../../../../../core/utils/color_constant.dart';
import '../../../../../core/utils/size_utils.dart';
import '../../../../../theme/app_style.dart';
import '../controller.dart';
import '../k32_model.dart';

class SelectedBodyPartsWidget extends StatelessWidget {
  final List<K32Model> list;
  final K32Model model;
  final K32Controller controller;
  const SelectedBodyPartsWidget({Key? key, required this.model, required this.list, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        list.remove(model);
        controller.update();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(
              minHeight: getVerticalSize(50),
            ),
          width: size.width / 2 - 20,
          decoration: BoxDecoration(
            color: ColorConstant.whiteA700,
            borderRadius: BorderRadius.circular(3),
            border: Border.all(
              color: ColorConstant.fromHex('#403875').withOpacity(0.22),
              width: 1
            ),
          ),
            child: Container(
                margin: getMargin(left: 12, right: 12, top: 8, bottom: 8),
                child: Center(
                    child: Text(model.bodyPartsModel.localizedBodyPart,
                        textAlign: TextAlign.center,
                        style: AppStyle.txtSFProDisplayLight10w400.copyWith(fontSize: 16)),
                )),
          ),
          SizedBox(width: getHorizontalSize(12),),
          Visibility(
            visible: model.bodyPartsModel.whatHurts.isNotEmpty,
            child: Container(
              constraints: BoxConstraints(
                minHeight: getVerticalSize(50),
              ),
              width: size.width / 2 - 20,
              decoration: BoxDecoration(
                color: ColorConstant.whiteA700,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                    color: ColorConstant.fromHex('#403875').withOpacity(0.22),
                    width: 1
                ),
              ),
              child: Container(
                  margin: getMargin(left: 12, right: 12, top: 8, bottom: 8),
                  child: Center(
                      child: Text(model.subtitle,
                          textAlign: TextAlign.center,
                          style: AppStyle.txtSFProDisplayLight10w400.copyWith(fontSize: 16)),
                  )),
            ),
          ),
          SizedBox(width: getHorizontalSize(12),),
        ],
      ),
    );
  }
}
