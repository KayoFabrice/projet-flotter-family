import 'package:uuid/uuid.dart';

import '../data/contacts_import_repository.dart';
import '../data/contacts_repository.dart';
import 'contact.dart';
import 'contact_circle.dart';
import 'imported_contact.dart';

class ContactsImportService {
  ContactsImportService(this._importRepository, this._contactsRepository);

  final ContactsImportRepository _importRepository;
  final ContactsRepository _contactsRepository;

  Future<List<ImportedContact>> loadDeviceContacts() async {
    final contacts = await _importRepository.fetchDeviceContacts();
    final cleaned = contacts.where((contact) => contact.displayName.trim().isNotEmpty).toList();
    cleaned.sort((a, b) => a.displayName.compareTo(b.displayName));
    return cleaned;
  }

  Future<void> persistSelectedContacts(List<ImportedContact> contacts) async {
    if (contacts.isEmpty) {
      return;
    }
    final now = DateTime.now().toUtc();
    const uuid = Uuid();
    final mapped = <Contact>[];
    for (var index = 0; index < contacts.length; index++) {
      final imported = contacts[index];
      if (imported.displayName.trim().isEmpty) {
        continue;
      }
      mapped.add(
        Contact(
          id: uuid.v4(),
          displayName: imported.displayName,
          circle: ContactCircle.amis,
          createdAt: now.toIso8601String(),
          phone: imported.phone,
          email: imported.email,
        ),
      );
    }
    await _contactsRepository.createImportedContacts(mapped);
  }
}
