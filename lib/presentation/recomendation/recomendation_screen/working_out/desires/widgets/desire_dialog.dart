import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;
import 'package:riva_psy/core/app_export.dart';
import 'package:riva_psy/core/models/desire/desire.dart';
import 'package:riva_psy/widgets/custom_message_box.dart';

import '../../../../../../core/utils/color_constant.dart';
import '../../../../../../core/utils/size_utils.dart';

class DesireDialog extends StatelessWidget {
  final Function()? onTap;
  final Desire desire;

  const DesireDialog({Key? key, this.onTap, required this.desire}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: CustomMessageBox(
          bgColor: ColorConstant.darkBg,
            width: size.width - 20,
            height: 600,
            title: DateFormat('dd.MM.yy').format(desire.createdAt), content: Padding(

          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, left: 5, bottom: 20),
                child: AspectRatio(aspectRatio: 295/227,
                child: Image.asset(ImageConstant.desireItemPNG, fit: BoxFit.fill,),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text(desire.simpleDesires, style: AppStyle.txtSFProDisplayLight14.copyWith(fontSize: 15, overflow: TextOverflow.ellipsis), maxLines: 10,)),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(3),
                ),
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text(desire.desireDetails, style: AppStyle.txtSFProDisplayLight14.copyWith(fontSize: 15, overflow: TextOverflow.ellipsis), maxLines: 10)),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              _DesireActionButton(
              width: 244,
              height: 50,
              onTap: onTap,
              prefixWidget: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 15,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: ColorConstant.cyan700, width: 1)
                  ),
                ),
              ),
              centralWidget: () {
                if (desire.completed) {
                  return Text('${'executed_1'.tr()} ${DateFormat('dd.MM.yyyy').format(
                      desire.dateOfExecution)}'.toUpperCase(),
                    style: AppStyle.txtSFProDisplayLight16Cyan700,);
                } else if (DateTime.now().isBefore(desire.dateOfExecution)) {
                  return Row(children: [
                      Text('${'will_execute'.tr()} '.toUpperCase(),
                style: AppStyle.txtSFProDisplayLight16DeepPurple,),
                    Text('${DateFormat('dd.MM.yyyy').format(
                        desire.dateOfExecution)}'.toUpperCase(),
                      style: AppStyle.txtSFProDisplayLight16Cyan700,)
                  ],);
                }
                return Text('lost_wish'.tr().toUpperCase(),
                  style: AppStyle.txtSFProDisplayLight16DeepPurple,);
              }())
    ],
          ),
        ))
      ),
    );  }
}

// Dark by default, light while pressed — the opposite of CustomButton's
// static light background, needed only on this dialog's dark backdrop.
// Kept local rather than added to CustomButton so it doesn't change the
// press behavior of every other button in the app.
class _DesireActionButton extends StatefulWidget {
  final double width;
  final double height;
  final VoidCallback? onTap;
  final Widget prefixWidget;
  final Widget centralWidget;

  const _DesireActionButton({
    required this.width,
    required this.height,
    required this.onTap,
    required this.prefixWidget,
    required this.centralWidget,
  });

  @override
  State<_DesireActionButton> createState() => _DesireActionButtonState();
}

class _DesireActionButtonState extends State<_DesireActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _pressed ? Colors.white.withOpacity(0.7) : ColorConstant.darkBg,
          borderRadius: BorderRadius.circular(getHorizontalSize(3)),
          border: Border.all(color: Colors.white, width: 1),
          boxShadow: [
            BoxShadow(
                color: ColorConstant.fromHex('#5F6B80').withOpacity(0.2),
                offset: Offset(0, 6),
                blurRadius: 5),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [widget.prefixWidget, widget.centralWidget],
          ),
        ),
      ),
    );
  }
}
