import 'package:sqflite/sqflite.dart';

import '../../database/app_database.dart';
import '../domain/performance_metric.dart';

abstract class PerformanceMetricsRepository {
  Future<void> saveMetric(PerformanceMetric metric);
}

class PerformanceMetricsRepositoryImpl implements PerformanceMetricsRepository {
  PerformanceMetricsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<void> saveMetric(PerformanceMetric metric) async {
    final db = await _database.database;
    await db.insert(
      AppDatabase.performanceMetricsTable,
      {
        'metric_key': metric.metricKey,
        'duration_ms': metric.durationMs,
        'recorded_at': metric.recordedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
