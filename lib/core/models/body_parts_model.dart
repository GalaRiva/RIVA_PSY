import 'package:easy_localization/easy_localization.dart';

class BodyPartsModel {
  final String bodyPart;
  final List<dynamic> whatHurts;
  final double? marginLeft;
  final double? marginTop;
  // Stable, language-independent identifier for standard (seeded) entries.
  // Null for custom entries the user typed themselves — those have no
  // translation key, so identity falls back to `bodyPart`.
  final String? key;
  // Parallel to whatHurts — the literal translation key for each sensation
  // word, same order. Null (or a length mismatch) for anything seeded
  // before this field existed, or custom entries — falls back to the
  // frozen whatHurts text in that case.
  final List<String>? whatHurtsKeys;


  BodyPartsModel( {this.marginLeft, this.marginTop,required this.bodyPart, required this.whatHurts, this.key, this.whatHurtsKeys});

  String get identity => key ?? bodyPart;

  // Re-translates bodyPart/whatHurts from their stable keys at display
  // time instead of trusting the frozen text, which was translated once
  // at Hive-seed time and keeps showing whatever locale was active then
  // (see EventModel.localizedName — same bug, same fix, different model).
  String get localizedBodyPart => key != null ? key!.tr() : bodyPart;

  List<String> get localizedWhatHurts {
    final keys = whatHurtsKeys;
    if (keys != null && keys.length == whatHurts.length) {
      return keys.map((k) => k.tr()).toList();
    }
    return whatHurts.map((e) => e.toString()).toList();
  }

  // Single source of truth for the "select what hurts" dialog height,
  // replacing three duplicated Russian-text switch statements.
  static const _messageBoxHeights = {
    'head_and_face': 266.0, 'throat': 266.0, 'chest': 314.0,
    'shoulders_and_arms': 314.0, 'legs': 266.0, 'stomach': 314.0,
  };
  double get messageBoxHeight => _messageBoxHeights[key] ?? 160;

  factory BodyPartsModel.fromJson(Map<String, dynamic> json) => BodyPartsModel(
      bodyPart: json['bodyPart'],
      whatHurts: json['whatHurts'],
      marginLeft: json['marginLeft'],
      marginTop: json['marginTop'],
      key: json['key'],
      whatHurtsKeys: (json['whatHurtsKeys'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),);

  Map<String, dynamic> toJson () => {
    'bodyPart': bodyPart,
    'whatHurts': whatHurts,
    'marginLeft': marginLeft,
    'marginTop': marginTop,
    'key': key,
    'whatHurtsKeys': whatHurtsKeys,
  };
}