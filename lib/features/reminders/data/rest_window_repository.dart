import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/rest_window.dart';

abstract class RestWindowRepository {
  Future<List<RestWindow>> fetchWindows();
  Future<void> saveWindows(List<RestWindow> windows);
}

class RestWindowRepositoryImpl implements RestWindowRepository {
  RestWindowRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<RestWindow>> fetchWindows() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.restWindowsTable,
      orderBy: 'start_minute ASC',
    );
    return rows
        .map(
          (row) => RestWindow(
            startMinute: row['start_minute'] as int,
            endMinute: row['end_minute'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveWindows(List<RestWindow> windows) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(AppDatabase.restWindowsTable);
      for (final window in windows) {
        await txn.insert(
          AppDatabase.restWindowsTable,
          {
            'start_minute': window.startMinute,
            'end_minute': window.endMinute,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
