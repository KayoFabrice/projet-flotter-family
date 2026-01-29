import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_import_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contacts_import_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/imported_contact.dart';

class FakeImportRepository implements ContactsImportRepository {
  FakeImportRepository(this.contacts);

  final List<ImportedContact> contacts;

  @override
  Future<List<ImportedContact>> fetchDeviceContacts() async {
    return contacts;
  }
}

class FakeContactsRepository implements ContactsRepository {
  final List<Contact> stored = [];

  @override
  Future<void> createImportedContacts(List<Contact> contacts) async {
    stored.addAll(contacts);
  }

  @override
  Future<void> createOnboardingContact(Contact contact) async {}

  @override
  Future<List<Contact>> fetchOnboardingContacts() async => const [];

  @override
  Future<int> countOnboardingContacts() async => 0;
}

void main() {
  test('ContactsImportService persists selected contacts with ISO UTC dates', () async {
    final importRepository = FakeImportRepository(const []);
    final localRepository = FakeContactsRepository();
    final service = ContactsImportService(importRepository, localRepository);

    await service.persistSelectedContacts(const [
      ImportedContact(id: 'a', displayName: 'Alex', phone: '0600000000'),
      ImportedContact(id: 'b', displayName: 'Sarah', email: 'sarah@test.com'),
    ]);

    expect(localRepository.stored.length, 2);
    expect(localRepository.stored.first.displayName, 'Alex');
    expect(localRepository.stored.first.phone, '0600000000');
    expect(localRepository.stored.first.email, isNull);
    expect(localRepository.stored.first.circle, ContactCircle.amis);
    final createdAt = DateTime.parse(localRepository.stored.first.createdAt);
    expect(createdAt.isUtc, isTrue);
  });
}
