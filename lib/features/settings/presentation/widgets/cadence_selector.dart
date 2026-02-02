import 'package:flutter/material.dart';

import '../../../contacts/domain/contact_circle.dart';

class CadenceSelector extends StatelessWidget {
  const CadenceSelector({
    super.key,
    required this.circle,
    required this.selectedDays,
    required this.onChanged,
  });

  final ContactCircle circle;
  final int selectedDays;
  final ValueChanged<int> onChanged;

  static const _options = [7, 14, 30];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            circle.label,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _subtitleFor(circle),
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final option in _options)
                ChoiceChip(
                  key: ValueKey('cadence-${circle.storageValue}-$option'),
                  label: Text(_labelFor(option)),
                  selected: selectedDays == option,
                  onSelected: (_) => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelFor(int days) {
    switch (days) {
      case 7:
        return '7 j';
      case 14:
        return '14 j';
      case 30:
        return '30 j';
      default:
        return '${days} j';
    }
  }

  String _subtitleFor(ContactCircle circle) {
    switch (circle) {
      case ContactCircle.proches:
        return 'Rythme recommande pour les liens forts.';
      case ContactCircle.eloignes:
        return 'Un rappel plus espacé pour garder le fil.';
      case ContactCircle.partenaire:
        return 'Une cadence stable et réguliere.';
      case ContactCircle.amis:
        return 'Pour rester present sans surcharge.';
    }
  }
}
