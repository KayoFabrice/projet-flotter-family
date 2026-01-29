import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/key_location.dart';

abstract class KeyLocationRepository {
  Future<KeyLocation?> fetchKeyLocation();
  Future<void> saveKeyLocation(KeyLocation location);
}

class KeyLocationRepositoryImpl implements KeyLocationRepository {
  KeyLocationRepositoryImpl(this._database);

  final AppDatabase _database;

  static const _keyLocationLabelKey = 'key_location_label';

  @override
  Future<KeyLocation?> fetchKeyLocation() async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.settingsFlagsTable,
      where: 'setting_key = ?',
      whereArgs: const [_keyLocationLabelKey],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['setting_value'];
    if (value is! String || value.isEmpty) {
      return null;
    }
    return KeyLocation(label: value);
  }

  @override
  Future<void> saveKeyLocation(KeyLocation location) async {
    final db = await _database.database;
    await db.insert(
      AppDatabase.settingsFlagsTable,
      {
        'setting_key': _keyLocationLabelKey,
        'setting_value': location.label,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
