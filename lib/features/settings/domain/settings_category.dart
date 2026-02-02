class SettingsCategory {
  const SettingsCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
  });

  final String id;
  final String name;
  final String description;
  final bool isActive;

  SettingsCategory copyWith({
    String? id,
    String? name,
    String? description,
    bool? isActive,
  }) {
    return SettingsCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }

  static const defaults = <SettingsCategory>[
    SettingsCategory(
      id: 'famille',
      name: 'Famille',
      description: 'Parents, freres, soeurs, famille proche',
      isActive: true,
    ),
    SettingsCategory(
      id: 'amis_proches',
      name: 'Amis proches',
      description: 'Ceux a qui vous parlez souvent',
      isActive: true,
    ),
    SettingsCategory(
      id: 'autres',
      name: 'Autres',
      description: 'Connaissances, collegues, amis lointains',
      isActive: true,
    ),
  ];
}
