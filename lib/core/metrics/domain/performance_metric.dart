class PerformanceMetric {
  const PerformanceMetric({
    required this.metricKey,
    required this.durationMs,
    required this.recordedAt,
  });

  final String metricKey;
  final int durationMs;
  final String recordedAt;
}
