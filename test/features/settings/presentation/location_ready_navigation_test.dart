import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/core/permissions/location_permission_service.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_step.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/onboarding_ready_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_step_provider.dart';
import 'package:projet_flutter_famille/features/settings/data/key_location_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/degraded_mode_service.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location_service.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/location_or_availability_page.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/degraded_mode_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/key_location_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/location_permission_provider.dart';

class FakeLocationPermissionService extends LocationPermissionService {
  FakeLocationPermissionService(this.status);

  final LocationPermissionStatus status;

  @override
  Future<LocationPermissionStatus> requestLocationPermission() async {
    return status;
  }
}

class FakeOnboardingService extends OnboardingService {
  FakeOnboardingService() : super(FakeOnboardingRepository());
}

class FakeOnboardingRepository implements OnboardingRepository {
  OnboardingStep step = OnboardingStep.locationOrAvailability;

  @override
  Future<OnboardingStep> fetchCurrentStep() async => step;

  @override
  Future<void> setCurrentStep(OnboardingStep step) async {
    this.step = step;
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
  testWidgets('Location CTA saves step and navigates to Ready', (tester) async {
    final permissionService =
        FakeLocationPermissionService(LocationPermissionStatus.granted);
    final keyLocationService = KeyLocationService(FakeKeyLocationRepository());
    final degradedService = DegradedModeService(FakeSettingsFlagsRepository());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          locationPermissionServiceProvider.overrideWithValue(permissionService),
          keyLocationServiceProvider.overrideWithValue(keyLocationService),
          degradedModeServiceProvider.overrideWithValue(degradedService),
          onboardingServiceProvider.overrideWithValue(FakeOnboardingService()),
        ],
        child: MaterialApp(
          routes: {
            OnboardingReadyPage.routeName: (_) => const OnboardingReadyPage(),
          },
          home: const LocationOrAvailabilityPage(),
        ),
      ),
    );

    await tester.tap(find.text('Activer la localisation'));
    await tester.pumpAndSettle();

    expect(find.text('Tout est pret !'), findsOneWidget);
  });
}
