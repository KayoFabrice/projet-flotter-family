import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/degraded_mode_service.dart';

class FakeSettingsFlagsRepository implements SettingsFlagsRepository {
  final Map<String, bool> storage = {};
  final Map<String, String> stringStorage = {};

  @override
  Future<bool?> fetchBool(String key) async => storage[key];

  @override
  Future<void> saveBool(String key, bool value) async {
    storage[key] = value;
  }

  @override
  Future<String?> fetchString(String key) async => stringStorage[key];

  @override
  Future<void> saveString(String key, String value) async {
    stringStorage[key] = value;
  }
}

void main() {
  test('DegradedModeService saves and reads flag', () async {
    final repository = FakeSettingsFlagsRepository();
    final service = DegradedModeService(repository);

    await service.setDegradedMode(true);
    final value = await service.isDegradedMode();

    expect(value, isTrue);
  });
}
