import 'package:flutter/material.dart';

import '../../domain/contact_circle.dart';

class CircleSelectorSheet extends StatefulWidget {
  const CircleSelectorSheet({super.key, required this.initialCircle});

  final ContactCircle initialCircle;

  static Future<ContactCircle?> show(
    BuildContext context, {
    required ContactCircle initialCircle,
  }) {
    return showModalBottomSheet<ContactCircle>(
      context: context,
      showDragHandle: true,
      builder: (_) => CircleSelectorSheet(initialCircle: initialCircle),
    );
  }

  @override
  State<CircleSelectorSheet> createState() => _CircleSelectorSheetState();
}

class _CircleSelectorSheetState extends State<CircleSelectorSheet> {
  late ContactCircle _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCircle;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Changer de catégorie',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...ContactCircle.values.map(
              (circle) => RadioListTile<ContactCircle>(
                value: circle,
                groupValue: _selected,
                title: Text(circle.label),
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }
                  setState(() {
                    _selected = value;
                  });
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annuler'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _selected == widget.initialCircle
                      ? null
                      : () {
                          Navigator.of(context).pop(_selected);
                        },
                  child: const Text('Confirmer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
