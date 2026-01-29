import 'performance_metric.dart';
import '../data/performance_metrics_repository.dart';

class PerformanceMetricKeys {
  static const launchToAgenda = 'launch_to_agenda_ms';
}

class PerformanceMetricsService {
  PerformanceMetricsService(this._repository);

  final PerformanceMetricsRepository _repository;

  Future<void> recordMetric({
    required String key,
    required int durationMs,
  }) async {
    final metric = PerformanceMetric(
      metricKey: key,
      durationMs: durationMs,
      recordedAt: DateTime.now().toUtc().toIso8601String(),
    );
    await _repository.saveMetric(metric);
  }
}
