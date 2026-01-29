import 'package:uuid/uuid.dart';

import '../data/contacts_repository.dart';
import 'contact.dart';
import 'contact_circle.dart';
import 'onboarding_contacts_limit_exception.dart';

class ContactsService {
  ContactsService(this._repository);

  final ContactsRepository _repository;

  Future<List<Contact>> loadOnboardingContacts() {
    return _repository.fetchOnboardingContacts();
  }

  Future<Contact> createOnboardingContact({
    required String displayName,
    required ContactCircle circle,
  }) async {
    final existingCount = await _repository.countOnboardingContacts();
    if (existingCount >= 3) {
      throw const OnboardingContactsLimitException();
    }
    final now = DateTime.now();
    final contact = Contact(
      id: const Uuid().v4(),
      displayName: displayName,
      circle: circle,
      createdAt: now.toUtc().toIso8601String(),
    );
    await _repository.createOnboardingContact(contact);
    return contact;
  }
}
