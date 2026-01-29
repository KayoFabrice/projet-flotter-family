import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/core/permissions/location_permission_service.dart';
import 'package:projet_flutter_famille/features/settings/data/key_location_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location_service.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/degraded_mode_service.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/location_or_availability_page.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/location_permission_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/key_location_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/degraded_mode_provider.dart';

class FakeLocationPermissionService extends LocationPermissionService {
  FakeLocationPermissionService(this.status);

  final LocationPermissionStatus status;
  bool openedSettings = false;

  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    return status;
  }

  @override
  Future<bool> openSettings() async {
    openedSettings = true;
    return true;
  }
}

class FakeKeyLocationRepository implements KeyLocationRepository {
  KeyLocation? stored;

  @override
  Future<KeyLocation?> fetchKeyLocation() async => stored;

  @override
  Future<void> saveKeyLocation(KeyLocation location) async {
    stored = location;
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
  testWidgets('Location CTA shows snackbar when permission denied', (tester) async {
    final service = FakeLocationPermissionService(LocationPermissionStatus.denied);
    final keyLocationService = KeyLocationService(FakeKeyLocationRepository());
    final settingsRepository = FakeSettingsFlagsRepository();
    final degradedService = DegradedModeService(settingsRepository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          locationPermissionServiceProvider.overrideWithValue(service),
          keyLocationServiceProvider.overrideWithValue(keyLocationService),
          degradedModeServiceProvider.overrideWithValue(degradedService),
        ],
        child: const MaterialApp(
          home: LocationOrAvailabilityPage(),
        ),
      ),
    );

    await tester.tap(find.text('Activer la localisation'));
    await tester.pump();

    expect(
      find.text(
        'Localisation refusee. Mode degrade actif (rappels moins contextuels).',
      ),
      findsOneWidget,
    );
    expect(settingsRepository.storage['mode_degrade'], isTrue);
  });

  testWidgets('Location CTA offers settings when permanently denied', (tester) async {
    final service =
        FakeLocationPermissionService(LocationPermissionStatus.permanentlyDenied);
    final keyLocationService = KeyLocationService(FakeKeyLocationRepository());
    final settingsRepository = FakeSettingsFlagsRepository();
    final degradedService = DegradedModeService(settingsRepository);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          locationPermissionServiceProvider.overrideWithValue(service),
          keyLocationServiceProvider.overrideWithValue(keyLocationService),
          degradedModeServiceProvider.overrideWithValue(degradedService),
        ],
        child: const MaterialApp(
          home: LocationOrAvailabilityPage(),
        ),
      ),
    );

    await tester.tap(find.text('Activer la localisation'));
    await tester.pump();

    expect(find.text('Ouvrir les reglages'), findsOneWidget);
    expect(settingsRepository.storage['mode_degrade'], isTrue);
  });
}
