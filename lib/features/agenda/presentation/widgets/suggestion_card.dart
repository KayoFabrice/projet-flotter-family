import 'package:flutter/material.dart';

import '../../../reminders/domain/suggestion_selector.dart';

class SuggestionCard extends StatelessWidget {
  const SuggestionCard({
    super.key,
    required this.decision,
    this.onWrite,
    this.onCall,
    this.onLater,
    this.onNotNow,
  });

  final SuggestionDecision decision;
  final VoidCallback? onWrite;
  final VoidCallback? onCall;
  final VoidCallback? onLater;
  final VoidCallback? onNotNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactName = decision.contact?.displayName ?? 'Contact';
    final message = decision.message;

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggestion prioritaire',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              contactName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message ?? 'Prenez des nouvelles rapidement.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: onWrite,
                  child: const Text('Ecrire'),
                ),
                OutlinedButton(
                  onPressed: onCall,
                  child: const Text('Appeler'),
                ),
                TextButton(
                  onPressed: onLater,
                  child: const Text('Plus tard'),
                ),
                TextButton(
                  onPressed: onNotNow,
                  child: const Text('Pas le bon moment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
