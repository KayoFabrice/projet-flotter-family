import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/core/permissions/contacts_permission_service.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_service.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/import_contacts_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contacts_permission_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_step_provider.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_step.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/location_or_availability_page.dart';

class FakeContactsPermissionService extends ContactsPermissionService {
  FakeContactsPermissionService(this.status);

  final ContactsPermissionStatus status;

  @override
  Future<ContactsPermissionStatus> requestContactsPermission() async {
    return status;
  }
}

class FakeOnboardingService extends OnboardingService {
  FakeOnboardingService() : super(FakeOnboardingRepository());
}

class FakeOnboardingRepository implements OnboardingRepository {
  OnboardingStep step = OnboardingStep.importContacts;

  @override
  Future<OnboardingStep> fetchCurrentStep() async => step;

  @override
  Future<void> setCurrentStep(OnboardingStep step) async {
    this.step = step;
  }
}

void main() {
  testWidgets('ImportContactsPage shows snackbar when permission denied', (tester) async {
    final service = FakeContactsPermissionService(ContactsPermissionStatus.denied);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsPermissionServiceProvider.overrideWithValue(service),
          onboardingServiceProvider.overrideWithValue(FakeOnboardingService()),
        ],
        child: MaterialApp(
          routes: {
            LocationOrAvailabilityPage.routeName: (_) =>
                const LocationOrAvailabilityPage(),
          },
          home: const ImportContactsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Autoriser et importer'));
    await tester.pump();

    expect(
      find.text(
        "Mode degrade active. Vous pourrez activer l'import dans les reglages plus tard.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('ImportContactsPage offers settings when permission permanently denied', (tester) async {
    final service = FakeContactsPermissionService(
      ContactsPermissionStatus.permanentlyDenied,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsPermissionServiceProvider.overrideWithValue(service),
          onboardingServiceProvider.overrideWithValue(FakeOnboardingService()),
        ],
        child: MaterialApp(
          routes: {
            LocationOrAvailabilityPage.routeName: (_) =>
                const LocationOrAvailabilityPage(),
          },
          home: const ImportContactsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Autoriser et importer'));
    await tester.pump();

    expect(find.text('Ouvrir les reglages'), findsOneWidget);
  });
}
