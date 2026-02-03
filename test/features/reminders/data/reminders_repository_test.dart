import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/core/database/app_database.dart';
import 'package:projet_flutter_famille/features/reminders/data/reminders_repository.dart';
import 'package:projet_flutter_famille/features/reminders/data/rest_window_repository.dart';
import 'package:projet_flutter_famille/features/reminders/domain/rest_window.dart';
import 'package:projet_flutter_famille/features/settings/data/availability_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/key_location_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';
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

class FakeRestWindowRepository implements RestWindowRepository {
  FakeRestWindowRepository({this.windows = const []});

  List<RestWindow> windows;

  @override
  Future<List<RestWindow>> fetchWindows() async => windows;

  @override
  Future<void> saveWindows(List<RestWindow> windows) async {
    this.windows = List<RestWindow>.from(windows);
  }
}

class FakeSettingsFlagsRepository implements SettingsFlagsRepository {
  FakeSettingsFlagsRepository({this.boolValues = const {}, this.stringValues = const {}});

  Map<String, bool> boolValues;
  Map<String, String> stringValues;

  @override
  Future<bool?> fetchBool(String key) async => boolValues[key];

  @override
  Future<void> saveBool(String key, bool value) async {
    boolValues = {...boolValues, key: value};
  }

  @override
  Future<String?> fetchString(String key) async => stringValues[key];

  @override
  Future<void> saveString(String key, String value) async {
    stringValues = {...stringValues, key: value};
  }
}

void main() {
  test('RemindersRepository retourne le lieu cle si present', () async {
    final keyRepo = FakeKeyLocationRepository(
      location: const KeyLocation(label: 'Maison'),
    );
    final availabilityRepo = FakeAvailabilityRepository();
    final restWindowRepo = FakeRestWindowRepository();
    final settingsFlagsRepo = FakeSettingsFlagsRepository();
    final repository = RemindersRepositoryImpl(
      database: AppDatabase.instance,
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
      restWindowRepository: restWindowRepo,
      settingsFlagsRepository: settingsFlagsRepo,
    );

    final locations = await repository.fetchKeyLocationLabels();

    expect(locations, ['Maison']);
  });

  test('RemindersRepository supporte plusieurs lieux separes par virgule', () async {
    final keyRepo = FakeKeyLocationRepository(
      location: const KeyLocation(label: 'Maison, Bureau,  Salle'),
    );
    final availabilityRepo = FakeAvailabilityRepository();
    final restWindowRepo = FakeRestWindowRepository();
    final settingsFlagsRepo = FakeSettingsFlagsRepository();
    final repository = RemindersRepositoryImpl(
      database: AppDatabase.instance,
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
      restWindowRepository: restWindowRepo,
      settingsFlagsRepository: settingsFlagsRepo,
    );

    final locations = await repository.fetchKeyLocationLabels();

    expect(locations, containsAll(<String>['Maison', 'Bureau', 'Salle']));
  });

  test('RemindersRepository retourne une liste vide si aucun lieu', () async {
    final keyRepo = FakeKeyLocationRepository();
    final availabilityRepo = FakeAvailabilityRepository();
    final restWindowRepo = FakeRestWindowRepository();
    final settingsFlagsRepo = FakeSettingsFlagsRepository();
    final repository = RemindersRepositoryImpl(
      database: AppDatabase.instance,
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
      restWindowRepository: restWindowRepo,
      settingsFlagsRepository: settingsFlagsRepo,
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
    final restWindowRepo = FakeRestWindowRepository();
    final settingsFlagsRepo = FakeSettingsFlagsRepository();
    final repository = RemindersRepositoryImpl(
      database: AppDatabase.instance,
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
      restWindowRepository: restWindowRepo,
      settingsFlagsRepository: settingsFlagsRepo,
    );

    final windows = await repository.fetchAvailabilityWindows();

    expect(windows.length, 1);
    expect(windows.first.startMinute, 9 * 60);
  });

  test('RemindersRepository retourne la plage de repos par defaut', () async {
    final keyRepo = FakeKeyLocationRepository();
    final availabilityRepo = FakeAvailabilityRepository();
    final restWindowRepo = FakeRestWindowRepository(windows: const []);
    final settingsFlagsRepo = FakeSettingsFlagsRepository();
    final repository = RemindersRepositoryImpl(
      database: AppDatabase.instance,
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
      restWindowRepository: restWindowRepo,
      settingsFlagsRepository: settingsFlagsRepo,
    );

    final restWindows = await repository.fetchRestWindows();

    expect(restWindows.length, 1);
    expect(restWindows.first.startMinute, 22 * 60);
    expect(restWindows.first.endMinute, 7 * 60);
  });

  test('RemindersRepository retourne les plages de repos stockees', () async {
    final keyRepo = FakeKeyLocationRepository();
    final availabilityRepo = FakeAvailabilityRepository();
    final restWindowRepo = FakeRestWindowRepository(
      windows: const [
        RestWindow(startMinute: 21 * 60, endMinute: 6 * 60),
      ],
    );
    final settingsFlagsRepo = FakeSettingsFlagsRepository();
    final repository = RemindersRepositoryImpl(
      database: AppDatabase.instance,
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
      restWindowRepository: restWindowRepo,
      settingsFlagsRepository: settingsFlagsRepo,
    );

    final restWindows = await repository.fetchRestWindows();

    expect(restWindows.length, 1);
    expect(restWindows.first.startMinute, 21 * 60);
    expect(restWindows.first.endMinute, 6 * 60);
  });

  test('RemindersRepository reutilise les disponibilites en mode repos', () async {
    final keyRepo = FakeKeyLocationRepository();
    final availabilityRepo = FakeAvailabilityRepository(
      windows: const [
        AvailabilityWindow(startMinute: 20 * 60, endMinute: 23 * 60),
      ],
    );
    final restWindowRepo = FakeRestWindowRepository(
      windows: const [
        RestWindow(startMinute: 22 * 60, endMinute: 7 * 60),
      ],
    );
    final settingsFlagsRepo = FakeSettingsFlagsRepository(
      boolValues: const {'rest_mode_use_availability': true},
    );
    final repository = RemindersRepositoryImpl(
      database: AppDatabase.instance,
      keyLocationRepository: keyRepo,
      availabilityRepository: availabilityRepo,
      restWindowRepository: restWindowRepo,
      settingsFlagsRepository: settingsFlagsRepo,
    );

    final restWindows = await repository.fetchRestWindows();

    expect(restWindows.length, 1);
    expect(restWindows.first.startMinute, 20 * 60);
    expect(restWindows.first.endMinute, 23 * 60);
  });
}
