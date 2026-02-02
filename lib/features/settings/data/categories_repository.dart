import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/settings_category.dart';

abstract class CategoriesRepository {
  Future<List<SettingsCategory>> fetchCategories();
  Future<void> saveCategories(List<SettingsCategory> categories);
}

class CategoriesRepositoryImpl implements CategoriesRepository {
  CategoriesRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<List<SettingsCategory>> fetchCategories() async {
    final db = await _database.database;
    final rows = await db.query(AppDatabase.settingsCategoriesTable);
    if (rows.isEmpty) {
      final legacyRows = await db.query(AppDatabase.categorySettingsTable);
      if (legacyRows.isEmpty) {
        return SettingsCategory.defaults;
      }
      final enabledByKey = <String, bool>{
        'famille': true,
        'amis': true,
        'autres': true,
      };
      for (final row in legacyRows) {
        final circle = row['circle'];
        final enabled = row['enabled'];
        if (circle is! String || enabled is! int) {
          continue;
        }
        if (circle == 'amis') {
          enabledByKey['amis'] = enabled == 1;
        } else {
          enabledByKey['famille'] = enabled == 1;
        }
      }
      return SettingsCategory.defaults
          .map(
            (category) => category.copyWith(
              isActive: enabledByKey[category.id] ?? category.isActive,
            ),
          )
          .toList();
    }

    return rows
        .map(
          (row) => SettingsCategory(
            id: row['id'] as String,
            name: row['name'] as String,
            description: (row['description'] as String?) ?? '',
            isActive: (row['is_active'] as int) == 1,
          ),
        )
        .toList();
  }

  @override
  Future<void> saveCategories(List<SettingsCategory> categories) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(AppDatabase.settingsCategoriesTable);
      for (final category in categories) {
        await txn.insert(
          AppDatabase.settingsCategoriesTable,
          {
            'id': category.id,
            'name': category.name,
            'description': category.description,
            'is_active': category.isActive ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
