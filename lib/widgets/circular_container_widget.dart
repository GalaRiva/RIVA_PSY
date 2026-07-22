import 'package:flutter/material.dart';
import 'package:riva_psy/core/app_export.dart';

Widget CircularContainerWidget ({
  final double? height,
  final double? width,
  final EdgeInsetsGeometry? margin,
  final Color? color,
}) {
  return Container(
    margin: margin,
    height: height == null ? getSize(39) : height,
    width: width == null ? getSize(39) : width,
    decoration: BoxDecoration(
        color: color == null ? ColorConstant.teal200 : color,
        borderRadius: BorderRadius.circular(100)
    ),
  );
}