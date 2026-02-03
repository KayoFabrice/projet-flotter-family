import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/cadence_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contact_history_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contact_detail_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contacts_provider.dart';
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
  test('ContactDetailProvider updates contact', () async {
    final now = DateTime(2026, 1, 10).toUtc().toIso8601String();
    final repository = FakeContactsRepository(
      initial: [
        Contact(
          id: '1',
          displayName: 'Alex',
          circle: ContactCircle.proches,
          createdAt: now,
        ),
      ],
    );
    final cadenceRepository = FakeCadenceRepository({
      ContactCircle.proches: 7,
      ContactCircle.amis: 21,
    });
    final historyDate = DateTime(2026, 1, 9).toUtc();
    final historyRepository = FakeContactHistoryRepository({
      '1': [
        ContactHistoryEntry(
          id: 1,
          contactId: '1',
          actionType: 'message',
          occurredAt: historyDate.toIso8601String(),
        ),
      ],
    });

    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(repository),
        cadenceRepositoryProvider.overrideWithValue(cadenceRepository),
        contactHistoryRepositoryProvider.overrideWithValue(historyRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(contactDetailProvider('1').future);

    final updated = await container
        .read(contactDetailProvider('1').notifier)
        .updateContact(
          displayName: 'Alexandre',
          circle: ContactCircle.amis,
        );

    expect(updated, isTrue);
    final state = container.read(contactDetailProvider('1')).value;
    expect(state, isNotNull);
    expect(state!.contact.displayName, 'Alexandre');
    expect(state.contact.circle, ContactCircle.amis);
    expect(state.cadenceDays, 21);
    expect(state.recentHistory.length, 1);
    expect(
      state.nextSuggestedAt,
      historyDate.add(const Duration(days: 21)),
    );
  });

  test('ContactDetailProvider deletion refreshes contacts list', () async {
    final now = DateTime(2026, 1, 10).toUtc().toIso8601String();
    final repository = FakeContactsRepository(
      initial: [
        Contact(
          id: '1',
          displayName: 'Alex',
          circle: ContactCircle.proches,
          createdAt: now,
        ),
      ],
    );
    final cadenceRepository = FakeCadenceRepository({
      ContactCircle.proches: 7,
      ContactCircle.amis: 21,
    });
    final historyRepository = FakeContactHistoryRepository({
      '1': [
        ContactHistoryEntry(
          id: 1,
          contactId: '1',
          actionType: 'call',
          occurredAt: DateTime(2026, 1, 8).toUtc().toIso8601String(),
        ),
      ],
    });

    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(repository),
        contactsDebounceDurationProvider.overrideWithValue(Duration.zero),
        cadenceRepositoryProvider.overrideWithValue(cadenceRepository),
        contactHistoryRepositoryProvider.overrideWithValue(historyRepository),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(contactsProvider.future);
    expect(initial.allContacts.length, 1);

    await container.read(contactDetailProvider('1').future);
    final deleted =
        await container.read(contactDetailProvider('1').notifier).deleteContact();
    expect(deleted, isTrue);

    final refreshed = container.read(contactsProvider).value;
    expect(refreshed, isNotNull);
    expect(refreshed!.allContacts, isEmpty);
  });

  test('ContactDetailProvider updates circle and keeps history intact', () async {
    final now = DateTime(2026, 1, 10).toUtc().toIso8601String();
    final repository = FakeContactsRepository(
      initial: [
        Contact(
          id: '1',
          displayName: 'Alex',
          circle: ContactCircle.proches,
          createdAt: now,
        ),
      ],
    );
    final cadenceRepository = FakeCadenceRepository({
      ContactCircle.proches: 7,
      ContactCircle.amis: 21,
    });
    final historyDate = DateTime(2026, 1, 7).toUtc();
    final historyEntry = ContactHistoryEntry(
      id: 2,
      contactId: '1',
      actionType: 'message',
      occurredAt: historyDate.toIso8601String(),
    );
    final historyRepository = FakeContactHistoryRepository({
      '1': [historyEntry],
    });

    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(repository),
        cadenceRepositoryProvider.overrideWithValue(cadenceRepository),
        contactHistoryRepositoryProvider.overrideWithValue(historyRepository),
      ],
    );
    addTearDown(container.dispose);

    await container.read(contactDetailProvider('1').future);

    final updated = await container
        .read(contactDetailProvider('1').notifier)
        .updateContactCircle(ContactCircle.amis);

    expect(updated, isTrue);
    final state = container.read(contactDetailProvider('1')).value;
    expect(state, isNotNull);
    expect(state!.contact.circle, ContactCircle.amis);
    expect(state.cadenceDays, 21);
    expect(state.recentHistory, [historyEntry]);
    expect(
      state.nextSuggestedAt,
      historyDate.add(const Duration(days: 21)),
    );
  });
}
