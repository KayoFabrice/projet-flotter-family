import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/cadence_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contact_history_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/contact_edit_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contact_detail_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_cadence_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_contacts_provider.dart';

class FakeContactsRepository implements ContactsRepository {
  FakeContactsRepository({List<Contact>? initial})
      : _stored = List<Contact>.from(initial ?? const []);

  final List<Contact> _stored;

  @override
  Future<Contact?> fetchContactById(String id) async {
    return _stored.cast<Contact?>().firstWhere(
          (contact) => contact?.id == id,
          orElse: () => null,
        );
  }

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
  Future<void> updateContact(Contact contact) async {
    final index = _stored.indexWhere((item) => item.id == contact.id);
    if (index == -1) {
      return;
    }
    _stored[index] = contact;
  }

  @override
  Future<void> deleteContact(String id) async {
    _stored.removeWhere((contact) => contact.id == id);
  }

  @override
  Future<int> countOnboardingContacts() async => _stored.length;
}

class FakeCadenceRepository implements CadenceRepository {
  FakeCadenceRepository(this._stored);

  final Map<ContactCircle, int> _stored;

  @override
  Future<Map<ContactCircle, int>> fetchCadences() async => Map.of(_stored);

  @override
  Future<void> saveCadences(List<ContactCadence> cadences) async {
    _stored
      ..clear()
      ..addEntries(
        cadences.map(
          (cadence) => MapEntry(cadence.circle, cadence.cadenceDays),
        ),
      );
  }
}

class FakeContactHistoryRepository implements ContactHistoryRepository {
  FakeContactHistoryRepository(this._stored);

  final Map<String, List<ContactHistoryEntry>> _stored;

  @override
  Future<List<ContactHistoryEntry>> fetchRecentHistory(
    String contactId, {
    int limit = 5,
  }) async {
    return List.unmodifiable(_stored[contactId] ?? const []);
  }

  @override
  Future<int> addHistoryEntry({
    required String contactId,
    required String actionType,
    required String occurredAt,
  }) async {
    return 1;
  }
}

void main() {
  testWidgets('ContactEditPage shows inline validation errors', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ContactEditPage(),
        ),
      ),
    );

    expect(find.text('Enregistrer'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    final submitFinder = find.text('Enregistrer');
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Nom requis'), findsOneWidget);
    expect(find.text('Relation requise'), findsOneWidget);
  });

  testWidgets('ContactEditPage shows delete CTA in edit mode', (tester) async {
    final contact = Contact(
      id: '1',
      displayName: 'Maman',
      circle: ContactCircle.proches,
      createdAt: DateTime(2026, 1, 10).toUtc().toIso8601String(),
      phone: '+33 6 12 34 56 78',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(initial: [contact]),
          ),
          cadenceRepositoryProvider.overrideWithValue(
            FakeCadenceRepository({
              ContactCircle.proches: 7,
              ContactCircle.eloignes: 30,
              ContactCircle.partenaire: 14,
              ContactCircle.amis: 14,
            }),
          ),
          contactHistoryRepositoryProvider.overrideWithValue(
            FakeContactHistoryRepository(const {}),
          ),
        ],
        child: MaterialApp(
          home: ContactEditPage(
            args: const ContactEditArgs.edit(contactId: '1'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Modifier le contact'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);
    expect(find.text('Supprimer ce contact'), findsOneWidget);
    expect(find.text('Maman'), findsOneWidget);
  });

  testWidgets('ContactEditPage validates name in edit mode', (tester) async {
    final contact = Contact(
      id: '1',
      displayName: 'Maman',
      circle: ContactCircle.proches,
      createdAt: DateTime(2026, 1, 10).toUtc().toIso8601String(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(initial: [contact]),
          ),
          cadenceRepositoryProvider.overrideWithValue(
            FakeCadenceRepository({
              ContactCircle.proches: 7,
              ContactCircle.eloignes: 30,
              ContactCircle.partenaire: 14,
              ContactCircle.amis: 14,
            }),
          ),
          contactHistoryRepositoryProvider.overrideWithValue(
            FakeContactHistoryRepository(const {}),
          ),
        ],
        child: MaterialApp(
          home: ContactEditPage(
            args: const ContactEditArgs.edit(contactId: '1'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump();

    final submitFinder = find.text('Enregistrer');
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Nom requis'), findsOneWidget);
  });

  testWidgets('ContactEditPage shows delete confirmation dialog', (tester) async {
    final contact = Contact(
      id: '1',
      displayName: 'Maman',
      circle: ContactCircle.proches,
      createdAt: DateTime(2026, 1, 10).toUtc().toIso8601String(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contactsRepositoryProvider.overrideWithValue(
            FakeContactsRepository(initial: [contact]),
          ),
          cadenceRepositoryProvider.overrideWithValue(
            FakeCadenceRepository({
              ContactCircle.proches: 7,
              ContactCircle.eloignes: 30,
              ContactCircle.partenaire: 14,
              ContactCircle.amis: 14,
            }),
          ),
          contactHistoryRepositoryProvider.overrideWithValue(
            FakeContactHistoryRepository(const {}),
          ),
        ],
        child: MaterialApp(
          home: ContactEditPage(
            args: const ContactEditArgs.edit(contactId: '1'),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final deleteFinder = find.text('Supprimer ce contact');
    await tester.ensureVisible(deleteFinder);
    await tester.tap(deleteFinder, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Supprimer ce contact ?'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);
    expect(find.text('Supprimer'), findsOneWidget);
  });
}
