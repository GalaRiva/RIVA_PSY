import 'package:flutter/material.dart';

/// Premium UI palette. Use these for any new/redesigned component instead
/// of hardcoding Color(0xFF...) or reaching for ColorConstant.
abstract class AppColors {
  static const Color primary = Color(0xFF2A5C55);
  static const Color primaryLight = Color(0xFFE4EFEA);

  static const Color background = Color(0xFFF9FAFA);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1A1C1E);
  static const Color textSecondary = Color(0xFF7A8287);

  static const Color error = Color(0xFFD94A4A);
  static const Color divider = Color(0xFFEAEEEE);
}
