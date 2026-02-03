class CooldownRule {
  const CooldownRule({this.defaultDuration = const Duration(hours: 48)});

  final Duration defaultDuration;

  DateTime computeCooldownUntil(DateTime nowUtc, {Duration? duration}) {
    final effective = duration ?? defaultDuration;
    return nowUtc.toUtc().add(effective);
  }

  String computeCooldownUntilIso(DateTime nowUtc, {Duration? duration}) {
    return computeCooldownUntil(nowUtc, duration: duration).toIso8601String();
  }

  bool isInCooldown({required DateTime nowUtc, String? cooldownUntilIso}) {
    final parsed = _parseCooldownUntil(cooldownUntilIso);
    if (parsed == null) {
      return false;
    }
    return nowUtc.toUtc().isBefore(parsed);
  }

  DateTime? _parseCooldownUntil(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(value);
    return parsed?.toUtc();
  }
}
