import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_window.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/location_or_availability_page.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/availability_provider.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/degraded_mode_service.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/degraded_mode_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/widgets/availability_time_range_editor.dart';

class FakeAvailabilityNotifier extends AvailabilityNotifier {
  @override
  Future<List<AvailabilityWindow>> build() async {
    return const [];
  }
}

class FakeSettingsFlagsRepository implements SettingsFlagsRepository {
  final Map<String, bool> storage = {};

  @override
  Future<bool?> fetchBool(String key) async => storage[key];

  @override
  Future<void> saveBool(String key, bool value) async {
    storage[key] = value;
  }
}

void main() {
  testWidgets('Manual availability flow opens editor after permission denied', (tester) async {
    final settingsRepository = FakeSettingsFlagsRepository();
    final degradedService = DegradedModeService(settingsRepository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          availabilityProvider.overrideWith(FakeAvailabilityNotifier.new),
          degradedModeServiceProvider.overrideWithValue(degradedService),
        ],
        child: const MaterialApp(
          home: LocationOrAvailabilityPage(),
        ),
      ),
    );

    await tester.tap(find.text('Choisir des horaires fixes'));
    await tester.pumpAndSettle();

    expect(find.byType(AvailabilityTimeRangeEditor), findsOneWidget);
    expect(settingsRepository.storage['mode_degrade'], isTrue);
  });
}
