import 'package:flutter/material.dart';

// This is where the magic happens.
// This functions are responsible to make UI responsive across all the mobile devices.

// `size` used to be a plain top-level `Size size = ...` — in Dart, a
// top-level variable's initializer runs exactly once, on first access, and
// is cached forever after. On iOS specifically that first access could
// happen before the engine had handed over the real window metrics (this
// app was still mid-transition off the legacy pre-UIScene window APIs —
// see the "UIScene lifecycle will soon be required" build warning), baking
// in an undersized snapshot that every getHorizontalSize/getVerticalSize/
// getFontSize call downstream then used for the rest of the app's life —
// matching the "fonts/icons too small almost everywhere on iOS" report.
// Android's embedding apparently didn't hit the same early-read timing, so
// this went unnoticed there. Making these getters (re-read fresh every
// call, via the current non-deprecated View API) instead of a cached
// variable fixes it regardless of the exact timing at play.
Size get size {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  return view.physicalSize / view.devicePixelRatio;
}

// Caution! If you think these are static values and are used to build a static UI,  you mustn’t.
// These are the Viewport values of your Figma Design.
// These are used in the code as a reference to create your UI Responsively.
const num FIGMA_DESIGN_WIDTH = 360;
const num FIGMA_DESIGN_HEIGHT = 800;
const num FIGMA_DESIGN_STATUS_BAR = 29;

///This method is used to get device viewport width.
get width {
  return size.width;
}

///This method is used to get device viewport height.
// Tried excluding the bottom safe-area inset from this (see git history) on
// the theory that it was under-measuring height and capping font/icon sizes
// on iOS — confirmed numerically (getFontSize(16) went 15->16), but that's
// too small a difference to be the "fonts feel small" complaint, and it's a
// global reference used for bottom-anchored absolute positioning all over
// the app — inflating it shifted several screens' buttons down/off-position
// (confirmed on-device: "кнопки уехали"). Reverted; not worth the layout
// regression for a 1px, imperceptible font gain.
get height {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  final mediaQuery = MediaQueryData.fromView(view);
  num statusBar = mediaQuery.viewPadding.top;
  num bottomBar = mediaQuery.viewPadding.bottom;
  num screenHeight = size.height - statusBar - bottomBar;
  return screenHeight;
}

///This method is used to set padding/margin (for the left and Right side) & width of the screen or widget according to the Viewport width.
double getHorizontalSize(double px) {
  return ((px * width) / FIGMA_DESIGN_WIDTH);
}

///This method is used to set padding/margin (for the top and bottom side) & height of the screen or widget according to the Viewport height.
double getVerticalSize(double px) {
  return ((px * height) / (FIGMA_DESIGN_HEIGHT - FIGMA_DESIGN_STATUS_BAR));
}

///This method is used to set smallest px in image height and width
double getSize(double px) {
  var height = getVerticalSize(px);
  var width = getHorizontalSize(px);
  if (height < width) {
    return height.toInt().toDouble();
  } else {
    return width.toInt().toDouble();
  }
}

///This method is used to set text font size according to Viewport
// Deliberately decoupled from getSize() (shared with icon/shape sizing) so
// this can boost text specifically without touching layout dimensions —
// a similar boost via `height` shifted button *positions* across several
// screens (see height's own doc comment); a boost isolated to font size
// has no such effect since padding/margins/positions all go through
// getHorizontalSize/getVerticalSize directly, never through this. Factor
// chosen to make text legibly bigger per user feedback (eye strain testing
// at the previous, unboosted size), not just numerically different.
const double _fontSizeBoost = 1.2;
double getFontSize(double px) {
  return getSize(px) * _fontSizeBoost;
}

///This method is used to set padding responsively
EdgeInsetsGeometry getPadding({
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  return getMarginOrPadding(
    all: all,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
}

///This method is used to set margin responsively
EdgeInsetsGeometry getMargin({
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  return getMarginOrPadding(
    all: all,
    left: left,
    top: top,
    right: right,
    bottom: bottom,
  );
}

///This method is used to get padding or margin responsively
EdgeInsetsGeometry getMarginOrPadding({
  double? all,
  double? left,
  double? top,
  double? right,
  double? bottom,
}) {
  if (all != null) {
    left = all;
    top = all;
    right = all;
    bottom = all;
  }
  return EdgeInsets.only(
    left: getHorizontalSize(
      left ?? 0,
    ),
    top: getVerticalSize(
      top ?? 0,
    ),
    right: getHorizontalSize(
      right ?? 0,
    ),
    bottom: getVerticalSize(
      bottom ?? 0,
    ),
  );
}
