import 'package:flutter/material.dart';

import '../../../../core/utils/color_constant.dart';
import '../../../../core/utils/size_utils.dart';
import '../../../../theme/app_decoration.dart';
import '../../../../theme/app_style.dart';

class EventChangeTextFieldWidget extends StatelessWidget {
  final Function(String text)? onChange;
  final String title;
  final String hintText;
  final TextEditingController textEditingController;
  const EventChangeTextFieldWidget({Key? key, required this.title, this.onChange, required this.hintText, required this.textEditingController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: getMargin(
        top: 30,
      ),
      padding: getPadding(
        left: 6,
        top: 12,
        right: 6,
        bottom: 12,
      ),
      decoration:
      AppDecoration.outlineBluegray60014.copyWith(
        borderRadius: BorderRadiusStyle.customBorderBL3,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
            style: AppStyle.txtSFProDisplayLight11Gray800
                .copyWith(
              letterSpacing: getHorizontalSize(
                0.44,
              ),
            ),
          ),
          Padding(
            padding:
            getPadding(top: 20),
            child: SizedBox(
              height: 57,
              width: MediaQuery.of(context).size.width - 32,
              child: TextFormField(
                controller: textEditingController,
                onChanged: onChange,
                maxLines: 30,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide.none
                    ),
                    fillColor: ColorConstant.gray200,
                    filled: true,
                    hintText: hintText,

                    hintStyle: TextStyle(fontFamily: 'Manrope', fontWeight: FontWeight.w300, fontSize: 14, color: ColorConstant.fromHex('#3B3B4A'),)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
