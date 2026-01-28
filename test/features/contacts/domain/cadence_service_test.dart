import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/cadence_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/cadence_service.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';

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

void main() {
  test('CadenceService fills defaults and saves cadence values', () async {
    final repository = FakeCadenceRepository();
    final service = CadenceService(repository);

    final loaded = await service.loadCadencesForCircles(
      [ContactCircle.proches, ContactCircle.partenaire],
    );

    expect(
      loaded,
      [
        ContactCadence(circle: ContactCircle.proches, cadenceDays: 7),
        ContactCadence(circle: ContactCircle.partenaire, cadenceDays: 14),
      ],
    );

    await service.saveCadences(loaded);

    expect(
      await repository.fetchCadences(),
      {
        ContactCircle.proches: 7,
        ContactCircle.partenaire: 14,
      },
    );
  });

  test('CadenceService rejects invalid cadence values', () async {
    final repository = FakeCadenceRepository();
    final service = CadenceService(repository);

    expect(
      () => service.saveCadences(
        const [
          ContactCadence(circle: ContactCircle.proches, cadenceDays: 0),
        ],
      ),
      throwsArgumentError,
    );
  });
}
