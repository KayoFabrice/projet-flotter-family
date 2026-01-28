import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/onboarding_step.dart';

abstract class OnboardingRepository {
  Future<OnboardingStep> fetchCurrentStep();
  Future<void> setCurrentStep(OnboardingStep step);
}

class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._database);

  final AppDatabase _database;
  static const _legacyTable = 'onboarding_state';

  @override
  Future<OnboardingStep> fetchCurrentStep() async {
    final db = await _database.database;
    List<Map<String, Object?>> rows;
    try {
      rows = await db.query(
        AppDatabase.onboardingTable,
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );
    } on DatabaseException {
      rows = await db.query(
        _legacyTable,
        where: 'id = ?',
        whereArgs: [1],
        limit: 1,
      );
    }

    if (rows.isEmpty) {
      return OnboardingStep.welcome;
    }

    final storedValue = rows.first['step'];
    if (storedValue is String) {
      return OnboardingStepMapping.fromStorage(storedValue);
    }

    return OnboardingStep.welcome;
  }

  @override
  Future<void> setCurrentStep(OnboardingStep step) async {
    final db = await _database.database;
    try {
      await db.insert(
        AppDatabase.onboardingTable,
        {
          'id': 1,
          'step': step.storageValue,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException {
      await db.insert(
        _legacyTable,
        {
          'id': 1,
          'step': step.storageValue,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }
}
