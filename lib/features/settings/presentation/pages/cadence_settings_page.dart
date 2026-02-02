import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/global_cadence.dart';
import '../providers/global_cadence_provider.dart';

class CadenceSettingsPage extends ConsumerWidget {
  const CadenceSettingsPage({super.key});

  static const routeName = '/settings/cadence';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(globalCadenceProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);

    return state.when(
      data: (cadence) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _Header(title: 'Cadence'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'Frequence globale',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: muted,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.dividerColor),
                      ),
                      child: Column(
                        children: [
                          for (final option in cadence.options)
                            _CadenceRow(
                              option: option,
                              selected: option.key == cadence.selectedKey,
                              isLast: option == cadence.options.last,
                              onTap: () async {
                                ref
                                    .read(globalCadenceProvider.notifier)
                                    .select(option.key);
                                await ref
                                    .read(globalCadenceProvider.notifier)
                                    .persist();
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cette frequence determine la regularite des rappels pour vos contacts principaux. Vous pouvez ajuster la cadence pour chaque contact individuellement.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
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
                const Text('Erreur de chargement de la cadence.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(globalCadenceProvider);
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

class _CadenceRow extends StatelessWidget {
  const _CadenceRow({
    required this.option,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  final GlobalCadenceOption option;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isLast ? Colors.transparent : theme.dividerColor,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? theme.colorScheme.primary : null,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check, size: 20),
          ],
        ),
      ),
    );
  }
}
