import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/global_cadence_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/settings_flags_provider.dart';

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
  test('GlobalCadenceProvider loads default and persists update', () async {
    final repository = FakeSettingsFlagsRepository();
    final container = ProviderContainer(
      overrides: [
        settingsFlagsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(globalCadenceProvider.future);
    expect(initial.selectedKey, 'hebdomadaire');

    final notifier = container.read(globalCadenceProvider.notifier);
    notifier.select('mensuel');
    final saved = await notifier.persist();

    expect(saved, isTrue);
    expect(repository.stringStorage['global_cadence'], 'mensuel');
  });
}
