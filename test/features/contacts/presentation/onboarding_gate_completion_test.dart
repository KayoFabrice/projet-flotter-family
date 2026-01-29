import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_completion_repository.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/onboarding_gate.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_completion_provider.dart';
import 'package:projet_flutter_famille/core/metrics/domain/performance_metrics_service.dart';
import 'package:projet_flutter_famille/core/metrics/presentation/providers/performance_metrics_provider.dart';

class FakeOnboardingCompletionRepository
    implements OnboardingCompletionRepository {
  @override
  Future<bool> fetchIsComplete() async => true;

  @override
  Future<void> setComplete(bool value) async {}
}

class FakePerformanceMetricsService implements PerformanceMetricsService {
  int recordCount = 0;

  @override
  Future<void> recordMetric({required String key, required int durationMs}) async {
    recordCount += 1;
  }
}

void main() {
  testWidgets('OnboardingGate routes to AppShell when onboarding is complete',
      (tester) async {
    final fakeService = FakePerformanceMetricsService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompletionRepositoryProvider
              .overrideWithValue(FakeOnboardingCompletionRepository()),
          performanceMetricsServiceProvider.overrideWithValue(fakeService),
        ],
        child: const MaterialApp(
          home: OnboardingGate(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Agenda'), findsWidgets);
    expect(fakeService.recordCount, 1);
  });
}
