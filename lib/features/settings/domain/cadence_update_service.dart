import '../data/settings_flags_repository.dart';

class CadenceUpdateService {
  CadenceUpdateService(this._repository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  static const _lastUpdateKey = 'cadence_updated_at';

  final SettingsFlagsRepository _repository;
  final DateTime Function() _clock;

  Future<void> recordUpdate() async {
    final now = _clock().toUtc().toIso8601String();
    await _repository.saveString(_lastUpdateKey, now);
  }

  Future<DateTime?> fetchLastUpdate() async {
    final raw = await _repository.fetchString(_lastUpdateKey);
    if (raw == null) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    return parsed?.toUtc();
  }

  Future<bool> shouldDelaySuggestions(Duration minDelay) async {
    final lastUpdate = await fetchLastUpdate();
    if (lastUpdate == null) {
      return false;
    }
    final now = _clock().toUtc();
    return now.difference(lastUpdate) < minDelay;
  }
}
