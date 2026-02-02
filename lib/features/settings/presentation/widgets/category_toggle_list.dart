import 'package:flutter/material.dart';

import '../../../contacts/domain/contact_circle.dart';

class CategoryToggleList extends StatelessWidget {
  const CategoryToggleList({
    super.key,
    required this.isCategoryEnabled,
    required this.onChanged,
  });

  final bool Function(ContactCircle circle) isCategoryEnabled;
  final void Function(ContactCircle circle, bool enabled) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final circle in ContactCircle.values)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: SwitchListTile(
              value: isCategoryEnabled(circle),
              onChanged: (value) => onChanged(circle, value),
              title: Text(
                circle.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              dense: true,
            ),
          ),
      ],
    );
  }
}
