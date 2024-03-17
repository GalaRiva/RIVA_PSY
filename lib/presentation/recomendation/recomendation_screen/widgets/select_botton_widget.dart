import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:listenmebaby71_s_application17/widgets/custom_button.dart';

import '../../../../../core/utils/color_constant.dart';
import '../../../../../theme/app_style.dart';
import '../../../../../widgets/custom_message_box.dart';
import '../../../../core/utils/size_utils.dart';

class SelectButtonWidget extends StatefulWidget {
  final String title;
  final String content;
  final double? height;
  final bool? isSelect;

  const SelectButtonWidget({Key? key, required this.title, required this.content, this.height, this.isSelect}) : super(key: key);

  @override
  State<SelectButtonWidget> createState() => _SelectButtonWState();
}

class _SelectButtonWState extends State<SelectButtonWidget> {
  bool opened = false;

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
      height: 30,
      child: CustomButton( text: widget.title.toUpperCase(),
        width: size.width / 2 - 40,
        height: 20,
        bgColor: opened ? ColorConstant.blueGray20001 : Colors.white.withOpacity(0.24),
        onTap: () {
        setState(() {
          opened = !opened;
        });
          showDialog(
              barrierColor: Colors.transparent,
              context: context,
              builder: (context) =>
                  CustomMessageBox(title: widget.title,
                    content: widget.content.split('.').join('.\n').split('?').join('.\n').split('!').join('.\n'),
                    height: 470 ?? 150,)).then((value) {
            setState(() {
              opened = !opened;
            });
          });
        },
        //bgColor: Colors.white,
        textStyle: AppStyle.txtSFProDisplayRegular12.copyWith(
            fontWeight: FontWeight.w600,
            color: opened ? ColorConstant.whiteA700 : ColorConstant.deepPurple600
        ),),
    );
  }
}

