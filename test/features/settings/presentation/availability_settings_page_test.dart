import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/time_slot_preferences_repository.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/availability_settings_page.dart';
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
  testWidgets('Plages horaires toggles presets', (tester) async {
    final repository = FakeTimeSlotPreferencesRepository();
    final container = ProviderContainer(
      overrides: [
        timeSlotPreferencesRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: AvailabilitySettingsPage()),
      ),
    );

    await tester.pumpAndSettle();

    final initialState = container.read(timeSlotSettingsProvider).value;
    expect(initialState?.isSelected('soiree'), isTrue);

    await tester.tap(find.text('Matinee'));
    await tester.pumpAndSettle();

    final updatedState = container.read(timeSlotSettingsProvider).value;
    expect(updatedState?.isSelected('matinee'), isTrue);
  });
}
