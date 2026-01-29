import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/permissions/contacts_permission_service.dart';
import '../providers/contacts_import_provider.dart';
import '../providers/contacts_permission_provider.dart';
import '../widgets/contacts_import_list.dart';
import '../../domain/onboarding_step.dart';
import '../providers/onboarding_step_provider.dart';
import 'location_page.dart';

class ImportContactsPage extends ConsumerWidget {
  const ImportContactsPage({super.key});

  static const routeName = '/onboarding/import-contacts';
  static const _degradedMessage =
      "Mode degrade active. Vous pourrez activer l'import dans les reglages plus tard.";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final importState = ref.watch(contactsImportProvider);

    Future<void> handleImport() async {
      final service = ref.read(contactsPermissionServiceProvider);
      final status = await service.requestContactsPermission();
      if (!context.mounted) {
        return;
      }
      switch (status) {
        case ContactsPermissionStatus.granted:
          await ref.read(contactsImportProvider.notifier).loadContacts();
          return;
        case ContactsPermissionStatus.denied:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(_degradedMessage),
            ),
          );
          return;
        case ContactsPermissionStatus.permanentlyDenied:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(_degradedMessage),
              action: SnackBarAction(
                label: 'Ouvrir les reglages',
                onPressed: () {
                  service.openSettings();
                },
              ),
            ),
          );
          return;
      }
    }

    Future<void> handleConfirmSelection() async {
      final success = await ref.read(contactsImportProvider.notifier).persistSelection();
      if (!context.mounted) {
        return;
      }
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Impossible d'importer les contacts."),
          ),
        );
        return;
      }
      await _goToNextStep(ref, context);
    }

    Future<void> handleSkip() async {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(_degradedMessage),
        ),
      );
      await _goToNextStep(ref, context);
    }

    return importState.when(
      data: (state) {
        return Scaffold(
          backgroundColor: ImportContactsContent.pageBackground,
          body: SafeArea(
            child: ImportContactsContent(
              state: state,
              onImportPressed: handleImport,
              onSkipPressed: () => handleSkip(),
              onQueryChanged: (value) {
                ref.read(contactsImportProvider.notifier).updateQuery(value);
              },
              onToggleSelection: (contactId) {
                ref.read(contactsImportProvider.notifier).toggleSelection(contactId);
              },
              onConfirmSelection: handleConfirmSelection,
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
                const Text('Erreur de chargement des contacts.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(contactsImportProvider);
                  },
                  child: const Text('Reessayer'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => handleSkip(),
                  child: const Text('Continuer sans importer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _goToNextStep(WidgetRef ref, BuildContext context) async {
  final saved = await ref
      .read(onboardingStepProvider.notifier)
      .setStep(OnboardingStep.locationOrAvailability);
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
  await Navigator.of(context).pushReplacementNamed(LocationPage.routeName);
}

class ImportContactsContent extends StatelessWidget {
  const ImportContactsContent({
    super.key,
    required this.state,
    required this.onImportPressed,
    required this.onSkipPressed,
    required this.onQueryChanged,
    required this.onToggleSelection,
    required this.onConfirmSelection,
  });

  final ContactsImportState state;
  final VoidCallback onImportPressed;
  final VoidCallback onSkipPressed;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onToggleSelection;
  final VoidCallback onConfirmSelection;

  static const pageBackground = Color(0xFFFBFCFD);
  static const _activeStepColor = Color(0xFF4C6EF5);
  static const _inactiveStepColor = Color(0xFFF1F5F9);
  static const _muted = Color(0xFF8B95A1);
  static const _border = Color(0xFFE5E7EB);
  static const _cardBackground = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    final showSelection = state.hasRequestedImport;
    final primaryLabel =
        showSelection ? 'Importer la selection' : 'Autoriser et importer';
    final primaryEnabled =
        showSelection ? state.selectedIds.isNotEmpty : true;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: const _StepIndicator(),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: showSelection
                ? ContactsImportList(
                    contacts: state.filteredContacts,
                    selectedIds: state.selectedIds,
                    onToggleSelection: onToggleSelection,
                    query: state.query,
                    onQueryChanged: onQueryChanged,
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: _inactiveStepColor,
                          borderRadius: BorderRadius.circular(48),
                        ),
                        child: const Icon(
                          Icons.group_outlined,
                          size: 40,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Simplifiez-vous la vie',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Importez vos contacts pour construire votre agenda relationnel sans effort manuel.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: _muted,
                              height: 1.6,
                            ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _cardBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 14,
                              color: _muted,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Nous n'ecrirons jamais a votre place.",
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: _muted,
                                  ),
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
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _activeStepColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: primaryEnabled
                      ? (showSelection ? onConfirmSelection : onImportPressed)
                      : null,
                  child: Text(primaryLabel),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onSkipPressed,
                  style: TextButton.styleFrom(
                    foregroundColor: _muted,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Continuer sans importer'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
              ? ImportContactsContent._activeStepColor
              : ImportContactsContent._inactiveStepColor,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
