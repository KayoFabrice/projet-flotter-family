import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/circles_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_step.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/circles_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/first_contacts_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_step_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_contacts_provider.dart';
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

class FakeContactsRepository implements ContactsRepository {
  final List<Contact> _stored = [];

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

void main() {
  testWidgets('CirclesPage shows four circles and CTA', (tester) async {
    final fakeRepository = FakeCirclesRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          circlesRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MaterialApp(home: CirclesPage()),
      ),
    );

    await tester.pump();

    final gridFinder = find.byType(Scrollable);

    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Freres & Soeurs'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Grand-parents'), 200, scrollable: gridFinder);
    expect(find.text('Grand-parents'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Amis proches'), 200, scrollable: gridFinder);
    expect(find.text('Amis proches'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
  });

  testWidgets('CirclesPage shows message when continuing without selection', (tester) async {
    final fakeRepository = FakeCirclesRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          circlesRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MaterialApp(home: CirclesPage()),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('Continuer'));
    await tester.pump();

    expect(
      find.text('Selectionnez au moins un cercle pour continuer.'),
      findsOneWidget,
    );
  });

  testWidgets('CirclesPage persists selection and navigates to first contacts', (tester) async {
    final fakeRepository = FakeCirclesRepository();
    final fakeContactsRepository = FakeContactsRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          circlesRepositoryProvider.overrideWithValue(fakeRepository),
          onboardingRepositoryProvider.overrideWithValue(
            FakeOnboardingRepository(OnboardingStep.circles),
          ),
          contactsRepositoryProvider.overrideWithValue(fakeContactsRepository),
        ],
        child: MaterialApp(
          routes: {
            FirstContactsPage.routeName: (_) => const FirstContactsPage(),
          },
          home: const CirclesPage(),
        ),
      ),
    );

    await tester.pump();

    await tester.tap(find.text('Parents'));
    await tester.pump();

    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    expect(find.text('Premiers contacts'), findsOneWidget);
    expect(fakeRepository.fetchSelectedCircles(), completion([ContactCircle.proches]));
  });
}
