import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contacts/domain/contact_cadence.dart';
import '../../../contacts/domain/contact_circle.dart';
import '../providers/cadence_settings_provider.dart';
import '../widgets/cadence_selector.dart';

class CadenceSettingsPage extends ConsumerWidget {
  const CadenceSettingsPage({super.key});

  static const routeName = '/settings/cadence';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadenceState = ref.watch(cadenceSettingsProvider);

    Future<void> handleSave() async {
      final saved = await ref.read(cadenceSettingsProvider.notifier).persist();
      if (!context.mounted) {
        return;
      }
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Impossible d'enregistrer la cadence.")),
        );
      }
    }

    return cadenceState.when(
      data: (cadences) {
        return Scaffold(
          body: SafeArea(
            child: CadenceSettingsContent(
              cadences: cadences,
              onCadenceSelected: (circle, cadenceDays) {
                ref
                    .read(cadenceSettingsProvider.notifier)
                    .updateCadence(circle, cadenceDays);
              },
              onSavePressed: handleSave,
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: SafeArea(
          child: Center(child: CircularProgressIndicator()),
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
                    ref.invalidate(cadenceSettingsProvider);
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

class CadenceSettingsContent extends StatelessWidget {
  const CadenceSettingsContent({
    super.key,
    required this.cadences,
    required this.onCadenceSelected,
    required this.onSavePressed,
  });

  final List<ContactCadence> cadences;
  final void Function(ContactCircle circle, int cadenceDays) onCadenceSelected;
  final VoidCallback onSavePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
              const SizedBox(width: 4),
              Text(
                'Cadence',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Definissez un rythme par categorie pour adapter les rappels.',
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                for (final cadence in cadences) ...[
                  CadenceSelector(
                    circle: cadence.circle,
                    selectedDays: cadence.cadenceDays,
                    onChanged: (days) {
                      onCadenceSelected(cadence.circle, days);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: theme.dividerColor),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onSavePressed,
              child: const Text('Enregistrer'),
            ),
          ),
        ),
      ],
    );
  }
}
