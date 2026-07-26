class EventModel {
   String name;
   String svgPath;
   // Stable, language-independent identifier for standard (seeded) entries.
   // Null for custom entries the user typed themselves — those have no
   // translation key, so identity falls back to `name`.
   String? key;

  EventModel(this.name, this.svgPath, [this.key]);

  String get identity => key ?? name;

  // Neutral-emotion polarity (standardEventListThree's +/- pairs). Seeded
  // entries encode it in the key suffix (_positive/_+ or _negative/_-);
  // custom entries the user adds have no key, so this falls back to the
  // trailing +/- character on `name` (see K27Controller.updateCurrentEventList).
  bool get isNeutralPositive {
    final k = key;
    if (k != null) return k.endsWith('_positive') || k.endsWith('_+');
    return name.trim().endsWith('+');
  }

  bool get isNeutralNegative {
    final k = key;
    if (k != null) return k.endsWith('_negative') || k.endsWith('_-');
    return name.trim().endsWith('-');
  }

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(json['name'], json['svgPath'], json['key']);

  Map<String, dynamic> toJson() => {
    'name': name,
    'svgPath': svgPath,
    'key': key
  };
}