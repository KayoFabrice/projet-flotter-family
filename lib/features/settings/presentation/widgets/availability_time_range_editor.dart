import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/availability_provider.dart';
import '../../domain/availability_window.dart';

class AvailabilityTimeRangeEditor extends ConsumerWidget {
  const AvailabilityTimeRangeEditor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);
    final border = theme.dividerColor;
    final card = theme.cardColor;

    final availabilityState = ref.watch(availabilityProvider);

    return availabilityState.when(
      data: (windows) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Definir vos disponibilites',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Ajoutez des plages horaires autorisees pour les rappels.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: muted,
                  ),
            ),
            const SizedBox(height: 16),
            if (windows.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Text(
                  'Aucune plage definie.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: muted,
                      ),
                ),
              )
            else
              Column(
                children: [
                  for (var i = 0; i < windows.length; i++)
                    _AvailabilityRow(
                      window: windows[i],
                      onEdit: () => _editWindow(context, ref, i, windows[i]),
                      onDelete: () => ref
                          .read(availabilityProvider.notifier)
                          .removeWindow(i),
                    ),
                ],
              ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _addWindow(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une plage'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                final success =
                    await ref.read(availabilityProvider.notifier).persist();
                if (!context.mounted) {
                  return;
                }
                if (!success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Plages horaires invalides.'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Enregistrer mes disponibilites'),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => Column(
        children: [
          const Text('Erreur de chargement des disponibilites.'),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(availabilityProvider),
            child: const Text('Reessayer'),
          ),
        ],
      ),
    );
  }

  Future<void> _addWindow(BuildContext context, WidgetRef ref) async {
    final window = await _pickWindow(context);
    if (window == null) {
      return;
    }
    ref.read(availabilityProvider.notifier).addWindow(window);
  }

  Future<void> _editWindow(
    BuildContext context,
    WidgetRef ref,
    int index,
    AvailabilityWindow current,
  ) async {
    final window = await _pickWindow(
      context,
      initialStart: _minuteToTime(current.startMinute),
      initialEnd: _minuteToTime(current.endMinute),
    );
    if (window == null) {
      return;
    }
    ref.read(availabilityProvider.notifier).updateWindow(index, window);
  }

  Future<AvailabilityWindow?> _pickWindow(
    BuildContext context, {
    TimeOfDay? initialStart,
    TimeOfDay? initialEnd,
  }) async {
    final start = await showTimePicker(
      context: context,
      initialTime: initialStart ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (start == null) {
      return null;
    }
    final end = await showTimePicker(
      context: context,
      initialTime: initialEnd ?? const TimeOfDay(hour: 12, minute: 0),
    );
    if (end == null) {
      return null;
    }
    final startMinute = start.hour * 60 + start.minute;
    final endMinute = end.hour * 60 + end.minute;
    if (startMinute >= endMinute) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fin doit etre apres le debut.'),
        ),
      );
      return null;
    }
    return AvailabilityWindow(startMinute: startMinute, endMinute: endMinute);
  }

  TimeOfDay _minuteToTime(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    return TimeOfDay(hour: hour, minute: minute);
  }
}

class _AvailabilityRow extends StatelessWidget {
  const _AvailabilityRow({
    required this.window,
    required this.onEdit,
    required this.onDelete,
  });

  final AvailabilityWindow window;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _formatWindow(context, window),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }

  String _formatWindow(BuildContext context, AvailabilityWindow window) {
    final start = _formatMinutes(window.startMinute);
    final end = _formatMinutes(window.endMinute);
    return '$start - $end';
  }

  String _formatMinutes(int minutes) {
    final hour = minutes ~/ 60;
    final minute = minutes % 60;
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
