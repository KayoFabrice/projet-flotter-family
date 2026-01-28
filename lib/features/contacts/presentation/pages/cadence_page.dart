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

  static const pageBackground = Color(0xFFFBFCFD);
  static const _activeStepColor = Color(0xFF4C6EF5);
  static const _inactiveStepColor = Color(0xFFF1F5F9);
  static const _footerBorder = Color(0x14000000);
  static const _muted = Color(0xFF8B95A1);

  @override
  Widget build(BuildContext context) {
    const options = [7, 14, 30];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _StepIndicator(),
              const SizedBox(height: 32),
              Text(
                'Quel est le bon rythme ?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Choisissez une frequence ideale pour ces premiers contacts. Vous pourrez l\'ajuster pour chacun plus tard.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: _muted,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                for (var index = 0; index < cadences.length; index++) ...[
                  Text(
                    cadences[index].circle.label,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  for (final option in options) ...[
                    CadenceOptionChip(
                      key: ValueKey('cadence-${cadences[index].circle.storageValue}-$option'),
                      title: _optionTitle(option),
                      subtitle: _optionSubtitle(option),
                      icon: _optionIcon(option),
                      selected: cadences[index].cadenceDays == option,
                      onSelected: () {
                        onCadenceSelected(cadences[index].circle, option);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (index != cadences.length - 1) const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: pageBackground,
            border: Border(top: BorderSide(color: _footerBorder)),
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _activeStepColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onContinuePressed,
              child: const Text('Continuer'),
            ),
          ),
        ),
      ],
    );
  }

  String _optionTitle(int days) {
    switch (days) {
      case 7:
        return 'Chaque semaine';
      case 14:
        return 'Tous les 15 jours';
      case 30:
        return 'Chaque mois';
      default:
        return 'Tous les $days jours';
    }
  }

  String _optionSubtitle(int days) {
    switch (days) {
      case 7:
        return 'Pour la famille tres proche';
      case 14:
        return 'Pour garder un lien regulier';
      case 30:
        return 'Juste pour prendre des nouvelles';
      default:
        return 'Cadence personnalisee';
    }
  }

  IconData _optionIcon(int days) {
    switch (days) {
      case 7:
        return Icons.calendar_today_outlined;
      case 14:
        return Icons.calendar_month_outlined;
      case 30:
        return Icons.schedule;
      default:
        return Icons.calendar_month_outlined;
    }
  }
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
        _StepBar(active: false),
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
