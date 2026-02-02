import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/cadence_update_service.dart';

class FakeSettingsFlagsRepository implements SettingsFlagsRepository {
  final Map<String, bool> boolStorage = {};
  final Map<String, String> stringStorage = {};

  @override
  Future<bool?> fetchBool(String key) async => boolStorage[key];

  @override
  Future<void> saveBool(String key, bool value) async {
    boolStorage[key] = value;
  }

  @override
  Future<String?> fetchString(String key) async => stringStorage[key];

  @override
  Future<void> saveString(String key, String value) async {
    stringStorage[key] = value;
  }
}

void main() {
  test('CadenceUpdateService records update and delays suggestions', () async {
    final repository = FakeSettingsFlagsRepository();
    final fixedNow = DateTime.utc(2026, 2, 2, 10, 0, 0);
    final service = CadenceUpdateService(repository, clock: () => fixedNow);

    await service.recordUpdate();

    final lastUpdate = await service.fetchLastUpdate();
    expect(lastUpdate, fixedNow);

    final shouldDelay = await service.shouldDelaySuggestions(
      const Duration(hours: 2),
    );
    expect(shouldDelay, isTrue);
  });
}
