import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/settings_category.dart';
import '../providers/categories_settings_provider.dart';

class CategoriesSettingsPage extends ConsumerStatefulWidget {
  const CategoriesSettingsPage({super.key});

  static const routeName = '/settings/categories';

  @override
  ConsumerState<CategoriesSettingsPage> createState() =>
      _CategoriesSettingsPageState();
}

class _CategoriesSettingsPageState
    extends ConsumerState<CategoriesSettingsPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesSettingsProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);

    return state.when(
      data: (categories) => Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _Header(title: 'Categories'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Definissez le cercle relationnel de ce contact. Cela peut nous aider a mieux organiser votre agenda.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: muted,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    for (final category in categories)
                      _CategoryCard(
                        category: category,
                        onTap: () async {
                          ref
                              .read(categoriesSettingsProvider.notifier)
                              .toggle(category.id);
                          await ref
                              .read(categoriesSettingsProvider.notifier)
                              .persist();
                        },
                      ),
                    const SizedBox(height: 24),
                    Divider(color: theme.dividerColor, height: 1),
                    const SizedBox(height: 16),
                    Text(
                      'Ajouter une categorie',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Nom de la nouvelle categorie',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            _controller.clear();
                          },
                          child: Text(
                            'Annuler',
                            style: TextStyle(color: muted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: () async {
                            final text = _controller.text;
                            if (text.trim().isEmpty) {
                              return;
                            }
                            ref
                                .read(categoriesSettingsProvider.notifier)
                                .addCategory(text);
                            await ref
                                .read(categoriesSettingsProvider.notifier)
                                .persist();
                            _controller.clear();
                          },
                          child: const Text('Enregistrer'),
                        ),
                      ],
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
                const Text('Erreur de chargement des categories.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    ref.invalidate(categoriesSettingsProvider);
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

  final SettingsCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withOpacity(0.6);
    final selected = category.isActive;
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.dividerColor;
    final background = selected
        ? theme.colorScheme.secondary.withOpacity(0.4)
        : theme.cardColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (category.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        category.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              AnimatedOpacity(
                opacity: selected ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: const Icon(Icons.check, size: 22),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
