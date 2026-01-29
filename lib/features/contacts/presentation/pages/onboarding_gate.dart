import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_shell.dart';
import '../../../../core/metrics/domain/performance_metrics_service.dart';
import '../../../../core/metrics/presentation/providers/performance_metrics_provider.dart';
import '../../../../core/metrics/startup_timer.dart';
import '../../domain/onboarding_step.dart';
import '../providers/onboarding_completion_provider.dart';
import '../providers/onboarding_step_provider.dart';
import 'cadence_page.dart';
import 'circles_page.dart';
import 'first_contacts_page.dart';
import 'import_contacts_page.dart';
import 'onboarding_ready_page.dart';
import 'welcome_page.dart';
import '../../../settings/presentation/pages/location_or_availability_page.dart';

class OnboardingGate extends ConsumerStatefulWidget {
  const OnboardingGate({super.key});

  @override
  ConsumerState<OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends ConsumerState<OnboardingGate> {
  bool _performanceRecorded = false;

  @override
  Widget build(BuildContext context) {
    final completionState = ref.watch(onboardingCompletionProvider);

    return completionState.when(
      data: (completion) {
        if (completion.isComplete) {
          if (!_performanceRecorded) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted || _performanceRecorded) {
                return;
              }
              final durationMs = AppStartupTimer.elapsedMs;
              try {
                await ref.read(performanceMetricsServiceProvider).recordMetric(
                      key: PerformanceMetricKeys.launchToAgenda,
                      durationMs: durationMs,
                    );
              } finally {
                if (mounted) {
                  setState(() {
                    _performanceRecorded = true;
                  });
                }
              }
            });
          }
          return const AppShell();
        }

        final stepState = ref.watch(onboardingStepProvider);
        return stepState.when(
          data: (step) {
            switch (step) {
              case OnboardingStep.cadence:
                return const CadencePage();
              case OnboardingStep.importContacts:
                return const ImportContactsPage();
              case OnboardingStep.locationOrAvailability:
                return const LocationOrAvailabilityPage();
              case OnboardingStep.ready:
                return const OnboardingReadyPage();
              case OnboardingStep.circles:
                return const CirclesPage();
              case OnboardingStep.firstContacts:
                return const FirstContactsPage();
              case OnboardingStep.welcome:
                return const WelcomePage();
            }
          },
          loading: () => const Scaffold(
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (error, stackTrace) => Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erreur de chargement de l\'onboarding.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        ref.invalidate(onboardingStepProvider);
                      },
                      child: const Text('Reessayer'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Erreur de chargement de l\'etat d\'onboarding.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(onboardingCompletionProvider);
                  },
                  child: const Text('Reessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
