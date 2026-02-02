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
  static const contactCadenceOverridesTable = 'contact_cadence_overrides';
  static const contactHistoryTable = 'contact_history';
  static const settingsFlagsTable = 'settings_flags';
  static const availabilityWindowsTable = 'availability_windows';
  static const restWindowsTable = 'rest_windows';
  static const categorySettingsTable = 'category_settings';
  static const timeSlotPresetsTable = 'time_slot_presets';
  static const settingsCategoriesTable = 'settings_categories';
  static const performanceMetricsTable = 'performance_metrics';

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final dbPath = join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      dbPath,
      version: 15,
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
          'CREATE TABLE $contactCadenceOverridesTable (contact_id TEXT PRIMARY KEY, cadence_days INTEGER NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $contactHistoryTable (id INTEGER PRIMARY KEY AUTOINCREMENT, contact_id TEXT NOT NULL, action_type TEXT NOT NULL, occurred_at TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $settingsFlagsTable (setting_key TEXT PRIMARY KEY, setting_value TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $availabilityWindowsTable (id INTEGER PRIMARY KEY AUTOINCREMENT, start_minute INTEGER NOT NULL, end_minute INTEGER NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $restWindowsTable (id INTEGER PRIMARY KEY AUTOINCREMENT, start_minute INTEGER NOT NULL, end_minute INTEGER NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $categorySettingsTable (circle TEXT PRIMARY KEY, enabled INTEGER NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $timeSlotPresetsTable (preset_key TEXT PRIMARY KEY)',
        );
        await database.execute(
          'CREATE TABLE $settingsCategoriesTable (id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT, is_active INTEGER NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $performanceMetricsTable (id INTEGER PRIMARY KEY AUTOINCREMENT, metric_key TEXT NOT NULL, duration_ms INTEGER NOT NULL, recorded_at TEXT NOT NULL)',
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
        if (oldVersion < 10) {
          await database.execute(
            'CREATE TABLE $performanceMetricsTable (id INTEGER PRIMARY KEY AUTOINCREMENT, metric_key TEXT NOT NULL, duration_ms INTEGER NOT NULL, recorded_at TEXT NOT NULL)',
          );
        }
        if (oldVersion < 11) {
          await database.execute(
            'CREATE TABLE $contactCadenceOverridesTable (contact_id TEXT PRIMARY KEY, cadence_days INTEGER NOT NULL)',
          );
        }
        if (oldVersion < 12) {
          await database.execute(
            'CREATE TABLE $contactHistoryTable (id INTEGER PRIMARY KEY AUTOINCREMENT, contact_id TEXT NOT NULL, action_type TEXT NOT NULL, occurred_at TEXT NOT NULL)',
          );
        }
        if (oldVersion < 13) {
          await database.execute(
            'CREATE TABLE $categorySettingsTable (circle TEXT PRIMARY KEY, enabled INTEGER NOT NULL)',
          );
        }
        if (oldVersion < 14) {
          await database.execute(
            'CREATE TABLE $timeSlotPresetsTable (preset_key TEXT PRIMARY KEY)',
          );
          await database.execute(
            'CREATE TABLE $settingsCategoriesTable (id TEXT PRIMARY KEY, name TEXT NOT NULL, description TEXT, is_active INTEGER NOT NULL)',
          );
        }
        if (oldVersion < 15) {
          await database.execute(
            'CREATE TABLE $restWindowsTable (id INTEGER PRIMARY KEY AUTOINCREMENT, start_minute INTEGER NOT NULL, end_minute INTEGER NOT NULL)',
          );
        }
      },
    );

    _database = db;
    return db;
  }
}
