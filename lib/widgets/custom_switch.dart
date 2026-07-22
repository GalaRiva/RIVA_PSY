import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:riva_psy/core/app_export.dart';

class CustomSwitch extends StatelessWidget {
  CustomSwitch({this.alignment, this.margin, this.value, this.onChanged});

  Alignment? alignment;

  EdgeInsetsGeometry? margin;

  bool? value;

  Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(
            alignment: alignment ?? Alignment.center,
            child: _buildSwitchWidget(),
          )
        : _buildSwitchWidget();
  }

  _buildSwitchWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: FlutterSwitch(
        value: value ?? false,
        height: getHorizontalSize(28),
        width: getHorizontalSize(48),
        toggleSize: getSize(22),
        borderRadius: getHorizontalSize(
          14.00,
        ),
        activeColor: ColorConstant.cyan700,
        activeToggleColor: ColorConstant.whiteA700,
        inactiveColor: ColorConstant.blueGray100,
        inactiveToggleColor: ColorConstant.whiteA700,
        onToggle: (value) {onChanged!(value);},
      ),
    );
  }
}
