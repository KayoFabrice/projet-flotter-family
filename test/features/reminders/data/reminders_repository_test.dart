import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/reminders/data/reminders_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/availability_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/key_location_repository.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_window.dart';
import 'package:projet_flutter_famille/features/settings/domain/key_location.dart';

class FakeKeyLocationRepository implements KeyLocationRepository {
  FakeKeyLocationRepository({this.location});

  KeyLocation? location;

  @override
  Future<KeyLocation?> fetchKeyLocation() async => location;

  @override
  Future<void> saveKeyLocation(KeyLocation location) async {
    this.location = location;
  }
}

class FakeAvailabilityRepository implements AvailabilityRepository {
  FakeAvailabilityRepository({this.windows = const []});

  List<AvailabilityWindow> windows;

  @override
  Future<List<AvailabilityWindow>> fetchWindows() async => windows;

  @override
  Future<void> saveWindows(List<AvailabilityWindow> windows) async {
    this.windows = List<AvailabilityWindow>.from(windows);
  }
}

void main() {
  test('RemindersRepository retourne le lieu cle si present', () async {
    final keyRepo = FakeKeyLocationRepository(
      location: const KeyLocation(label: 'Maison'),
    );
    final availabilityRepo = FakeAvailabilityRepository();
    final repository = RemindersRepositoryImpl(
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
    );

    final locations = await repository.fetchKeyLocationLabels();

    expect(locations, ['Maison']);
  });

  test('RemindersRepository supporte plusieurs lieux separes par virgule', () async {
    final keyRepo = FakeKeyLocationRepository(
      location: const KeyLocation(label: 'Maison, Bureau,  Salle'),
    );
    final availabilityRepo = FakeAvailabilityRepository();
    final repository = RemindersRepositoryImpl(
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
    );

    final locations = await repository.fetchKeyLocationLabels();

    expect(locations, containsAll(<String>['Maison', 'Bureau', 'Salle']));
  });

  test('RemindersRepository retourne une liste vide si aucun lieu', () async {
    final keyRepo = FakeKeyLocationRepository();
    final availabilityRepo = FakeAvailabilityRepository();
    final repository = RemindersRepositoryImpl(
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
    );

    final locations = await repository.fetchKeyLocationLabels();

    expect(locations, isEmpty);
  });

  test('RemindersRepository charge les plages horaires', () async {
    final keyRepo = FakeKeyLocationRepository();
    final availabilityRepo = FakeAvailabilityRepository(
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      ],
    );
    final repository = RemindersRepositoryImpl(
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
    );

    final windows = await repository.fetchAvailabilityWindows();

    expect(windows.length, 1);
    expect(windows.first.startMinute, 9 * 60);
  });
}
