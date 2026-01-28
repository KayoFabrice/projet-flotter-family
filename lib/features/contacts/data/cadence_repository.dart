import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/contact_cadence.dart';
import '../domain/contact_circle.dart';

abstract class CadenceRepository {
  Future<Map<ContactCircle, int>> fetchCadences();
  Future<void> saveCadences(List<ContactCadence> cadences);
}

class CadenceRepositoryImpl implements CadenceRepository {
  CadenceRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Map<ContactCircle, int>> fetchCadences() async {
    final db = await _database.database;
    final rows = await db.query(AppDatabase.contactCadencesTable);
    final mapped = <ContactCircle, int>{};
    for (final row in rows) {
      final circleRaw = row['circle'];
      final cadenceRaw = row['cadence_days'];
      if (circleRaw is! String || cadenceRaw is! int) {
        continue;
      }
      mapped[ContactCircleMapping.fromStorage(circleRaw)] = cadenceRaw;
    }
    return mapped;
  }

  @override
  Future<void> saveCadences(List<ContactCadence> cadences) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(AppDatabase.contactCadencesTable);
      for (final cadence in cadences) {
        await txn.insert(
          AppDatabase.contactCadencesTable,
          {
            'circle': cadence.circle.storageValue,
            'cadence_days': cadence.cadenceDays,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
