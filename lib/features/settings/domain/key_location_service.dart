import '../data/key_location_repository.dart';
import 'key_location.dart';

class KeyLocationService {
  KeyLocationService(this._repository);

  final KeyLocationRepository _repository;

  Future<KeyLocation> loadKeyLocation() async {
    return await _repository.fetchKeyLocation() ?? KeyLocation.defaultLocation;
  }

  Future<KeyLocation> ensureDefaultKeyLocation() async {
    final existing = await _repository.fetchKeyLocation();
    if (existing != null) {
      return existing;
    }
    const defaultLocation = KeyLocation.defaultLocation;
    await _repository.saveKeyLocation(defaultLocation);
    return defaultLocation;
  }

  Future<void> saveKeyLocation(KeyLocation location) {
    return _repository.saveKeyLocation(location);
  }
}
