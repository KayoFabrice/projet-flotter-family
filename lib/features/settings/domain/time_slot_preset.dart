class TimeSlotPreset {
  const TimeSlotPreset({
    required this.key,
    required this.label,
    required this.subLabel,
    this.startMinute,
    this.endMinute,
  });

  final String key;
  final String label;
  final String subLabel;
  final int? startMinute;
  final int? endMinute;

  static const presets = <TimeSlotPreset>[
    TimeSlotPreset(
      key: 'matinee',
      label: 'Matinee',
      subLabel: '08:00 - 10:00',
      startMinute: 8 * 60,
      endMinute: 10 * 60,
    ),
    TimeSlotPreset(
      key: 'pause_dejeuner',
      label: 'Pause dejeuner',
      subLabel: '12:00 - 14:00',
      startMinute: 12 * 60,
      endMinute: 14 * 60,
    ),
    TimeSlotPreset(
      key: 'fin_apres_midi',
      label: "Fin d'apres-midi",
      subLabel: '16:00 - 18:00',
      startMinute: 16 * 60,
      endMinute: 18 * 60,
    ),
    TimeSlotPreset(
      key: 'soiree',
      label: 'Soiree',
      subLabel: '18:00 - 20:00',
      startMinute: 18 * 60,
      endMinute: 20 * 60,
    ),
    TimeSlotPreset(
      key: 'week_end',
      label: 'Week-end uniquement',
      subLabel: 'Samedi & Dimanche',
    ),
  ];
}

class TimeSlotSelectionState {
  const TimeSlotSelectionState({
    required this.presets,
    required this.selectedKeys,
  });

  final List<TimeSlotPreset> presets;
  final Set<String> selectedKeys;

  bool isSelected(String key) => selectedKeys.contains(key);

  TimeSlotSelectionState toggle(String key) {
    final updated = <String>{...selectedKeys};
    if (updated.contains(key)) {
      updated.remove(key);
    } else {
      updated.add(key);
    }
    if (updated.isEmpty) {
      updated.add(key);
    }
    return TimeSlotSelectionState(presets: presets, selectedKeys: updated);
  }
}
