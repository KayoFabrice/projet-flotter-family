import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/navigation/app_shell.dart';
import '../providers/onboarding_completion_provider.dart';

class OnboardingReadyPage extends ConsumerWidget {
  const OnboardingReadyPage({super.key});

  static const routeName = '/onboarding/ready';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    Future<void> handleContinue() async {
      final success =
          await ref.read(onboardingCompletionProvider.notifier).markComplete();
      if (!context.mounted) {
        return;
      }
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'enregistrer la fin d'onboarding."),
          ),
        );
        return;
      }
      await Navigator.of(context).pushReplacementNamed(AppShell.routeName);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _StepIndicator(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _ReadyTokens.success,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tout est pret !',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Votre agenda relationnel est configure. Profitez de votre tranquillite d\'esprit, nous vous previendrons au bon moment.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _ReadyTokens.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: handleContinue,
                  child: const Text('Decouvrir mon agenda'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReadyTokens {
  static const primary = Color(0xFF4C6EF5);
  static const success = Color(0xFF4CAF50);
  static const inactiveStep = Color(0xFFE6E8F2);
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _StepBar(active: true),
        SizedBox(width: 8),
        _StepBar(active: true),
        SizedBox(width: 8),
        _StepBar(active: true),
        SizedBox(width: 8),
        _StepBar(active: true),
        SizedBox(width: 8),
        _StepBar(active: true),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: active ? _ReadyTokens.primary : _ReadyTokens.inactiveStep,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
