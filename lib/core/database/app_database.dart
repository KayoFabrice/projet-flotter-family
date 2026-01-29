import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'projet_flutter_famille.db';
  static const onboardingTable = 'onboarding_states';
  static const selectedCirclesTable = 'selected_circles';
  static const contactsTable = 'contacts';
  static const contactCadencesTable = 'contact_cadences';
  static const settingsFlagsTable = 'settings_flags';
  static const availabilityWindowsTable = 'availability_windows';

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final dbPath = join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      dbPath,
      version: 9,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE $onboardingTable (id INTEGER PRIMARY KEY, step TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $selectedCirclesTable (circle TEXT PRIMARY KEY)',
        );
        await database.execute(
          'CREATE TABLE $contactsTable (id TEXT PRIMARY KEY, display_name TEXT NOT NULL, circle TEXT NOT NULL, created_at TEXT NOT NULL, is_onboarding INTEGER NOT NULL DEFAULT 1, phone TEXT, email TEXT)',
        );
        await database.execute(
          'CREATE TABLE $contactCadencesTable (circle TEXT PRIMARY KEY, cadence_days INTEGER NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $settingsFlagsTable (setting_key TEXT PRIMARY KEY, setting_value TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $availabilityWindowsTable (id INTEGER PRIMARY KEY AUTOINCREMENT, start_minute INTEGER NOT NULL, end_minute INTEGER NOT NULL)',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
            'CREATE TABLE $selectedCirclesTable (circle TEXT PRIMARY KEY)',
          );
        }
        if (oldVersion < 3) {
          await database.execute(
            'CREATE TABLE $contactsTable (id TEXT PRIMARY KEY, display_name TEXT NOT NULL, circle TEXT NOT NULL, created_at TEXT NOT NULL, is_onboarding INTEGER NOT NULL DEFAULT 1, phone TEXT, email TEXT)',
          );
        } else if (oldVersion < 7) {
          const oldTable = '${contactsTable}_old';
          await database.execute(
            'ALTER TABLE $contactsTable RENAME TO $oldTable',
          );
          await database.execute(
            'CREATE TABLE $contactsTable (id TEXT PRIMARY KEY, display_name TEXT NOT NULL, circle TEXT NOT NULL, created_at TEXT NOT NULL, is_onboarding INTEGER NOT NULL DEFAULT 1, phone TEXT, email TEXT)',
          );
          if (oldVersion < 4) {
            await database.execute(
              'INSERT INTO $contactsTable (id, display_name, circle, created_at, is_onboarding, phone, email) '
              'SELECT CAST(id AS TEXT), display_name, circle, created_at, 1, NULL, NULL FROM $oldTable',
            );
          } else if (oldVersion < 6) {
            await database.execute(
              'INSERT INTO $contactsTable (id, display_name, circle, created_at, is_onboarding, phone, email) '
              'SELECT CAST(id AS TEXT), display_name, circle, created_at, is_onboarding, NULL, NULL FROM $oldTable',
            );
          } else {
            await database.execute(
              'INSERT INTO $contactsTable (id, display_name, circle, created_at, is_onboarding, phone, email) '
              'SELECT CAST(id AS TEXT), display_name, circle, created_at, is_onboarding, phone, email FROM $oldTable',
            );
          }
          await database.execute('DROP TABLE $oldTable');
        }
        if (oldVersion < 5) {
          await database.execute(
            'CREATE TABLE $contactCadencesTable (circle TEXT PRIMARY KEY, cadence_days INTEGER NOT NULL)',
          );
        }
        if (oldVersion < 8) {
          await database.execute(
            'CREATE TABLE $settingsFlagsTable (setting_key TEXT PRIMARY KEY, setting_value TEXT NOT NULL)',
          );
        }
        if (oldVersion < 9) {
          await database.execute(
            'CREATE TABLE $availabilityWindowsTable (id INTEGER PRIMARY KEY AUTOINCREMENT, start_minute INTEGER NOT NULL, end_minute INTEGER NOT NULL)',
          );
        }
      },
    );

    _database = db;
    return db;
  }
}
