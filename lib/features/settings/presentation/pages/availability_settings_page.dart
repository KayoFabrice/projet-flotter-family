import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/time_slot_preset.dart';
import '../providers/time_slot_settings_provider.dart';

class AvailabilitySettingsPage extends ConsumerWidget {
  const AvailabilitySettingsPage({super.key});

  static const routeName = '/settings/time-slots';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(timeSlotSettingsProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);

    return state.when(
      data: (selection) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _Header(title: 'Plages horaires'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Choisissez les moments ou vous preferez recevoir vos suggestions de contact. Nous eviterons de vous deranger en dehors de ces heures.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final preset in selection.presets)
                      _TimeSlotCard(
                        preset: preset,
                        selected: selection.isSelected(preset.key),
                        onTap: () async {
                          ref
                              .read(timeSlotSettingsProvider.notifier)
                              .togglePreset(preset.key);
                          await ref
                              .read(timeSlotSettingsProvider.notifier)
                              .persist();
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const Scaffold(
        body: SafeArea(child: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Erreur de chargement des plages horaires.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(timeSlotSettingsProvider);
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

class _Header extends StatelessWidget {
  const _Header({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _TimeSlotCard extends StatelessWidget {
  const _TimeSlotCard({
    required this.preset,
    required this.selected,
    required this.onTap,
  });

  final TimeSlotPreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor;
    final background = selected
        ? theme.colorScheme.secondary.withOpacity(0.6)
        : theme.cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preset.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preset.subLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: const Icon(Icons.check, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
