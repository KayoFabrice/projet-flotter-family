import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/import_contacts_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contacts_import_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_step_provider.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_step.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_service.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_repository.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/location_or_availability_page.dart';

void main() {
  testWidgets('ImportContactsContent shows explainer and CTAs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ImportContactsContent(
            state: ContactsImportState.initial(),
            onImportPressed: () {},
            onSkipPressed: () {},
            onQueryChanged: (_) {},
            onToggleSelection: (_) {},
            onConfirmSelection: () {},
          ),
        ),
      ),
    );

    expect(find.text('Simplifiez-vous la vie'), findsOneWidget);
    expect(
      find.text(
        'Importez vos contacts pour construire votre agenda relationnel sans effort manuel.',
      ),
      findsOneWidget,
    );
    expect(find.text("Nous n'ecrirons jamais a votre place."), findsOneWidget);
    expect(find.text('Autoriser et importer'), findsOneWidget);
    expect(find.text('Continuer sans importer'), findsOneWidget);
  });

  testWidgets('ImportContactsPage shows degraded message when skipping', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
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

    await tester.tap(find.text('Continuer sans importer'));
    await tester.pump();

    expect(
      find.text(
        "Mode degrade active. Vous pourrez activer l'import dans les reglages plus tard.",
      ),
      findsOneWidget,
    );
    await tester.pumpAndSettle();
    expect(find.text('Le bon moment, au bon endroit'), findsOneWidget);
  });
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
