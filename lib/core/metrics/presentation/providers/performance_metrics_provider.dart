import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../database/app_database.dart';
import '../../data/performance_metrics_repository.dart';
import '../../domain/performance_metrics_service.dart';

final performanceMetricsRepositoryProvider =
    Provider<PerformanceMetricsRepository>((ref) {
  return PerformanceMetricsRepositoryImpl(AppDatabase.instance);
});

final performanceMetricsServiceProvider =
    Provider<PerformanceMetricsService>((ref) {
  final repository = ref.read(performanceMetricsRepositoryProvider);
  return PerformanceMetricsService(repository);
});
