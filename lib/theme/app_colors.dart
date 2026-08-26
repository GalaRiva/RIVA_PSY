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
  // quadrants, Synergy Heatmap gradient, Social Battery split) — narrowed
  // to shades within the teal/emerald family (plus purple as the one
  // deliberate outlier for "depleted") rather than a four-hue traffic-light
  // set. Gold is kept only as a small decorative accent (e.g. the "right
  // now" glow point, popup borders) — it's no longer used to encode data.
  static const Color chartTeal = Color(0xFF0E8F6B); // calm / resourced / alone — deep emerald
  static const Color chartAqua = Color(0xFF1CB8A6); // energized / drive / social — vivid turquoise
  static const Color chartStress = Color(0xFF2E5C63); // stress / tension — cool slate-teal
  static const Color chartPurple = Color(0xFF5A3FC2); // depleted / burnout — rich violet
  static const Color chartGold = Color(0xFFDFA320); // decorative accents only — not a data color
}
