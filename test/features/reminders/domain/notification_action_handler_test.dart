import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contact_history_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_action_types.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_call_action_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_write_action_service.dart';
import 'package:projet_flutter_famille/features/reminders/data/reminders_repository.dart';
import 'package:projet_flutter_famille/features/reminders/domain/notification_action_handler.dart';
import 'package:projet_flutter_famille/features/reminders/domain/reminder_cooldown_service.dart';
import 'package:projet_flutter_famille/features/reminders/domain/reminder_deferral_service.dart';
import 'package:projet_flutter_famille/features/reminders/domain/rest_window.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_window.dart';

class _FakeHistoryRepository implements ContactHistoryRepository {
  final entries = <ContactHistoryEntry>[];

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
    entries.add(
      ContactHistoryEntry(
        id: entries.length + 1,
        contactId: contactId,
        actionType: actionType,
        occurredAt: occurredAt,
      ),
    );
    return entries.length;
  }
}

class _FakeLauncher implements ContactActionLauncher {
  @override
  Future<bool> canLaunch(Uri uri) async => true;

  @override
  Future<bool> launch(Uri uri) async => true;
}

class _FakeRemindersRepository implements RemindersRepository {
  @override
  Future<List<String>> fetchKeyLocationLabels() async => const [];

  @override
  Future<List<AvailabilityWindow>> fetchAvailabilityWindows() async => const [];

  @override
  Future<List<RestWindow>> fetchRestWindows() async => const [];

  @override
  Future<Duration> fetchCooldownDuration() async =>
      const Duration(hours: 48);

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

void main() {
  test('NotificationActionHandler declenche l ecriture et historise', () async {
    final repo = _FakeHistoryRepository();
    final history = ContactHistoryService(repository: repo);
    final writeService = ContactWriteActionService(
      historyService: history,
      launcher: _FakeLauncher(),
    );
    final callService = ContactCallActionService(
      historyService: history,
      launcher: _FakeLauncher(),
    );
    final deferralService = ReminderDeferralService(
      cooldownService: ReminderCooldownService(_FakeRemindersRepository()),
      historyService: history,
    );
    final handler = NotificationActionHandler(
      writeService: writeService,
      callService: callService,
      deferralService: deferralService,
    );

    final result = await handler.handleWriteAction(
      contactId: 'c1',
      uri: Uri.parse('sms:+33612345678'),
    );

    expect(result, ContactWriteOutcome.success);
    expect(repo.entries.length, 2);
    expect(repo.entries.first.actionType, ContactActionTypes.writeAttempt);
    expect(repo.entries.last.actionType, ContactActionTypes.writeSuccess);
  });

  test('NotificationActionHandler declenche l appel et historise', () async {
    final repo = _FakeHistoryRepository();
    final history = ContactHistoryService(repository: repo);
    final writeService = ContactWriteActionService(
      historyService: history,
      launcher: _FakeLauncher(),
    );
    final callService = ContactCallActionService(
      historyService: history,
      launcher: _FakeLauncher(),
    );
    final deferralService = ReminderDeferralService(
      cooldownService: ReminderCooldownService(_FakeRemindersRepository()),
      historyService: history,
    );
    final handler = NotificationActionHandler(
      writeService: writeService,
      callService: callService,
      deferralService: deferralService,
    );

    final result = await handler.handleCallAction(
      contactId: 'c2',
      uri: Uri.parse('tel:+33612345678'),
    );

    expect(result, ContactCallOutcome.success);
    expect(repo.entries.length, 2);
    expect(repo.entries.first.actionType, ContactActionTypes.callAttempt);
    expect(repo.entries.last.actionType, ContactActionTypes.callSuccess);
  });
}
