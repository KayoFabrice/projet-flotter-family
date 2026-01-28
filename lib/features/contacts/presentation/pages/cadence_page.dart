import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact_cadence.dart';
import '../../domain/contact_circle.dart';
import '../../domain/onboarding_step.dart';
import '../providers/onboarding_cadence_provider.dart';
import '../providers/onboarding_step_provider.dart';
import '../widgets/cadence_option_chip.dart';
import 'import_contacts_page.dart';

class CadencePage extends ConsumerWidget {
  const CadencePage({super.key});

  static const routeName = '/onboarding/cadence';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadenceState = ref.watch(onboardingCadenceProvider);

    Future<void> handleContinue() async {
      final cadenceSaved = await ref.read(onboardingCadenceProvider.notifier).persist();
      if (!context.mounted) {
        return;
      }
      if (!cadenceSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'enregistrer la cadence."),
          ),
        );
        return;
      }

      final stepSaved = await ref
          .read(onboardingStepProvider.notifier)
          .setStep(OnboardingStep.importContacts);
      if (!context.mounted) {
        return;
      }
      if (!stepSaved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'enregistrer l'etape d'onboarding."),
          ),
        );
        return;
      }

      await Navigator.of(context).pushReplacementNamed(
        ImportContactsPage.routeName,
      );
    }

    return cadenceState.when(
      data: (cadences) {
        return Scaffold(
          backgroundColor: CadenceContent.pageBackground,
          body: SafeArea(
            child: CadenceContent(
              cadences: cadences,
              onCadenceSelected: (circle, cadenceDays) {
                ref
                    .read(onboardingCadenceProvider.notifier)
                    .updateCadence(circle, cadenceDays);
              },
              onContinuePressed: handleContinue,
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
                const Text('Erreur de chargement de la cadence.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(onboardingCadenceProvider);
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

class CadenceContent extends StatelessWidget {
  const CadenceContent({
    super.key,
    required this.cadences,
    required this.onCadenceSelected,
    required this.onContinuePressed,
  });

  final List<ContactCadence> cadences;
  final void Function(ContactCircle circle, int cadenceDays) onCadenceSelected;
  final VoidCallback onContinuePressed;

  static const pageBackground = Color(0xFFF6F7F3);
  static const _activeStepColor = Color(0xFF4C6FFF);
  static const _inactiveStepColor = Color(0xFFE2E8F0);
  static const _cardBorderColor = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    const options = [7, 14, 30];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepIndicator(),
          const SizedBox(height: 28),
          Text(
            'Cadence',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Definissez un rythme simple',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Choisissez une cadence par cercle. Vous pourrez ajuster plus tard.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (var index = 0; index < cadences.length; index++) ...[
                    _CadenceCard(
                      cadence: cadences[index],
                      options: options,
                      onSelected: (value) {
                        onCadenceSelected(cadences[index].circle, value);
                      },
                    ),
                    if (index != cadences.length - 1) const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _activeStepColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: onContinuePressed,
              child: const Text('Continuer'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CadenceCard extends StatelessWidget {
  const _CadenceCard({
    required this.cadence,
    required this.options,
    required this.onSelected,
  });

  final ContactCadence cadence;
  final List<int> options;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CadenceContent._cardBorderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cadence.circle.label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: options.map((option) {
              return CadenceOptionChip(
                key: ValueKey('cadence-${cadence.circle.storageValue}-$option'),
                label: '${option} j',
                selected: cadence.cadenceDays == option,
                onSelected: () => onSelected(option),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _StepBar(active: false),
        SizedBox(width: 8),
        _StepBar(active: false),
        SizedBox(width: 8),
        _StepBar(active: false),
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
          color: active
              ? CadenceContent._activeStepColor
              : CadenceContent._inactiveStepColor,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
