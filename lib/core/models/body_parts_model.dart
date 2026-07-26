class BodyPartsModel {
  final String bodyPart;
  final List<dynamic> whatHurts;
  final double? marginLeft;
  final double? marginTop;
  // Stable, language-independent identifier for standard (seeded) entries.
  // Null for custom entries the user typed themselves — those have no
  // translation key, so identity falls back to `bodyPart`.
  final String? key;


  BodyPartsModel( {this.marginLeft, this.marginTop,required this.bodyPart, required this.whatHurts, this.key});

  String get identity => key ?? bodyPart;

  factory BodyPartsModel.fromJson(Map<String, dynamic> json) => BodyPartsModel(bodyPart: json['bodyPart'], whatHurts: json['whatHurts'], marginLeft: json['marginLeft'], marginTop: json['marginTop'], key: json['key'],);

  Map<String, dynamic> toJson () => {
    'bodyPart': bodyPart,
    'whatHurts': whatHurts,
    'marginLeft': marginLeft,
    'marginTop': marginTop,
    'key': key
  };
}