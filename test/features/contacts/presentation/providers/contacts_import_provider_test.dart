import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contacts_import_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/imported_contact.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_import_repository.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contacts_import_provider.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';

class FakeContactsImportService extends ContactsImportService {
  FakeContactsImportService(this.contacts)
      : super(FakeContactsImportRepository(), FakeContactsRepository());

  final List<ImportedContact> contacts;
  final List<List<ImportedContact>> persistedSelections = [];

  @override
  Future<List<ImportedContact>> loadDeviceContacts() async {
    return contacts;
  }

  @override
  Future<void> persistSelectedContacts(List<ImportedContact> contacts) async {
    persistedSelections.add(contacts);
  }
}

class FakeContactsImportRepository implements ContactsImportRepository {
  @override
  Future<List<ImportedContact>> fetchDeviceContacts() async {
    return const [];
  }
}

class FakeContactsRepository implements ContactsRepository {
  @override
  Future<void> createContact(Contact contact) async {}

  @override
  Future<List<Contact>> fetchContacts() async => const [];

  @override
  Future<List<Contact>> searchContacts(String query) async => const [];

  @override
  Future<void> createImportedContacts(List<Contact> contacts) async {}

  @override
  Future<void> createOnboardingContact(Contact contact) async {}

  @override
  Future<List<Contact>> fetchOnboardingContacts() async => const [];

  @override
  Future<int> countOnboardingContacts() async => 0;
}

void main() {
  test('ContactsImportProvider loads and filters contacts', () async {
    final service = FakeContactsImportService(const [
      ImportedContact(id: '1', displayName: 'Alex'),
      ImportedContact(id: '2', displayName: 'Sarah'),
    ]);

    final container = ProviderContainer(
      overrides: [
        contactsImportServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(contactsImportProvider.notifier).loadContacts();

    final loadedState = container.read(contactsImportProvider).value;
    expect(loadedState, isNotNull);
    expect(loadedState!.contacts.length, 2);

    container.read(contactsImportProvider.notifier).updateQuery('sa');
    final filtered = container.read(contactsImportProvider).value!.filteredContacts;
    expect(filtered.length, 1);
    expect(filtered.first.displayName, 'Sarah');
  });

  test('ContactsImportProvider toggles selection', () async {
    final service = FakeContactsImportService(const [
      ImportedContact(id: '1', displayName: 'Alex'),
    ]);

    final container = ProviderContainer(
      overrides: [
        contactsImportServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(contactsImportProvider.notifier).loadContacts();
    container.read(contactsImportProvider.notifier).toggleSelection('1');

    final state = container.read(contactsImportProvider).value!;
    expect(state.selectedIds.contains('1'), isTrue);

    container.read(contactsImportProvider.notifier).toggleSelection('1');
    final updated = container.read(contactsImportProvider).value!;
    expect(updated.selectedIds.contains('1'), isFalse);
  });

  test('ContactsImportProvider persists partial selection', () async {
    final service = FakeContactsImportService(List.generate(
      10,
      (index) => ImportedContact(id: '$index', displayName: 'Contact $index'),
    ));

    final container = ProviderContainer(
      overrides: [
        contactsImportServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(container.dispose);

    await container.read(contactsImportProvider.notifier).loadContacts();
    container.read(contactsImportProvider.notifier).toggleSelection('1');
    container.read(contactsImportProvider.notifier).toggleSelection('8');

    final saved = await container.read(contactsImportProvider.notifier).persistSelection();
    expect(saved, isTrue);
    expect(service.persistedSelections.length, 1);
    expect(service.persistedSelections.first.length, 2);
  });
}
