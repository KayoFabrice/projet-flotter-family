import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static const _databaseName = 'projet_flutter_famille.db';
  static const onboardingTable = 'onboarding_states';
  static const selectedCirclesTable = 'selected_circles';

  Database? _database;

  Future<Database> get database async {
    final existing = _database;
    if (existing != null) {
      return existing;
    }

    final dbPath = join(await getDatabasesPath(), _databaseName);
    final db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE $onboardingTable (id INTEGER PRIMARY KEY, step TEXT NOT NULL)',
        );
        await database.execute(
          'CREATE TABLE $selectedCirclesTable (circle TEXT PRIMARY KEY)',
        );
      },
      onUpgrade: (database, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await database.execute(
            'CREATE TABLE $selectedCirclesTable (circle TEXT PRIMARY KEY)',
          );
        }
      },
    );

    _database = db;
    return db;
  }
}
