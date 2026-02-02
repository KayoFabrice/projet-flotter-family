import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contact_detail_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contacts_provider.dart';
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

    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(repository),
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

    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(repository),
        contactsDebounceDurationProvider.overrideWithValue(Duration.zero),
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
}
