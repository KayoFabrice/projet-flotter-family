import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/contact.dart';
import '../../domain/contact_circle.dart';
import '../../domain/contact_history_entry.dart';
import '../providers/contact_detail_provider.dart';
import '../widgets/circle_selector_sheet.dart';
import 'contact_edit_page.dart';

class ContactDetailArgs {
  const ContactDetailArgs({required this.contactId});

  final String contactId;
}

class ContactDetailPage extends ConsumerWidget {
  const ContactDetailPage({super.key, this.args});

  static const routeName = '/contacts/detail';

  final ContactDetailArgs? args;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedArgs = args ??
        ModalRoute.of(context)?.settings.arguments as ContactDetailArgs?;
    final contactId = resolvedArgs?.contactId;
    if (contactId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Contact introuvable.'),
        ),
      );
    }

    final contactState = ref.watch(contactDetailProvider(contactId));
    return Scaffold(
      body: SafeArea(
        child: contactState.when(
          data: (state) => _ContactDetailBody(
            contact: state.contact,
            cadenceDays: state.cadenceDays,
            nextSuggestedAt: state.nextSuggestedAt,
            recentHistory: state.recentHistory,
            isUpdating: state.isUpdating,
            onEdit: () async {
              final result = await Navigator.of(context).pushNamed(
                ContactEditPage.editRouteName,
                arguments: ContactEditArgs.edit(contactId: contactId),
              );
              if (result == ContactEditResult.deleted && context.mounted) {
                Navigator.of(context).pop();
              }
            },
            onChangeCategory: () async {
              final selected = await CircleSelectorSheet.show(
                context,
                initialCircle: state.contact.circle,
              );
              if (selected == null || !context.mounted) {
                return;
              }
              if (selected == state.contact.circle) {
                return;
              }
              final updated = await ref
                  .read(contactDetailProvider(contactId).notifier)
                  .updateContactCircle(selected);
              if (!context.mounted) {
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    updated
                        ? 'Catégorie mise à jour.'
                        : 'Impossible de mettre à jour la catégorie.',
                  ),
                ),
              );
            },
          ),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Erreur de chargement du contact.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(contactDetailProvider(contactId));
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactDetailBody extends StatelessWidget {
  const _ContactDetailBody({
    required this.contact,
    required this.cadenceDays,
    required this.nextSuggestedAt,
    required this.recentHistory,
    required this.isUpdating,
    required this.onEdit,
    required this.onChangeCategory,
  });

  final Contact contact;
  final int cadenceDays;
  final DateTime? nextSuggestedAt;
  final List<ContactHistoryEntry> recentHistory;
  final bool isUpdating;
  final VoidCallback onEdit;
  final VoidCallback onChangeCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedText = theme.colorScheme.onSurface.withOpacity(0.6);
    final initials = _initials(contact.displayName);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      children: [
        _HeaderRow(onEdit: onEdit),
        const SizedBox(height: 12),
        _ProfileSection(
          initials: initials,
          displayName: contact.displayName,
          relationLabel: contact.circle.label,
        ),
        const SizedBox(height: 16),
        _CategoryCard(
          value: contact.circle.label,
          onChange: isUpdating ? null : onChangeCategory,
        ),
        const SizedBox(height: 24),
        _ActionsGrid(
          onWrite: () => _showWriteOptions(context),
          onCall: contact.phone == null
              ? null
              : () => _launchUri(
                    context,
                    Uri(scheme: 'tel', path: contact.phone),
                  ),
        ),
        const SizedBox(height: 28),
        _StatsCard(
          mutedText: mutedText,
          lastContact: 'Non renseigné',
          cadence: _formatCadenceDays(cadenceDays),
          nextSuggested: _formatNextSuggested(nextSuggestedAt),
        ),
        const SizedBox(height: 28),
        _HistorySection(
          mutedText: mutedText,
          items: recentHistory.map(_mapHistoryEntry).toList(),
        ),
      ],
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

  void _showWriteOptions(BuildContext context) {
    final options = <_LaunchOption>[];
    final phone = contact.phone?.trim();
    final email = contact.email?.trim();
    if (phone != null && phone.isNotEmpty) {
      options.add(
        _LaunchOption(
          label: 'Écrire par SMS',
          uri: Uri(scheme: 'sms', path: phone),
        ),
      );
    }
    if (email != null && email.isNotEmpty) {
      options.add(
        _LaunchOption(
          label: 'Écrire par email',
          uri: Uri(scheme: 'mailto', path: email),
        ),
      );
    }
    if (options.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez un numéro ou un email pour écrire.'),
        ),
      );
      return;
    }
    if (options.length == 1) {
      _launchUri(context, options.first.uri);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                title: Text(option.label),
                subtitle: Text(option.uri.toString()),
                onTap: () {
                  Navigator.of(context).pop();
                  _launchUri(context, option.uri);
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemCount: options.length,
          ),
        );
      },
    );
  }

  String _formatCadenceDays(int cadenceDays) {
    if (cadenceDays <= 0) {
      return 'Non renseignée';
    }
    switch (cadenceDays) {
      case 7:
        return '1 semaine';
      case 14:
        return '2 semaines';
      case 30:
        return '1 mois';
      default:
        return '$cadenceDays jours';
    }
  }

  String _formatNextSuggested(DateTime? nextSuggestedAt) {
    if (nextSuggestedAt == null) {
      return 'Non renseigné';
    }
    final now = DateTime.now();
    final nextLocal = nextSuggestedAt.toLocal();
    if (_isSameDate(nextLocal, now)) {
      return "Aujourd'hui";
    }
    final today = DateTime(now.year, now.month, now.day);
    final deltaDays = nextLocal.difference(today).inDays;
    if (deltaDays == 1) {
      return 'Demain';
    }
    if (deltaDays > 1 && deltaDays <= 7) {
      return 'Dans $deltaDays jours';
    }
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final monthLabel = nextLocal.month >= 1 && nextLocal.month <= 12
        ? months[nextLocal.month - 1]
        : '';
    return '${nextLocal.day} $monthLabel';
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  _HistoryItem _mapHistoryEntry(ContactHistoryEntry entry) {
    switch (entry.actionType) {
      case 'call':
        return _HistoryItem(
          title: 'Appel sortant',
          dateLabel: _formatHistoryDate(entry.occurredAt),
          icon: Icons.phone,
        );
      case 'message':
        return _HistoryItem(
          title: 'Message',
          dateLabel: _formatHistoryDate(entry.occurredAt),
          icon: Icons.message,
        );
      case 'meeting':
        return _HistoryItem(
          title: 'Rencontre',
          dateLabel: _formatHistoryDate(entry.occurredAt),
          icon: Icons.calendar_today,
        );
      default:
        return _HistoryItem(
          title: 'Action',
          dateLabel: _formatHistoryDate(entry.occurredAt),
          icon: Icons.history,
        );
    }
  }

  String _formatHistoryDate(String isoDate) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) {
      return isoDate;
    }
    const months = [
      'janvier',
      'février',
      'mars',
      'avril',
      'mai',
      'juin',
      'juillet',
      'août',
      'septembre',
      'octobre',
      'novembre',
      'décembre',
    ];
    final monthLabel =
        parsed.month >= 1 && parsed.month <= 12 ? months[parsed.month - 1] : '';
    return '${parsed.day} $monthLabel';
  }

  Future<void> _launchUri(BuildContext context, Uri uri) async {
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action indisponible sur cet appareil.'),
          ),
        );
      }
      return;
    }
    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir l\'application.'),
        ),
      );
    }
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back),
        ),
        TextButton(
          onPressed: onEdit,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          ),
          child: const Text('Modifier'),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.initials,
    required this.displayName,
    required this.relationLabel,
  });

  final String initials;
  final String displayName;
  final String relationLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.secondary,
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            relationLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.value,
    required this.onChange,
  });

  final String value;
  final VoidCallback? onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mutedText = theme.colorScheme.onSurface.withOpacity(0.6);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catégorie',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text('Changer'),
          ),
        ],
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  const _ActionsGrid({
    required this.onWrite,
    required this.onCall,
  });

  final VoidCallback onWrite;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            label: 'Écrire',
            icon: Icons.message,
            isPrimary: true,
            onTap: onWrite,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            label: 'Appeler',
            icon: Icons.phone,
            isPrimary: false,
            onTap: onCall,
            disabledColor: theme.disabledColor,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
    this.disabledColor,
  });

  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onTap;
  final Color? disabledColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = isPrimary ? theme.colorScheme.primary : theme.cardColor;
    final foreground = isPrimary
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;
    final borderColor =
        isPrimary ? theme.colorScheme.primary : theme.dividerColor;

    final isDisabled = onTap == null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isDisabled ? theme.disabledColor.withOpacity(0.08) : background,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDisabled ? theme.dividerColor : borderColor,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isDisabled ? disabledColor : foreground),
            const SizedBox(height: 10),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDisabled ? disabledColor : foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.mutedText,
    required this.lastContact,
    required this.cadence,
    required this.nextSuggested,
  });

  final Color mutedText;
  final String lastContact;
  final String cadence;
  final String nextSuggested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          _StatRow(
            label: 'Dernier contact',
            value: lastContact,
            mutedText: mutedText,
          ),
          _StatRow(
            label: 'Cadence',
            value: cadence,
            mutedText: mutedText,
            trailing: const Icon(Icons.chevron_right, size: 18),
          ),
          _StatRow(
            label: 'Prochain',
            value: nextSuggested,
            mutedText: mutedText,
            leading: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.mutedText,
    this.leading,
    this.trailing,
  });

  final String label;
  final String value;
  final Color mutedText;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: mutedText,
              fontWeight: FontWeight.w600,
            ),
          ),
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 8),
              ],
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                IconTheme(
                  data: IconThemeData(
                    color: mutedText,
                  ),
                  child: trailing!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.mutedText,
    required this.items,
  });

  final Color mutedText;
  final List<_HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Historique récent',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: mutedText,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Text(
              'Aucune action récente.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedText,
              ),
            ),
          )
        else
          Column(
            children: items
                .map(
                  (item) => _HistoryTile(item: item, mutedText: mutedText),
                )
                .toList(),
          ),
      ],
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.item,
    required this.mutedText,
  });

  final _HistoryItem item;
  final Color mutedText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.dateLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: mutedText,
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

class _HistoryItem {
  const _HistoryItem({
    required this.title,
    required this.dateLabel,
    required this.icon,
  });

  final String title;
  final String dateLabel;
  final IconData icon;
}

class _LaunchOption {
  const _LaunchOption({required this.label, required this.uri});

  final String label;
  final Uri uri;
}
