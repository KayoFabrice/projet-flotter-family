import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/onboarding_step.dart';
import '../providers/onboarding_step_provider.dart';
import 'circles_page.dart';
import 'welcome_page.dart';

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stepState = ref.watch(onboardingStepProvider);

    return stepState.when(
      data: (step) {
        switch (step) {
          case OnboardingStep.circles:
            return const CirclesPage();
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
  }
}
