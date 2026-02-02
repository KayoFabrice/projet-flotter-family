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

  Future<List<Contact>> loadContacts() {
    return _repository.fetchContacts();
  }

  Future<List<Contact>> searchContacts(String query) {
    return _repository.searchContacts(query);
  }

  Future<Contact> loadContactById(String id) async {
    final contact = await _repository.fetchContactById(id);
    if (contact == null) {
      throw StateError('Contact introuvable');
    }
    return contact;
  }

  Future<Contact> createContact({
    required String displayName,
    required ContactCircle circle,
    String? phone,
    String? email,
  }) async {
    final now = DateTime.now();
    final contact = Contact(
      id: const Uuid().v4(),
      displayName: displayName,
      circle: circle,
      createdAt: now.toUtc().toIso8601String(),
      phone: phone,
      email: email,
    );
    await _repository.createContact(contact);
    return contact;
  }

  Future<Contact> updateContact({
    required String id,
    required String displayName,
    required ContactCircle circle,
    String? phone,
    String? email,
  }) async {
    final existing = await loadContactById(id);
    final updated = Contact(
      id: existing.id,
      displayName: displayName,
      circle: circle,
      createdAt: existing.createdAt,
      phone: phone,
      email: email,
    );
    await _repository.updateContact(updated);
    return updated;
  }

  Future<void> deleteContact(String id) {
    return _repository.deleteContact(id);
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
