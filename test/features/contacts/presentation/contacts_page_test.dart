import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/contacts_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/contact_edit_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_contacts_provider.dart';

class FakeContactsRepository implements ContactsRepository {
  FakeContactsRepository(this._contacts);

  final List<Contact> _contacts;

  @override
  Future<List<Contact>> fetchContacts() async => List.unmodifiable(_contacts);

  @override
  Future<List<Contact>> searchContacts(String query) async => _contacts
      .where(
        (contact) => contact.displayName.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();

  @override
  Future<List<Contact>> fetchOnboardingContacts() async => List.unmodifiable(_contacts);

  @override
  Future<void> createContact(Contact contact) async {
    _contacts.add(contact);
  }

  @override
  Future<void> createOnboardingContact(Contact contact) async {
    _contacts.add(contact);
  }

  @override
  Future<void> createImportedContacts(List<Contact> contacts) async {
    _contacts.addAll(contacts);
  }

  @override
  Future<int> countOnboardingContacts() async => _contacts.length;
}

void main() {
  testWidgets('ContactsPage shows search field and category sections', (tester) async {
    final now = DateTime(2026, 1, 10).toUtc().toIso8601String();
    final repository = FakeContactsRepository([
      Contact(
        id: '1',
        displayName: 'Sarah',
        circle: ContactCircle.proches,
        createdAt: now,
      ),
      Contact(
        id: '2',
        displayName: 'Leo',
        circle: ContactCircle.eloignes,
        createdAt: now,
      ),
      Contact(
        id: '3',
        displayName: 'Emma',
        circle: ContactCircle.partenaire,
        createdAt: now,
      ),
      Contact(
        id: '4',
        displayName: 'Mika',
        circle: ContactCircle.amis,
        createdAt: now,
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repository),
          contactsDebounceDurationProvider.overrideWithValue(Duration.zero),
        ],
        child: MaterialApp(
          routes: {
            ContactEditPage.routeName: (_) => const ContactEditPage(),
          },
          home: const ContactsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Mes Proches'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('PROCHES'), findsOneWidget);
    expect(find.text('ELOIGNES'), findsOneWidget);
    expect(find.text('PARTENAIRE'), findsOneWidget);
    expect(find.text('AMIS'), findsOneWidget);
    expect(find.text('Sarah'), findsOneWidget);
    expect(find.text('Leo'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'sa');
    await tester.pump();

    expect(find.text('Sarah'), findsOneWidget);
    expect(find.text('Leo'), findsNothing);
  });

  testWidgets('ContactsPage shows empty state and CTA', (tester) async {
    final repository = FakeContactsRepository([]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(repository),
          contactsDebounceDurationProvider.overrideWithValue(Duration.zero),
        ],
        child: MaterialApp(
          routes: {
            ContactEditPage.routeName: (_) => const ContactEditPage(),
          },
          home: const ContactsPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Aucun proche pour le moment.'), findsOneWidget);
    expect(find.text('Ajouter un proche'), findsOneWidget);
  });
}
