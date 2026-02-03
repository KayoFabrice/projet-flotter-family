import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:projet_flutter_famille/core/database/app_database.dart';
import 'package:projet_flutter_famille/features/reminders/data/reminders_repository.dart';
import 'package:projet_flutter_famille/features/reminders/data/rest_window_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/availability_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/key_location_repository.dart';
import 'package:projet_flutter_famille/features/settings/data/settings_flags_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('RemindersRepository stocke et relit cooldown_until', () async {
    final database = AppDatabase.instance;
    final db = await database.database;

    await db.delete(AppDatabase.contactsTable);

    await db.insert(AppDatabase.contactsTable, {
      'id': 'contact-1',
      'display_name': 'Maman',
      'circle': 'proches',
      'created_at': DateTime(2026, 1, 10).toUtc().toIso8601String(),
      'is_onboarding': 0,
      'phone': null,
      'email': null,
      'cooldown_until': null,
    });

    final repository = RemindersRepositoryImpl(
      database: database,
      keyLocationRepository: KeyLocationRepositoryImpl(database),
      availabilityRepository: AvailabilityRepositoryImpl(database),
      restWindowRepository: RestWindowRepositoryImpl(database),
      settingsFlagsRepository: SettingsFlagsRepositoryImpl(database),
    );

    final cooldownUntil =
        DateTime(2026, 1, 12, 12).toUtc().toIso8601String();
    await repository.setContactCooldownUntil(
      contactId: 'contact-1',
      cooldownUntil: cooldownUntil,
    );

    final stored = await repository.fetchContactCooldownUntil('contact-1');

    expect(stored, cooldownUntil);
  });
}
