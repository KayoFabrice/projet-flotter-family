import 'package:flutter_test/flutter_test.dart';

import 'package:projet_flutter_famille/features/contacts/data/cadence_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contact_history_repository.dart';
import 'package:projet_flutter_famille/features/contacts/data/contacts_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/reminders/data/message_catalog_repository.dart';
import 'package:projet_flutter_famille/features/reminders/data/reminders_repository.dart';
import 'package:projet_flutter_famille/features/reminders/domain/message_catalog.dart';
import 'package:projet_flutter_famille/features/reminders/domain/reminder_suggestion_service.dart';
import 'package:projet_flutter_famille/features/reminders/domain/rest_window.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_window.dart';

void main() {
  test('ReminderSuggestionService returns a catalog message for eligible contact',
      () async {
    final contact = Contact(
      id: 'a',
      displayName: 'Alice',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );

    final catalog = MessageCatalog({
      ContactCircle.proches: {
        MessageContext.morning: ['Un coucou test.'],
        MessageContext.general: ['Un message general.'],
      },
    });

    final service = ReminderSuggestionService(
      contactsRepository: _FakeContactsRepository([contact]),
      cadenceRepository: _FakeCadenceRepository({
        ContactCircle.proches: 7,
      }),
      historyRepository: _FakeHistoryRepository(),
      remindersRepository: _FakeRemindersRepository(
        keyLocations: const ['Maison'],
        windows: const [
          AvailabilityWindow(startMinute: 8 * 60, endMinute: 20 * 60),
        ],
        restWindows: const [],
      ),
      messageCatalogRepository: MessageCatalogRepositoryImpl(catalog: catalog),
    );

    final decision = await service.selectSuggestion(
      currentLocationLabel: 'Maison',
      currentMinuteOfDay: 9 * 60,
      nowUtc: DateTime.utc(2026, 1, 13, 9),
      nowLocal: DateTime(2026, 1, 13, 9),
    );

    expect(decision.contact?.id, 'a');
    expect(decision.message, 'Un coucou test.');
  });

  test('ReminderSuggestionService returns no suggestion when catalog empty',
      () async {
    final contact = Contact(
      id: 'a',
      displayName: 'Alice',
      circle: ContactCircle.proches,
      createdAt: DateTime.utc(2025, 12, 1).toIso8601String(),
    );

    final service = ReminderSuggestionService(
      contactsRepository: _FakeContactsRepository([contact]),
      cadenceRepository: _FakeCadenceRepository({
        ContactCircle.proches: 7,
      }),
      historyRepository: _FakeHistoryRepository(),
      remindersRepository: _FakeRemindersRepository(
        keyLocations: const ['Maison'],
        windows: const [
          AvailabilityWindow(startMinute: 8 * 60, endMinute: 20 * 60),
        ],
        restWindows: const [],
      ),
      messageCatalogRepository: MessageCatalogRepositoryImpl(
        catalog: const MessageCatalog({}),
      ),
    );

    final decision = await service.selectSuggestion(
      currentLocationLabel: 'Maison',
      currentMinuteOfDay: 9 * 60,
      nowUtc: DateTime.utc(2026, 1, 13, 9),
      nowLocal: DateTime(2026, 1, 13, 9),
    );

    expect(decision.hasSuggestion, isFalse);
  });
}

class _FakeContactsRepository implements ContactsRepository {
  _FakeContactsRepository(this._contacts);

  final List<Contact> _contacts;

  @override
  Future<List<Contact>> fetchContacts() async => _contacts;

  @override
  Future<List<Contact>> searchContacts(String query) async => _contacts;

  @override
  Future<List<Contact>> fetchOnboardingContacts() async => const [];

  @override
  Future<Contact?> fetchContactById(String id) async => null;

  @override
  Future<void> createContact(Contact contact) async {}

  @override
  Future<void> createOnboardingContact(Contact contact) async {}

  @override
  Future<void> createImportedContacts(List<Contact> contacts) async {}

  @override
  Future<void> updateContact(Contact contact) async {}

  @override
  Future<void> deleteContact(String id) async {}

  @override
  Future<int> countOnboardingContacts() async => 0;
}

class _FakeCadenceRepository implements CadenceRepository {
  _FakeCadenceRepository(this._cadences);

  final Map<ContactCircle, int> _cadences;

  @override
  Future<Map<ContactCircle, int>> fetchCadences() async => _cadences;

  @override
  Future<void> saveCadences(List<ContactCadence> cadences) async {}
}

class _FakeHistoryRepository implements ContactHistoryRepository {
  @override
  Future<List<ContactHistoryEntry>> fetchRecentHistory(
    String contactId, {
    int limit = 5,
  }) async {
    return const [];
  }

  @override
  Future<int> addHistoryEntry({
    required String contactId,
    required String actionType,
    required String occurredAt,
  }) async {
    return 1;
  }
}

class _FakeRemindersRepository implements RemindersRepository {
  _FakeRemindersRepository({
    required this.keyLocations,
    required this.windows,
    required this.restWindows,
  });

  final List<String> keyLocations;
  final List<AvailabilityWindow> windows;
  final List<RestWindow> restWindows;

  @override
  Future<List<String>> fetchKeyLocationLabels() async => keyLocations;

  @override
  Future<List<AvailabilityWindow>> fetchAvailabilityWindows() async => windows;

  @override
  Future<List<RestWindow>> fetchRestWindows() async => restWindows;

  @override
  Future<Duration> fetchCooldownDuration() async => const Duration(hours: 48);

  @override
  Future<void> saveCooldownDuration(Duration duration) async {}

  @override
  Future<void> setContactCooldownUntil({
    required String contactId,
    required String cooldownUntil,
  }) async {}

  @override
  Future<String?> fetchContactCooldownUntil(String contactId) async => null;
}
