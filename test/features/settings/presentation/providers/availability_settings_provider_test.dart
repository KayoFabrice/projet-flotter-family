import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/time_slot_preferences_repository.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/time_slot_settings_provider.dart';

class FakeTimeSlotPreferencesRepository
    implements TimeSlotPreferencesRepository {
  FakeTimeSlotPreferencesRepository({Set<String>? initial})
    : _stored = initial ?? <String>{};

  Set<String> _stored;

  @override
  Future<Set<String>> fetchSelectedPresetKeys() async => _stored;

  @override
  Future<void> saveSelectedPresetKeys(Set<String> keys) async {
    _stored = {...keys};
  }
}

void main() {
  test('TimeSlotSettingsProvider toggles and persists presets', () async {
    final repository = FakeTimeSlotPreferencesRepository();
    final container = ProviderContainer(
      overrides: [
        timeSlotPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(timeSlotSettingsProvider.future);
    expect(initial.isSelected('soiree'), isTrue);

    final notifier = container.read(timeSlotSettingsProvider.notifier);
    notifier.togglePreset('matinee');
    notifier.togglePreset('soiree');

    final saved = await notifier.persist();
    expect(saved, isTrue);
    expect(repository._stored.contains('soiree'), isFalse);
    expect(repository._stored.contains('matinee'), isTrue);
  });
}
