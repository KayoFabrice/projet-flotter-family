import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/reminders/data/reminders_repository.dart';
import 'package:projet_flutter_famille/features/reminders/domain/reminder_cooldown_service.dart';
import 'package:projet_flutter_famille/features/reminders/domain/rest_window.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_window.dart';

class FakeRemindersRepository implements RemindersRepository {
  Duration cooldownDuration = const Duration(hours: 48);
  String? cooldownUntil;
  String? savedDurationHours;

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
    savedDurationHours = duration.inHours.toString();
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
  test('ReminderCooldownService applique un cooldown apres ignore', () async {
    final repository = FakeRemindersRepository();
    final now = DateTime.utc(2026, 2, 3, 12, 0);
    final service = ReminderCooldownService(
      repository,
      clock: () => now,
    );

    final cooldownUntil =
        await service.applyCooldown(contactId: 'contact-1');

    expect(
      cooldownUntil,
      now.add(const Duration(hours: 48)).toIso8601String(),
    );
    expect(repository.cooldownUntil, cooldownUntil);
  });

  test('ReminderCooldownService persiste une duree configurable', () async {
    final repository = FakeRemindersRepository();
    final service = ReminderCooldownService(repository);

    await service.saveDefaultCooldown(const Duration(hours: 24));

    expect(repository.savedDurationHours, '24');
    expect(repository.cooldownDuration, const Duration(hours: 24));
  });
}
