class EventModel {
   String name;
   String svgPath;
   // Stable, language-independent identifier for standard (seeded) entries.
   // Null for custom entries the user typed themselves — those have no
   // translation key, so identity falls back to `name`.
   String? key;

  EventModel(this.name, this.svgPath, [this.key]);

  String get identity => key ?? name;

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(json['name'], json['svgPath'], json['key']);

  Map<String, dynamic> toJson() => {
    'name': name,
    'svgPath': svgPath,
    'key': key
  };
}