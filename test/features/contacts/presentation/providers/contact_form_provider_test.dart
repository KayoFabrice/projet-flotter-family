import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/contact_form_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_contacts_provider.dart';

class FakeContactsRepository implements ContactsRepository {
  final List<Contact> stored = [];

  @override
  Future<Contact?> fetchContactById(String id) async {
    return stored.cast<Contact?>().firstWhere(
          (contact) => contact?.id == id,
          orElse: () => null,
        );
  }

  @override
  Future<void> createContact(Contact contact) async {
    stored.add(contact);
  }

  @override
  Future<void> createImportedContacts(List<Contact> contacts) async {
    stored.addAll(contacts);
  }

  @override
  Future<void> createOnboardingContact(Contact contact) async {
    stored.add(contact);
  }

  @override
  Future<List<Contact>> fetchContacts() async => List.unmodifiable(stored);

  @override
  Future<List<Contact>> fetchOnboardingContacts() async =>
      List.unmodifiable(stored);

  @override
  Future<List<Contact>> searchContacts(String query) async => stored
      .where(
        (contact) =>
            contact.displayName.toLowerCase().contains(query.toLowerCase()),
      )
      .toList();

  @override
  Future<void> updateContact(Contact contact) async {
    final index = stored.indexWhere((item) => item.id == contact.id);
    if (index == -1) {
      return;
    }
    stored[index] = contact;
  }

  @override
  Future<void> deleteContact(String id) async {
    stored.removeWhere((contact) => contact.id == id);
  }

  @override
  Future<int> countOnboardingContacts() async => stored.length;
}

void main() {
  test('ContactFormProvider creates contact and inserts into repository',
      () async {
    final repository = FakeContactsRepository();
    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(contactFormProvider.notifier);

    notifier.updateName('Maman');
    notifier.updateCircle(ContactCircle.proches);

    final result = await notifier.submit();

    expect(result, ContactFormSubmitResult.success);
    expect(repository.stored.length, 1);
    expect(repository.stored.first.displayName, 'Maman');
    expect(repository.stored.first.circle, ContactCircle.proches);
  });
}
