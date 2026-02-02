import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../../contacts/domain/contact_circle.dart';
import '../domain/availability_settings.dart';
import '../domain/availability_window.dart';
import '../domain/category_settings.dart';

abstract class AvailabilitySettingsRepository {
  Future<AvailabilitySettings> fetchSettings();
  Future<void> saveSettings(AvailabilitySettings settings);
}

class AvailabilitySettingsRepositoryImpl
    implements AvailabilitySettingsRepository {
  AvailabilitySettingsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<AvailabilitySettings> fetchSettings() async {
    final db = await _database.database;
    final windowsRows = await db.query(
      AppDatabase.availabilityWindowsTable,
      orderBy: 'start_minute ASC',
    );
    final categoryRows = await db.query(AppDatabase.categorySettingsTable);

    final windows = windowsRows
        .map(
          (row) => AvailabilityWindow(
            startMinute: row['start_minute'] as int,
            endMinute: row['end_minute'] as int,
          ),
        )
        .toList();

    final enabledByCircle = <ContactCircle, bool>{};
    for (final row in categoryRows) {
      final circleValue = row['circle'];
      final enabledValue = row['enabled'];
      if (circleValue is! String || enabledValue is! int) {
        continue;
      }
      final circle = ContactCircleMapping.fromStorage(circleValue);
      enabledByCircle[circle] = enabledValue == 1;
    }

    final categorySettings = CategorySettings(
      enabledByCircle: enabledByCircle,
    ).mergeDefaults();

    return AvailabilitySettings(
      windows: windows,
      categorySettings: categorySettings,
    );
  }

  @override
  Future<void> saveSettings(AvailabilitySettings settings) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await _replaceWindows(txn, settings.windows);
      await _replaceCategories(txn, settings.categorySettings);
    });
  }

  Future<void> _replaceWindows(
    Transaction txn,
    List<AvailabilityWindow> windows,
  ) async {
    await txn.delete(AppDatabase.availabilityWindowsTable);
    for (final window in windows) {
      await txn.insert(
        AppDatabase.availabilityWindowsTable,
        {'start_minute': window.startMinute, 'end_minute': window.endMinute},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> _replaceCategories(
    Transaction txn,
    CategorySettings settings,
  ) async {
    await txn.delete(AppDatabase.categorySettingsTable);
    for (final entry in settings.enabledByCircle.entries) {
      await txn.insert(
        AppDatabase.categorySettingsTable,
        {'circle': entry.key.storageValue, 'enabled': entry.value ? 1 : 0},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
