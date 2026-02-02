import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../data/time_slot_preferences_repository.dart';
import '../../domain/time_slot_preset.dart';

final timeSlotPreferencesRepositoryProvider =
    Provider<TimeSlotPreferencesRepository>((ref) {
      return TimeSlotPreferencesRepositoryImpl(AppDatabase.instance);
    });

final timeSlotSettingsProvider =
    AsyncNotifierProvider<TimeSlotSettingsNotifier, TimeSlotSelectionState>(
      TimeSlotSettingsNotifier.new,
    );

class TimeSlotSettingsNotifier extends AsyncNotifier<TimeSlotSelectionState> {
  @override
  Future<TimeSlotSelectionState> build() async {
    final repository = ref.read(timeSlotPreferencesRepositoryProvider);
    final selected = await repository.fetchSelectedPresetKeys();
    final defaults = TimeSlotPreset.presets;
    final initialSelected = selected.isEmpty ? {'soiree'} : selected;
    return TimeSlotSelectionState(
      presets: defaults,
      selectedKeys: initialSelected,
    );
  }

  void togglePreset(String key) {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(current.toggle(key));
  }

  Future<bool> persist() async {
    final repository = ref.read(timeSlotPreferencesRepositoryProvider);
    final current = state.value;
    if (current == null) {
      return false;
    }
    try {
      await repository.saveSelectedPresetKeys(current.selectedKeys);
      return true;
    } catch (_) {
      return false;
    }
  }
}
