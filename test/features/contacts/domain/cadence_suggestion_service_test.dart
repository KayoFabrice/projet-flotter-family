import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/cadence_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/cadence_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/cadence_suggestion_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/cadence_update_service.dart';

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
  test('CadenceSuggestionService uses updated cadence and delays after save', () async {
    final repository = FakeCadenceRepository(
      initial: {
        ContactCircle.proches: 7,
        ContactCircle.eloignes: 30,
      },
    );
    final cadenceService = CadenceService(repository);

    var now = DateTime.utc(2026, 2, 2, 10, 0, 0);
    final settingsRepository = FakeSettingsFlagsRepository();
    final updateService = CadenceUpdateService(
      settingsRepository,
      clock: () => now,
    );

    final suggestionService = CadenceSuggestionService(
      cadenceService,
      updateService,
      minDelay: const Duration(hours: 1),
    );

    await updateService.recordUpdate();

    var snapshot = await suggestionService.loadSnapshot(ContactCircle.values);
    expect(snapshot.cadences[ContactCircle.proches], 7);
    expect(snapshot.shouldDelaySuggestions, isTrue);

    await repository.saveCadences(
      const [
        ContactCadence(circle: ContactCircle.proches, cadenceDays: 14),
        ContactCadence(circle: ContactCircle.eloignes, cadenceDays: 30),
      ],
    );

    now = now.add(const Duration(hours: 2));
    snapshot = await suggestionService.loadSnapshot(ContactCircle.values);
    expect(snapshot.cadences[ContactCircle.proches], 14);
    expect(snapshot.shouldDelaySuggestions, isFalse);
  });
}
