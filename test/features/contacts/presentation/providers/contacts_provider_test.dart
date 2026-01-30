import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contacts_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_contacts_provider.dart';

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

void main() {
  test('ContactsProvider loads contacts and filters by name', () async {
    final now = DateTime(2026, 1, 10).toUtc().toIso8601String();
    final repository = FakeContactsRepository(
      initial: [
        Contact(
          id: '1',
          displayName: 'Sarah',
          circle: ContactCircle.proches,
          createdAt: now,
        ),
        Contact(
          id: '2',
          displayName: 'Thomas',
          circle: ContactCircle.amis,
          createdAt: now,
        ),
        Contact(
          id: '3',
          displayName: 'ALICE',
          circle: ContactCircle.eloignes,
          createdAt: now,
        ),
      ],
    );

    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(repository),
        contactsDebounceDurationProvider.overrideWithValue(Duration.zero),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(contactsProvider.future);
    expect(initial.allContacts.length, 3);

    container.read(contactsProvider.notifier).updateQuery('sa');

    final filtered = container.read(contactsProvider).value;
    expect(filtered, isNotNull);
    expect(filtered!.filteredContacts.length, 1);
    expect(filtered.filteredContacts.first.displayName, 'Sarah');

    container.read(contactsProvider.notifier).updateQuery('ali');
    final filteredUpper = container.read(contactsProvider).value;
    expect(filteredUpper, isNotNull);
    expect(filteredUpper!.filteredContacts.length, 1);
    expect(filteredUpper.filteredContacts.first.displayName, 'ALICE');
  });
}
