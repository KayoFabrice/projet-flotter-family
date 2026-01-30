import 'package:flutter/material.dart';

import '../../domain/contact.dart';

class ContactListItem extends StatelessWidget {
  const ContactListItem({
    super.key,
    required this.contact,
    required this.subtitle,
    required this.mutedText,
    this.onMorePressed,
  });

  final Contact contact;
  final String subtitle;
  final Color mutedText;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _initials(contact.displayName);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            child: Text(
              initials,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.displayName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onMorePressed,
            icon: const Icon(Icons.more_horiz),
            color: mutedText,
          ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) {
      return '?';
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    final combined = (first + second).toUpperCase();
    return combined.isEmpty ? '?' : combined;
  }
}
