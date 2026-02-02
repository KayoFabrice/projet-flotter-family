import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../contacts/domain/contact_cadence.dart';
import '../../../contacts/domain/contact_circle.dart';
import '../providers/cadence_settings_provider.dart';
import 'cadence_settings_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cadenceState = ref.watch(cadenceSettingsProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const SizedBox(width: 32),
                  Expanded(
                    child: Text(
                      'Réglages',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _ProfileCard(muted: muted),
                  const SizedBox(height: 16),
                  _SectionLabel(title: 'Préférences', muted: muted),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    icon: Icons.auto_awesome,
                    title: 'Cadence',
                    subtitle: 'Fréquence des rappels principaux',
                    value: cadenceState.maybeWhen(
                      data: (cadences) {
                        final proches = cadences.firstWhere(
                          (cadence) => cadence.circle == ContactCircle.proches,
                          orElse: () => const ContactCadence(
                            circle: ContactCircle.proches,
                            cadenceDays: 7,
                          ),
                        );
                        return _formatCadenceValue(proches.cadenceDays);
                      },
                      orElse: () => '...',
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CadenceSettingsPage(),
                        ),
                      );
                    },
                  ),
                  _SettingsCard(
                    icon: Icons.schedule,
                    title: 'Plages horaires',
                    subtitle: 'Heures de notification preferees',
                    value: '18h - 20h',
                  ),
                  _SettingsCard(
                    icon: Icons.category_outlined,
                    title: 'Categories',
                    subtitle: 'Famille, amis proches, autres',
                  ),
                  const SizedBox(height: 8),
                  _SectionLabel(title: 'Systeme', muted: muted),
                  const SizedBox(height: 8),
                  _SettingsCard(
                    icon: Icons.shield_outlined,
                    title: 'Permissions',
                    subtitle: 'Contacts, localisation, notifications',
                    value: '2 actives',
                  ),
                  _SettingsCard(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    subtitle: 'Sons, vibrations, badges',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCadenceValue(int days) {
    switch (days) {
      case 7:
        return 'Hebdo';
      case 14:
        return 'Bi-hebdo';
      case 30:
        return 'Mensuel';
      default:
        return '${days} j';
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.muted});

  final Color muted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            child: Text(
              'A',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alexandre',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Compte gratuit',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.dividerColor),
            ),
            child: Icon(
              Icons.edit,
              size: 18,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.muted});

  final String title;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: muted,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: theme.colorScheme.onSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              if (value != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    value!,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ),
              Icon(Icons.chevron_right, size: 18, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
