import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/circles_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_step.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/cadence_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/first_contacts_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_cadence_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_contacts_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_step_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/selected_circles_provider.dart';

class FakeCirclesRepository implements CirclesRepository {
  FakeCirclesRepository({List<ContactCircle>? initial})
      : _stored = List<ContactCircle>.from(initial ?? const []);

  List<ContactCircle> _stored;

  @override
  Future<List<ContactCircle>> fetchSelectedCircles() async => List.unmodifiable(_stored);

  @override
  Future<void> saveSelectedCircles(List<ContactCircle> circles) async {
    _stored = List<ContactCircle>.from(circles);
  }
}

class FakeContactsRepository implements ContactsRepository {
  FakeContactsRepository({List<Contact>? initial})
      : _stored = List<Contact>.from(initial ?? const []);

  final List<Contact> _stored;

  @override
  Future<List<Contact>> fetchContacts() async => List.unmodifiable(_stored);

  @override
  Future<List<Contact>> searchContacts(String query) async => _stored
      .where(
        (contact) => contact.displayName.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();

  @override
  Future<List<Contact>> fetchOnboardingContacts() async => List.unmodifiable(_stored);

  @override
  Future<void> createContact(Contact contact) async {
    _stored.add(contact);
  }

  @override
  Future<void> createOnboardingContact(Contact contact) async {
    _stored.add(contact);
  }

  @override
  Future<void> createImportedContacts(List<Contact> contacts) async {
    _stored.addAll(contacts);
  }

  @override
  Future<int> countOnboardingContacts() async => _stored.length;
}

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository(this._step);

  OnboardingStep _step;

  @override
  Future<OnboardingStep> fetchCurrentStep() async => _step;

  @override
  Future<void> setCurrentStep(OnboardingStep step) async {
    _step = step;
  }
}

class FakeOnboardingCadenceNotifier extends OnboardingCadenceNotifier {
  @override
  Future<List<ContactCadence>> build() async {
    return const [
      ContactCadence(circle: ContactCircle.proches, cadenceDays: 7),
    ];
  }
}

void main() {
  testWidgets('FirstContactsPage shows message when continuing without contacts', (tester) async {
    final circlesRepository = FakeCirclesRepository(
      initial: const [ContactCircle.proches],
    );
    final contactsRepository = FakeContactsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          circlesRepositoryProvider.overrideWithValue(circlesRepository),
          contactsRepositoryProvider.overrideWithValue(contactsRepository),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(OnboardingStep.firstContacts),
          ),
        ],
        child: const MaterialApp(
          home: FirstContactsPage(),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('Continuer'));
    await tester.pump();

    expect(find.text('Ajoutez au moins un proche.'), findsOneWidget);
    expect(find.text('Ajouter'), findsOneWidget);
  });

  testWidgets('FirstContactsPage shows all circle options even with one selected', (tester) async {
    final circlesRepository = FakeCirclesRepository(
      initial: const [ContactCircle.proches],
    );
    final contactsRepository = FakeContactsRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          circlesRepositoryProvider.overrideWithValue(circlesRepository),
          contactsRepositoryProvider.overrideWithValue(contactsRepository),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(OnboardingStep.firstContacts),
          ),
        ],
        child: const MaterialApp(
          home: FirstContactsPage(),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('Ajouter un proche'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<ContactCircle>));
    await tester.pumpAndSettle();

    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Freres & Soeurs'), findsOneWidget);
    expect(find.text('Grand-parents'), findsOneWidget);
    expect(find.text('Amis proches'), findsOneWidget);
  });

  testWidgets('FirstContactsPage saves step and navigates to cadence', (tester) async {
    final circlesRepository = FakeCirclesRepository(
      initial: const [ContactCircle.proches],
    );
    final onboardingRepository = FakeOnboardingRepository(OnboardingStep.firstContacts);
    final contactsRepository = FakeContactsRepository(
      initial: [
        Contact(
          id: '1',
          displayName: 'Alex',
          circle: ContactCircle.proches,
          createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          circlesRepositoryProvider.overrideWithValue(circlesRepository),
          contactsRepositoryProvider.overrideWithValue(contactsRepository),
          onboardingRepositoryProvider.overrideWithValue(onboardingRepository),
          onboardingCadenceProvider.overrideWith(FakeOnboardingCadenceNotifier.new),
        ],
        child: MaterialApp(
          routes: {
            CadencePage.routeName: (_) => const CadencePage(),
          },
          home: const FirstContactsPage(),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Quel est le bon rythme ?'), findsOneWidget);
    expect(onboardingRepository.fetchCurrentStep(), completion(OnboardingStep.cadence));
  });
}
