import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/reminders/domain/cooldown_rule.dart';

void main() {
  test('CooldownRule applique une duree par defaut', () {
    final rule = CooldownRule(defaultDuration: const Duration(hours: 48));
    final now = DateTime.utc(2026, 1, 1, 12, 0);

    final cooldownUntil = rule.computeCooldownUntil(now);

    expect(
      cooldownUntil,
      now.add(const Duration(hours: 48)),
    );
  });

  test('CooldownRule permet une duree configurable', () {
    final rule = CooldownRule(defaultDuration: const Duration(hours: 24));
    final now = DateTime.utc(2026, 1, 1, 12, 0);

    final cooldownUntil = rule.computeCooldownUntil(now);

    expect(
      cooldownUntil,
      now.add(const Duration(hours: 24)),
    );
  });
}
