import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/location_permission_provider.dart';
import '../providers/key_location_provider.dart';
import '../providers/availability_provider.dart';
import '../providers/degraded_mode_provider.dart';
import '../widgets/availability_time_range_editor.dart';
import '../../../../core/permissions/location_permission_service.dart';
import '../../../contacts/presentation/providers/onboarding_step_provider.dart';
import '../../../contacts/domain/onboarding_step.dart';
import '../../../contacts/presentation/pages/ready_page.dart';
import '../../domain/key_location.dart';

class LocationOrAvailabilityPage extends ConsumerWidget {
  const LocationOrAvailabilityPage({super.key});

  static const routeName = '/onboarding/location';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final background = theme.scaffoldBackgroundColor;
    final primary = theme.colorScheme.primary;
    final secondary = theme.colorScheme.secondary;
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);
    final border = theme.dividerColor;
    final card = theme.cardColor;

    final keyLocationState = ref.watch(keyLocationProvider);

    Future<void> goToReady() async {
      final saved =
          await ref.read(onboardingStepProvider.notifier).setStep(OnboardingStep.ready);
      if (!context.mounted) {
        return;
      }
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'enregistrer l'etape d'onboarding."),
          ),
        );
        return;
      }
      await Navigator.of(context).pushReplacementNamed(ReadyPage.routeName);
    }

    Future<void> handleLocationPermission() async {
      final service = ref.read(locationPermissionServiceProvider);
      final degradedService = ref.read(degradedModeServiceProvider);
      final status = await service.requestLocationPermission();
      if (!context.mounted) {
        return;
      }
      switch (status) {
        case LocationPermissionStatus.granted:
          try {
            await ref.read(keyLocationServiceProvider).ensureDefaultKeyLocation();
            await degradedService.setDegradedMode(false);
          } catch (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Impossible d'enregistrer le lieu."),
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Localisation activee.'),
            ),
          );
          await goToReady();
          return;
        case LocationPermissionStatus.denied:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Localisation refusee. Mode degrade actif (rappels moins contextuels).',
              ),
            ),
          );
          await degradedService.setDegradedMode(true);
          return;
        case LocationPermissionStatus.permanentlyDenied:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Localisation desactivee. Mode degrade actif (rappels moins contextuels).',
              ),
              action: SnackBarAction(
                label: 'Ouvrir les reglages',
                onPressed: () {
                  service.openSettings();
                },
              ),
            ),
          );
          await degradedService.setDegradedMode(true);
          return;
      }
    }

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: _StepIndicator(
                activeColor: primary,
                inactiveColor: secondary,
              ),
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
                        color: secondary,
                        borderRadius: BorderRadius.circular(48),
                      ),
                      child: const Icon(
                        Icons.place_outlined,
                        size: 40,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Le bon moment, au bon endroit',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Autorisez la localisation pour recevoir des suggestions '
                      'quand vous etes disponible (trajets, retour a la maison).',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: muted,
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: muted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Vos trajets restent prives.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: keyLocationState.when(
                              data: (location) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Lieu cle propose',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: muted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    location.label,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              loading: () => Text(
                                'Chargement...',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                              error: (_, __) => Text(
                                'Lieu indisponible',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: muted,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final controller = TextEditingController();
                              final currentLabel = keyLocationState.value?.label ??
                                  KeyLocation.defaultLocation.label;
                              controller.text = currentLabel;
                              final result = await showDialog<String>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Modifier le lieu cle'),
                                    content: TextField(
                                      controller: controller,
                                      decoration: const InputDecoration(
                                        labelText: 'Nom du lieu',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Annuler'),
                                      ),
                                      FilledButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(controller.text),
                                        child: const Text('Enregistrer'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (result == null || !context.mounted) {
                                return;
                              }
                              try {
                                await ref
                                    .read(keyLocationProvider.notifier)
                                    .updateLabel(result);
                              } catch (_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Nom de lieu invalide.',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Text('Modifier'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: handleLocationPermission,
                      icon: const Icon(Icons.navigation_outlined, size: 20),
                      label: const Text('Activer la localisation'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () async {
                        await ref
                            .read(degradedModeServiceProvider)
                            .setDegradedMode(true);
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Mode degrade actif (rappels moins contextuels).',
                            ),
                          ),
                        );
                        final saved = await showModalBottomSheet<bool>(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => Padding(
                            padding: EdgeInsets.only(
                              left: 24,
                              right: 24,
                              top: 24,
                              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                            ),
                            child: const AvailabilityTimeRangeEditor(),
                          ),
                        );
                        if (!context.mounted) {
                          return;
                        }
                        if (saved == true) {
                          await goToReady();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: muted,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Choisir des horaires fixes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.activeColor,
    required this.inactiveColor,
  });

  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StepBar(active: true, activeColor: activeColor, inactiveColor: inactiveColor),
        SizedBox(width: 8),
        _StepBar(active: true, activeColor: activeColor, inactiveColor: inactiveColor),
        SizedBox(width: 8),
        _StepBar(active: true, activeColor: activeColor, inactiveColor: inactiveColor),
        SizedBox(width: 8),
        _StepBar(active: true, activeColor: activeColor, inactiveColor: inactiveColor),
        SizedBox(width: 8),
        _StepBar(active: true, activeColor: activeColor, inactiveColor: inactiveColor),
      ],
    );
  }
}

class _StepBar extends StatelessWidget {
  const _StepBar({
    required this.active,
    required this.activeColor,
    required this.inactiveColor,
  });

  final bool active;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 4,
        decoration: BoxDecoration(
          color: active ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
