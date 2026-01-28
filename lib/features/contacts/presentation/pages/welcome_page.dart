import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/onboarding_step.dart';
import '../providers/onboarding_step_provider.dart';
import 'circles_page.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  static const routeName = '/onboarding/welcome';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                'Gardez le lien avec vos proches, sans effort.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                "Recevez une suggestion claire au bon moment pour écrire ou appeler.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final success = await ref
                        .read(onboardingStepProvider.notifier)
                        .setStep(OnboardingStep.circles);

                    if (!context.mounted) {
                      return;
                    }

                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Impossible d'enregistrer l'etape d'onboarding.",
                          ),
                        ),
                      );
                      return;
                    }

                    await Navigator.of(context).pushNamed(
                      CirclesPage.routeName,
                    );
                  },
                  child: const Text('Commencer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
