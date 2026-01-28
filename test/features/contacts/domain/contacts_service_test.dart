import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contacts_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_contacts_limit_exception.dart';

class FakeContactsRepository implements ContactsRepository {
  final List<Contact> _stored = [];

  @override
  Future<List<Contact>> fetchOnboardingContacts() async => List.unmodifiable(_stored);

  @override
  Future<void> createOnboardingContact(Contact contact) async {
    _stored.add(contact);
  }

  @override
  Future<int> countOnboardingContacts() async => _stored.length;
}

void main() {
  test('ContactsService creates and loads onboarding contacts', () async {
    final repository = FakeContactsRepository();
    final service = ContactsService(repository);

    final contact = await service.createOnboardingContact(
      displayName: 'Alex',
      circle: ContactCircle.proches,
    );

    final loaded = await service.loadOnboardingContacts();

    expect(loaded.length, 1);
    expect(loaded.first.displayName, 'Alex');
    expect(loaded.first.circle, ContactCircle.proches);
    expect(loaded.first.createdAt, contact.createdAt);
    expect(DateTime.parse(loaded.first.createdAt).isUtc, isTrue);
  });

  test('ContactsService prevents creating more than three onboarding contacts', () async {
    final repository = FakeContactsRepository();
    final service = ContactsService(repository);

    for (var i = 0; i < 3; i++) {
      await service.createOnboardingContact(
        displayName: 'Contact $i',
        circle: ContactCircle.proches,
      );
    }

    expect(
      () => service.createOnboardingContact(
        displayName: 'Contact 4',
        circle: ContactCircle.proches,
      ),
      throwsA(isA<OnboardingContactsLimitException>()),
    );
  });
}
