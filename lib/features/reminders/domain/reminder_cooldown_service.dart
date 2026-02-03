import '../data/reminders_repository.dart';
import 'cooldown_rule.dart';

class ReminderCooldownService {
  ReminderCooldownService(
    this._repository, {
    CooldownRule? cooldownRule,
    DateTime Function()? clock,
  })  : _cooldownRule = cooldownRule ?? const CooldownRule(),
        _clock = clock ?? DateTime.now;

  final RemindersRepository _repository;
  final CooldownRule _cooldownRule;
  final DateTime Function() _clock;

  Future<String> applyCooldown({required String contactId}) async {
    final duration = await _repository.fetchCooldownDuration();
    final now = _clock().toUtc();
    final cooldownUntil =
        _cooldownRule.computeCooldownUntilIso(now, duration: duration);
    await _repository.setContactCooldownUntil(
      contactId: contactId,
      cooldownUntil: cooldownUntil,
    );
    return cooldownUntil;
  }

  Future<void> saveDefaultCooldown(Duration duration) {
    return _repository.saveCooldownDuration(duration);
  }
}
