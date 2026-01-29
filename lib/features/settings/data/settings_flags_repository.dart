import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';

abstract class SettingsFlagsRepository {
  Future<bool?> fetchBool(String key);
  Future<void> saveBool(String key, bool value);
}

class SettingsFlagsRepositoryImpl implements SettingsFlagsRepository {
  SettingsFlagsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<bool?> fetchBool(String key) async {
    final db = await _database.database;
    final rows = await db.query(
      AppDatabase.settingsFlagsTable,
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    final value = rows.first['setting_value'];
    if (value is! String) {
      return null;
    }
    return value == '1';
  }

  @override
  Future<void> saveBool(String key, bool value) async {
    final db = await _database.database;
    await db.insert(
      AppDatabase.settingsFlagsTable,
      {
        'setting_key': key,
        'setting_value': value ? '1' : '0',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
