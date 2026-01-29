import 'package:flutter_contacts/flutter_contacts.dart';

import '../domain/imported_contact.dart';

abstract class ContactsImportRepository {
  Future<List<ImportedContact>> fetchDeviceContacts();
}

class ContactsImportRepositoryImpl implements ContactsImportRepository {
  @override
  Future<List<ImportedContact>> fetchDeviceContacts() async {
    final contacts = await FlutterContacts.getContacts(
      withProperties: true,
    );

    return contacts
        .map(
          (contact) => ImportedContact(
            id: contact.id,
            displayName: contact.displayName,
            phone: contact.phones.isNotEmpty ? contact.phones.first.number : null,
            email: contact.emails.isNotEmpty ? contact.emails.first.address : null,
          ),
        )
        .toList();
  }
}
