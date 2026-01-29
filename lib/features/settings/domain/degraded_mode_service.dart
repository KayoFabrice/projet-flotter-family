import '../data/settings_flags_repository.dart';

class DegradedModeService {
  DegradedModeService(this._repository);

  final SettingsFlagsRepository _repository;

  static const _degradedModeKey = 'mode_degrade';

  Future<bool> isDegradedMode() async {
    return (await _repository.fetchBool(_degradedModeKey)) ?? false;
  }

  Future<void> setDegradedMode(bool enabled) async {
    await _repository.saveBool(_degradedModeKey, enabled);
  }
}
