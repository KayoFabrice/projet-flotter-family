import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact_circle.dart';
import '../../domain/onboarding_step.dart';
import '../providers/onboarding_step_provider.dart';
import '../providers/selected_circles_provider.dart';
import 'first_contacts_page.dart';

class CirclesPage extends ConsumerWidget {
  const CirclesPage({super.key});

  static const routeName = '/onboarding/circles';

  static const _activeStepColor = Color(0xFF4C6FFF);
  static const _inactiveStepColor = Color(0xFFE2E8F0);
  static const _selectedCardColor = Color(0xFFF5D7A7);
  static const _cardBorderColor = Color(0xFFE2E8F0);
  static const _cardIconBackground = Color(0xFFF2F4F8);
  static const _pageBackground = Color(0xFFF6F7F3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circlesState = ref.watch(selectedCirclesProvider);

    return circlesState.when(
      data: (selectedCircles) {
        return Scaffold(
          backgroundColor: _pageBackground,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _StepIndicator(),
                  const SizedBox(height: 28),
                  Text(
                    'Qui compte pour vous ?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Selectionnez les cercles que vous souhaitez entretenir. Vous pourrez affiner cela plus tard.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.05,
                      children: ContactCircle.values.map((circle) {
                        final isSelected = selectedCircles.contains(circle);
                        return _CircleCard(
                          label: circle.label,
                          icon: _iconForCircle(circle),
                          selected: isSelected,
                          onTap: () {
                            ref
                                .read(selectedCirclesProvider.notifier)
                                .toggleCircle(circle);
                          },
                        );
                      }).toList(),
                    ),
                  ),
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
                      onPressed: () async {
                        if (selectedCircles.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Selectionnez au moins un cercle pour continuer.',
                              ),
                            ),
                          );
                          return;
                        }

                        final selectionSaved = await ref
                            .read(selectedCirclesProvider.notifier)
                            .persistSelection();

                        if (!context.mounted) {
                          return;
                        }

                        if (!selectionSaved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Impossible d'enregistrer vos cercles.",
                              ),
                            ),
                          );
                          return;
                        }

                        final stepSaved = await ref
                            .read(onboardingStepProvider.notifier)
                            .setStep(OnboardingStep.firstContacts);

                        if (!context.mounted) {
                          return;
                        }

                        if (!stepSaved) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Impossible d'enregistrer l'etape d'onboarding.",
                              ),
                            ),
                          );
                          return;
                        }

                        await Navigator.of(context).pushReplacementNamed(
                          FirstContactsPage.routeName,
                        );
                      },
                      child: const Text('Continuer'),
                    ),
                  ),
                ],
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
                const Text('Erreur de chargement des cercles.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(selectedCirclesProvider);
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

  IconData _iconForCircle(ContactCircle circle) {
    switch (circle) {
      case ContactCircle.proches:
        return Icons.groups;
      case ContactCircle.eloignes:
        return Icons.person;
      case ContactCircle.partenaire:
        return Icons.favorite_border;
      case ContactCircle.amis:
        return Icons.sentiment_satisfied_outlined;
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
        _StepBar(active: false),
        SizedBox(width: 8),
        _StepBar(active: false),
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
          color: active ? CirclesPage._activeStepColor : CirclesPage._inactiveStepColor,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  const _CircleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? CirclesPage._selectedCardColor : Colors.white;
    final borderColor = selected ? CirclesPage._selectedCardColor : CirclesPage._cardBorderColor;
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: CirclesPage._cardIconBackground,
                    child: Icon(icon, color: Colors.black87, size: 28),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              if (selected)
                const Positioned(
                  right: 0,
                  top: 0,
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.check_circle,
                      size: 18,
                      color: CirclesPage._activeStepColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
