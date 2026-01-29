import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_contacts_provider.dart';

class FakeContactsRepository implements ContactsRepository {
  FakeContactsRepository({List<Contact>? initial})
      : _stored = List<Contact>.from(initial ?? const []);

  final List<Contact> _stored;

  @override
  Future<List<Contact>> fetchOnboardingContacts() async => List.unmodifiable(_stored);

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
  test('OnboardingContactsProvider loads empty and adds a contact', () async {
    final fakeRepository = FakeContactsRepository();
    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(onboardingContactsProvider), isA<AsyncLoading>());

    final initial = await container.read(onboardingContactsProvider.future);
    expect(initial, isEmpty);

    final added = await container.read(onboardingContactsProvider.notifier).addContact(
          displayName: 'Alex',
          circle: ContactCircle.amis,
        );

    expect(added, isTrue);
    final updated = container.read(onboardingContactsProvider).value ?? [];
    expect(updated.length, 1);
    expect(updated.first.displayName, 'Alex');
    expect(updated.first.circle, ContactCircle.amis);
    expect(updated.first.createdAt, isNotEmpty);
    final createdAt = DateTime.parse(updated.first.createdAt);
    expect(createdAt.isUtc, isTrue);
  });

  test('OnboardingContactsProvider refuses when max contacts reached', () async {
    final now = DateTime(2026, 1, 1).toUtc();
    final fakeRepository = FakeContactsRepository(
      initial: [
        Contact(
          id: '1',
          displayName: 'A',
          circle: ContactCircle.proches,
          createdAt: now.toIso8601String(),
        ),
        Contact(
          id: '2',
          displayName: 'B',
          circle: ContactCircle.amis,
          createdAt: now.toIso8601String(),
        ),
        Contact(
          id: '3',
          displayName: 'C',
          circle: ContactCircle.eloignes,
          createdAt: now.toIso8601String(),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        contactsRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(onboardingContactsProvider.future);
    expect(initial.length, 3);

    final added = await container.read(onboardingContactsProvider.notifier).addContact(
          displayName: 'D',
          circle: ContactCircle.proches,
        );

    expect(added, isFalse);
    final updated = container.read(onboardingContactsProvider).value ?? [];
    expect(updated.length, 3);
  });
}
