class TariffModel {
  final String name;
  final String nameInEn;
  DateTime endDate;
  final String description;
   double cost;
  final List<String> advantages;
  final bool trial;

  TariffModel(
      {required this.name, required this.nameInEn, required this.endDate, required this.description, required this.cost, required this.advantages, this.trial = false, });

  TariffModel copyWith({
    String? name,
    String? nameInEn,
    DateTime? endDate,
    String? description,
    double? cost,
    List<String>? advantages,
  }) {
    return TariffModel(
      name: name ?? this.name,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      advantages: advantages ?? this.advantages, nameInEn: nameInEn ?? this.nameInEn,
    );
  }

  factory TariffModel.fromJson(Map<String, dynamic> json) =>
      TariffModel(name: json['name'],
          endDate: DateTime.parse(json['endDate']),
          description: json['description'],
          trial: json['trial'] == null ? false : json['trial'],
          cost: json['cost'],
          nameInEn: json['nameInEn'] == null ? (json['name'] == 'Базовый' ? 'Base' : 'Oreon') : json['nameInEn'],
          advantages: json['advantages'] == null ? <String>[] : (json['advantages']as List<dynamic>).map((e)=> e.toString()).toList(), );

  Map<String, dynamic> toJson () => {
    'name': name,
    'endDate': endDate.toIso8601String(),
    'description': description,
    'cost':cost,
    'advantages': advantages,
    'trial': trial
  };

  static TariffModel BASE_TARIFF = TariffModel(
  name: 'Базовый',
  endDate: DateTime(9999, 12, 24),
  // Translation key, not literal display text — the subscription screen
  // calls .tr() on this. Was hardcoded Russian, showing up untranslated
  // even in the Spanish/English builds.
  description: 'base_tariff_description',
  cost: 0,
  advantages: [], nameInEn: 'Base',
  );

  static TariffModel ORION_TARIFF_14_DAYS = TariffModel(
      name: 'Орион',
      trial:  true,
      endDate: DateTime(DateTime.now().year, DateTime.now().month,DateTime.now().day + 14,),
      description: '',
      cost: 0,
      advantages: [
        'Доступ ко всем текстовым рекомендациям',
        'Доступ ко всем аудио рекомендациям',
        'Доступ к медитациям',
        'Доступ ко всей аналитике состояний',
        'Хранение всех данных на вашем телефоне'
      ], nameInEn: 'Oreon');

  static TariffModel ORION_TARIFF_MONTH = TariffModel(
      name: 'Орион', nameInEn: 'Oreon',
      endDate: DateTime(DateTime.now().year, DateTime.now().month + 1,DateTime.now().day,),
      description: '',
      cost: 0.01,
      advantages: [
        'Доступ ко всем текстовым рекомендациям',
        'Доступ ко всем аудио рекомендациям',
        'Доступ к медитациям',
        'Доступ ко всей аналитике состояний',
        'Хранение всех данных на вашем телефоне'
      ]);

  static TariffModel ORION_TARIFF_YEAR = TariffModel(
      name: 'Орион',
      nameInEn: 'Oreon',
      endDate: DateTime(DateTime.now().year + 1, DateTime.now().month,DateTime.now().day,),
      description: '',
      cost:  2990,
      advantages: [
        'Доступ ко всем текстовым рекомендациям',
        'Доступ ко всем аудио рекомендациям',
        'Доступ к медитациям',
        'Доступ ко всей аналитике состояний',
        'Хранение всех данных на вашем телефоне'
      ]);
}