import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/cadence_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/cadence_settings_provider.dart';
import 'package:projet_flutter_famille/features/settings/presentation/providers/degraded_mode_provider.dart';

class FakeCadenceRepository implements CadenceRepository {
  FakeCadenceRepository({Map<ContactCircle, int>? initial})
      : _stored = Map<ContactCircle, int>.from(initial ?? const {});

  Map<ContactCircle, int> _stored;

  @override
  Future<Map<ContactCircle, int>> fetchCadences() async => Map.unmodifiable(_stored);

  @override
  Future<void> saveCadences(List<ContactCadence> cadences) async {
    _stored = {
      for (final cadence in cadences) cadence.circle: cadence.cadenceDays,
    };
  }
}

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
  test('CadenceSettingsProvider loads defaults and persists updates', () async {
    final fakeRepository = FakeCadenceRepository();
    final fakeSettingsRepository = FakeSettingsFlagsRepository();
    final container = ProviderContainer(
      overrides: [
        cadenceSettingsRepositoryProvider.overrideWithValue(fakeRepository),
        settingsFlagsRepositoryProvider.overrideWithValue(fakeSettingsRepository),
      ],
    );
    addTearDown(container.dispose);

    final initial = await container.read(cadenceSettingsProvider.future);
    expect(
      initial,
      [
        ContactCadence(circle: ContactCircle.proches, cadenceDays: 7),
        ContactCadence(circle: ContactCircle.eloignes, cadenceDays: 30),
        ContactCadence(circle: ContactCircle.partenaire, cadenceDays: 14),
        ContactCadence(circle: ContactCircle.amis, cadenceDays: 14),
      ],
    );

    final notifier = container.read(cadenceSettingsProvider.notifier);
    notifier.updateCadence(ContactCircle.proches, 14);
    final persisted = await notifier.persist();

    expect(persisted, isTrue);
    expect(
      await fakeRepository.fetchCadences(),
      {
        ContactCircle.proches: 14,
        ContactCircle.eloignes: 30,
        ContactCircle.partenaire: 14,
        ContactCircle.amis: 14,
      },
    );
  });
}
