import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/settings/data/key_location_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location_service.dart';

class FakeKeyLocationRepository implements KeyLocationRepository {
  KeyLocation? stored;

  @override
  Future<KeyLocation?> fetchKeyLocation() async => stored;

  @override
  Future<void> saveKeyLocation(KeyLocation location) async {
    stored = location;
  }
}

void main() {
  test('KeyLocationService saves default when missing', () async {
    final repository = FakeKeyLocationRepository();
    final service = KeyLocationService(repository);

    final location = await service.ensureDefaultKeyLocation();

    expect(location, KeyLocation.defaultLocation);
    expect(repository.stored, KeyLocation.defaultLocation);
  });

  test('KeyLocationService returns existing location when present', () async {
    final repository = FakeKeyLocationRepository()
      ..stored = const KeyLocation(label: 'Bureau');
    final service = KeyLocationService(repository);

    final location = await service.ensureDefaultKeyLocation();

    expect(location.label, 'Bureau');
  });
}
