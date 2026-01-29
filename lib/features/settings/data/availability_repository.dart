import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/availability_window.dart';

abstract class AvailabilityRepository {
  Future<List<AvailabilityWindow>> fetchWindows();
  Future<void> saveWindows(List<AvailabilityWindow> windows);
}

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  AvailabilityRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<AvailabilityWindow>> fetchWindows() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.availabilityWindowsTable,
      orderBy: 'start_minute ASC',
    );
    return rows
        .map(
          (row) => AvailabilityWindow(
            startMinute: row['start_minute'] as int,
            endMinute: row['end_minute'] as int,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveWindows(List<AvailabilityWindow> windows) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(AppDatabase.availabilityWindowsTable);
      for (final window in windows) {
        await txn.insert(
          AppDatabase.availabilityWindowsTable,
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
