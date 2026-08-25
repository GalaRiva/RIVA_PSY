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

  // Shared data-viz accent set for the analytics dashboards (Energy Matrix
  // quadrants, Synergy Heatmap gradient, Social Battery split) — one
  // consistent four-color language drawn from the app's own brand colors
  // instead of each chart picking its own ad-hoc traffic-light palette.
  static const Color chartTeal = primary; // calm / resourced / alone
  static const Color chartGold = Color(0xFFC9A24B); // energized / drive / social
  static const Color chartRose = Color(0xFFB0495C); // stress / tension
  static const Color chartPurple = Color(0xFF5B4EA8); // depleted / burnout
}
