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

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final dbPath = join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      dbPath,
      version: 5,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE $onboardingTable (id INTEGER PRIMARY KEY, step TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $selectedCirclesTable (circle TEXT PRIMARY KEY)',
        );
        await database.execute(
          'CREATE TABLE $contactsTable (id INTEGER PRIMARY KEY, display_name TEXT NOT NULL, circle TEXT NOT NULL, created_at TEXT NOT NULL, is_onboarding INTEGER NOT NULL DEFAULT 1)',
        );
        await database.execute(
          'CREATE TABLE $contactCadencesTable (circle TEXT PRIMARY KEY, cadence_days INTEGER NOT NULL)',
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
            'CREATE TABLE $contactsTable (id INTEGER PRIMARY KEY, display_name TEXT NOT NULL, circle TEXT NOT NULL, created_at TEXT NOT NULL, is_onboarding INTEGER NOT NULL DEFAULT 1)',
          );
        } else if (oldVersion < 4) {
          await database.execute(
            'ALTER TABLE $contactsTable ADD COLUMN is_onboarding INTEGER NOT NULL DEFAULT 1',
          );
        }
        if (oldVersion < 5) {
          await database.execute(
            'CREATE TABLE $contactCadencesTable (circle TEXT PRIMARY KEY, cadence_days INTEGER NOT NULL)',
          );
        }
      },
    );

    _database = db;
    return db;
  }
}
