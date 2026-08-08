import 'package:flutter/widgets.dart';

/// Phosphor Icons (Regular), used directly instead of the phosphor_flutter
/// package. That package (and flutter_feather_icons, the spec's other
/// option) both declare `class XxxIconData extends IconData` — this
/// Flutter SDK marks IconData `final class`, so neither package's Dart
/// source compiles here at all ("The class 'IconData' can't be extended
/// outside of its library because it's a final class", confirmed by an
/// actual failed build, not a guess). The Phosphor .ttf itself has no such
/// restriction — it's bundled directly under assets/fonts/Phosphor.ttf
/// (copied from the phosphor_flutter package, MIT-licensed) and registered
/// as its own font family in pubspec.yaml, with codepoints taken from the
/// same package's phosphor_icons_regular.dart source.
abstract class AppIcons {
  static const IconData plus = IconData(0xe3d4, fontFamily: 'Phosphor');
  static const IconData x = IconData(0xe4f6, fontFamily: 'Phosphor');
  static const IconData minus = IconData(0xe32a, fontFamily: 'Phosphor');
  static const IconData check = IconData(0xe182, fontFamily: 'Phosphor');
  static const IconData caretRight = IconData(0xe13a, fontFamily: 'Phosphor');
  static const IconData caretUp = IconData(0xe13c, fontFamily: 'Phosphor');
  static const IconData caretDown = IconData(0xe136, fontFamily: 'Phosphor');
}
