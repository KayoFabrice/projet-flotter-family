import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/core/metrics/data/performance_metrics_repository.dart';
import 'package:projet_flutter_famille/core/metrics/domain/performance_metric.dart';
import 'package:projet_flutter_famille/core/metrics/domain/performance_metrics_service.dart';

class FakePerformanceMetricsRepository implements PerformanceMetricsRepository {
  int savedCount = 0;
  String? lastKey;
  int? lastDuration;

  @override
  Future<void> saveMetric(PerformanceMetric metric) async {
    savedCount += 1;
    lastKey = metric.metricKey;
    lastDuration = metric.durationMs;
  }
}

void main() {
  test('PerformanceMetricsService records a metric', () async {
    final repository = FakePerformanceMetricsRepository();
    final service = PerformanceMetricsService(repository);

    await service.recordMetric(
      key: PerformanceMetricKeys.launchToAgenda,
      durationMs: 1200,
    );

    expect(repository.savedCount, 1);
    expect(repository.lastKey, PerformanceMetricKeys.launchToAgenda);
    expect(repository.lastDuration, 1200);
  });
}
