import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/contact_history_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_action_types.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_entry.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_history_service.dart';
import 'package:projet_flutter_famille/features/reminders/data/reminders_repository.dart';
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

class _FakeRemindersRepository implements RemindersRepository {
  Duration cooldownDuration = const Duration(hours: 48);
  String? cooldownUntil;

  @override
  Future<List<String>> fetchKeyLocationLabels() async => const [];

  @override
  Future<List<AvailabilityWindow>> fetchAvailabilityWindows() async => const [];

  @override
  Future<List<RestWindow>> fetchRestWindows() async => const [];

  @override
  Future<Duration> fetchCooldownDuration() async => cooldownDuration;

  @override
  Future<void> saveCooldownDuration(Duration duration) async {
    cooldownDuration = duration;
  }

  @override
  Future<void> setContactCooldownUntil({
    required String contactId,
    required String cooldownUntil,
  }) async {
    this.cooldownUntil = cooldownUntil;
  }

  @override
  Future<String?> fetchContactCooldownUntil(String contactId) async =>
      cooldownUntil;
}

void main() {
  test('ReminderDeferralService applique un cooldown pour Plus tard', () async {
    final now = DateTime.utc(2026, 2, 3, 9, 0);
    final historyRepo = _FakeHistoryRepository();
    final historyService = ContactHistoryService(
      repository: historyRepo,
      nowUtc: () => now,
    );
    final remindersRepo = _FakeRemindersRepository();
    final cooldownService = ReminderCooldownService(
      remindersRepo,
      clock: () => now,
    );
    final service = ReminderDeferralService(
      cooldownService: cooldownService,
      historyService: historyService,
    );

    final cooldownUntil = await service.defer(
      contactId: 'c1',
      type: ReminderDeferralType.later,
    );

    expect(
      cooldownUntil,
      now.add(const Duration(hours: 48)).toIso8601String(),
    );
    expect(historyRepo.entries.length, 1);
    expect(historyRepo.entries.first.actionType, ContactActionTypes.reminderSnooze);
    expect(remindersRepo.cooldownUntil, cooldownUntil);
  });

  test('ReminderDeferralService applique un cooldown pour Pas le bon moment', () async {
    final now = DateTime.utc(2026, 2, 3, 10, 0);
    final historyRepo = _FakeHistoryRepository();
    final historyService = ContactHistoryService(
      repository: historyRepo,
      nowUtc: () => now,
    );
    final remindersRepo = _FakeRemindersRepository();
    final cooldownService = ReminderCooldownService(
      remindersRepo,
      clock: () => now,
    );
    final service = ReminderDeferralService(
      cooldownService: cooldownService,
      historyService: historyService,
    );

    final cooldownUntil = await service.defer(
      contactId: 'c2',
      type: ReminderDeferralType.notNow,
    );

    expect(
      cooldownUntil,
      now.add(const Duration(hours: 48)).toIso8601String(),
    );
    expect(historyRepo.entries.length, 1);
    expect(historyRepo.entries.first.actionType, ContactActionTypes.reminderDismiss);
    expect(remindersRepo.cooldownUntil, cooldownUntil);
  });
}
