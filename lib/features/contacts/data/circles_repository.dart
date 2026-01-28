import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/contact_circle.dart';

abstract class CirclesRepository {
  Future<List<ContactCircle>> fetchSelectedCircles();
  Future<void> saveSelectedCircles(List<ContactCircle> circles);
}

class CirclesRepositoryImpl implements CirclesRepository {
  CirclesRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<ContactCircle>> fetchSelectedCircles() async {
    final db = await _database.database;
    final rows = await db.query(AppDatabase.selectedCirclesTable);
    return rows
        .map((row) => row['circle'])
        .whereType<String>()
        .map(ContactCircleMapping.fromStorage)
        .toList();
  }

  @override
  Future<void> saveSelectedCircles(List<ContactCircle> circles) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(AppDatabase.selectedCirclesTable);
      for (final circle in circles) {
        await txn.insert(
          AppDatabase.selectedCirclesTable,
          {'circle': circle.storageValue},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
