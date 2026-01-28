import '../data/cadence_repository.dart';
import 'contact_cadence.dart';
import 'contact_circle.dart';

class CadenceService {
  CadenceService(this._repository);

  final CadenceRepository _repository;

  Future<List<ContactCadence>> loadCadencesForCircles(
    List<ContactCircle> circles,
  ) async {
    final stored = await _repository.fetchCadences();
    return circles
        .map(
          (circle) => ContactCadence(
            circle: circle,
            cadenceDays: stored[circle] ?? _defaultCadenceDays(circle),
          ),
        )
        .toList();
  }

  Future<void> saveCadences(List<ContactCadence> cadences) {
    return _repository.saveCadences(cadences);
  }

  int _defaultCadenceDays(ContactCircle circle) {
    switch (circle) {
      case ContactCircle.proches:
        return 7;
      case ContactCircle.eloignes:
        return 30;
      case ContactCircle.partenaire:
        return 14;
      case ContactCircle.amis:
        return 14;
    }
  }
}
