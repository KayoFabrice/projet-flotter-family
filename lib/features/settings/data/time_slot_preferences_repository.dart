import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/time_slot_preset.dart';

abstract class TimeSlotPreferencesRepository {
  Future<Set<String>> fetchSelectedPresetKeys();
  Future<void> saveSelectedPresetKeys(Set<String> keys);
}

class TimeSlotPreferencesRepositoryImpl
    implements TimeSlotPreferencesRepository {
  TimeSlotPreferencesRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Set<String>> fetchSelectedPresetKeys() async {
    final db = await _database.database;
    final rows = await db.query(AppDatabase.timeSlotPresetsTable);
    final keys = <String>{};
    for (final row in rows) {
      final key = row['preset_key'];
      if (key is String) {
        keys.add(key);
      }
    }
    if (keys.isNotEmpty) {
      return keys;
    }

    final legacyRows = await db.query(AppDatabase.availabilityWindowsTable);
    if (legacyRows.isEmpty) {
      return keys;
    }
    final inferred = <String>{};
    for (final row in legacyRows) {
      final start = row['start_minute'];
      final end = row['end_minute'];
      if (start is! int || end is! int) {
        continue;
      }
      for (final preset in TimeSlotPreset.presets) {
        if (preset.startMinute == null || preset.endMinute == null) {
          continue;
        }
        if (_overlaps(start, end, preset.startMinute!, preset.endMinute!)) {
          inferred.add(preset.key);
        }
      }
    }
    return inferred;
  }

  @override
  Future<void> saveSelectedPresetKeys(Set<String> keys) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.delete(AppDatabase.timeSlotPresetsTable);
      for (final key in keys) {
        await txn.insert(
          AppDatabase.timeSlotPresetsTable,
          {'preset_key': key},
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  bool _overlaps(int start, int end, int presetStart, int presetEnd) {
    return start < presetEnd && end > presetStart;
  }
}
