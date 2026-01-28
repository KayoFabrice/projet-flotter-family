import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact.dart';
import '../../domain/contact_circle.dart';
import '../../domain/onboarding_step.dart';
import '../providers/onboarding_contacts_provider.dart';
import '../providers/selected_circles_provider.dart';
import '../providers/onboarding_step_provider.dart';
import '../widgets/onboarding_contact_form.dart';
import 'cadence_page.dart';

class FirstContactsPage extends ConsumerWidget {
  const FirstContactsPage({super.key});

  static const routeName = '/onboarding/first-contacts';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final circlesState = ref.watch(selectedCirclesProvider);
    final contactsState = ref.watch(onboardingContactsProvider);

    Future<void> openAddContactSheet({
      required List<ContactCircle> availableCircles,
    }) async {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: OnboardingContactForm(
              availableCircles: availableCircles,
              onSubmit: (displayName, circle) async {
                Navigator.of(context).pop();
                final success =
                    await ref.read(onboardingContactsProvider.notifier).addContact(
                          displayName: displayName,
                          circle: circle,
                        );
                if (!context.mounted) {
                  return;
                }
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Impossible d'enregistrer le proche."),
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    }

    Future<void> handleContinue(
      List<Contact> contacts,
      List<ContactCircle> selectedCircles,
    ) async {
      if (contacts.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Ajoutez au moins un proche.'),
            action: SnackBarAction(
              label: 'Ajouter',
              onPressed: () {
                openAddContactSheet(availableCircles: selectedCircles);
              },
            ),
          ),
        );
        return;
      }

      final stepSaved = await ref
          .read(onboardingStepProvider.notifier)
          .setStep(OnboardingStep.cadence);

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
        CadencePage.routeName,
      );
    }

    return circlesState.when(
      data: (selectedCircles) {
        final circleOptions = ContactCircle.values.toList();
        return contactsState.when(
          data: (contacts) {
            return Scaffold(
              backgroundColor: FirstContactsContent.pageBackground,
              body: SafeArea(
                child: FirstContactsContent(
                  contacts: contacts,
                  onAddPressed: () {
                    openAddContactSheet(availableCircles: circleOptions);
                  },
                  onContinuePressed: () {
                    handleContinue(contacts, selectedCircles);
                  },
                ),
              ),
            );
          },
          loading: () {
            return Scaffold(
              backgroundColor: FirstContactsContent.pageBackground,
              body: SafeArea(
                child: FirstContactsContent(
                  contacts: const [],
                  onAddPressed: () {
                    openAddContactSheet(availableCircles: circleOptions);
                  },
                  onContinuePressed: () {
                    handleContinue(const [], selectedCircles);
                  },
                ),
              ),
            );
          },
          error: (error, stackTrace) => Scaffold(
            body: SafeArea(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Erreur de chargement des contacts.'),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: () {
                        ref.invalidate(onboardingContactsProvider);
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
}

class FirstContactsContent extends StatelessWidget {
  const FirstContactsContent({
    super.key,
    required this.contacts,
    required this.onAddPressed,
    required this.onContinuePressed,
  });

  final List<Contact> contacts;
  final VoidCallback onAddPressed;
  final VoidCallback onContinuePressed;

  static const pageBackground = Color(0xFFF6F7F3);
  static const _activeStepColor = Color(0xFF4C6FFF);
  static const _inactiveStepColor = Color(0xFFE2E8F0);
  static const _cardBorderColor = Color(0xFFE2E8F0);
  static const _cardIconBackground = Color(0xFFF2F4F8);

  @override
  Widget build(BuildContext context) {
    final canAddMore = contacts.length < 3;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StepIndicator(),
          const SizedBox(height: 28),
          Text(
            'Premiers contacts',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez vos premiers proches',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Ajoutez 1 a 3 proches pour demarrer votre agenda relationnel.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              itemCount: contacts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _ContactCard(contact: contact);
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: canAddMore ? onAddPressed : null,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                side: const BorderSide(color: _inactiveStepColor),
              ),
              child: const Text('Ajouter un proche'),
            ),
          ),
          const SizedBox(height: 12),
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.contact});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: FirstContactsContent._cardBorderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: FirstContactsContent._cardIconBackground,
            child: const Icon(Icons.person, color: Colors.black87),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  contact.circle.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
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
              ? FirstContactsContent._activeStepColor
              : FirstContactsContent._inactiveStepColor,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
