import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/contact.dart';
import '../../domain/contact_circle.dart';
import '../providers/contacts_provider.dart';
import '../widgets/contact_list_item.dart';
import 'contact_edit_page.dart';

class ContactsPage extends ConsumerStatefulWidget {
  const ContactsPage({super.key});

  static const routeName = '/contacts';

  @override
  ConsumerState<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends ConsumerState<ContactsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(contactsProvider, (previous, next) {
      final wasError = previous?.hasError ?? false;
      if (next.hasError && !wasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible de charger les proches.'),
          ),
        );
      }
    });

    final contactsState = ref.watch(contactsProvider);
    final theme = Theme.of(context);
    final mutedText = theme.colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Mes Proches',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          ContactEditPage.routeName,
                        );
                      },
                      icon: const Icon(Icons.add),
                      color: theme.colorScheme.onSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un contact...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  ref.read(contactsProvider.notifier).updateQuery(value);
                },
              ),
            ),
            Expanded(
              child: contactsState.when(
                data: (state) {
                  if (state.allContacts.isEmpty) {
                    return _EmptyContactsState(mutedText: mutedText);
                  }
                  if (state.filteredContacts.isEmpty) {
                    return _EmptySearchState(mutedText: mutedText);
                  }
                  return _ContactsList(
                    contacts: state.filteredContacts,
                    mutedText: mutedText,
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, stackTrace) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Erreur de chargement des proches.'),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: () {
                            ref.read(contactsProvider.notifier).refresh();
                          },
                          child: const Text('Reessayer'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactsList extends StatelessWidget {
  const _ContactsList({
    required this.contacts,
    required this.mutedText,
  });

  final List<Contact> contacts;
  final Color mutedText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = _groupByCircle(contacts);
    final children = <Widget>[];

    for (final section in sections.entries) {
      if (section.value.isEmpty) {
        continue;
      }
      children.add(
        _SectionHeader(
          title: _circleTitle(section.key),
          count: section.value.length,
          mutedText: mutedText,
        ),
      );
      children.addAll(
        section.value.map(
          (contact) => ContactListItem(
            contact: contact,
            subtitle: _circleSubtitle(contact.circle),
            mutedText: mutedText,
          ),
        ),
      );
      children.add(const SizedBox(height: 20));
    }

    children.add(const _SyncPromoCard());

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      itemBuilder: (context, index) => children[index],
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemCount: children.length,
    );
  }

  Map<ContactCircle, List<Contact>> _groupByCircle(List<Contact> contacts) {
    final grouped = {
      ContactCircle.proches: <Contact>[],
      ContactCircle.eloignes: <Contact>[],
      ContactCircle.partenaire: <Contact>[],
      ContactCircle.amis: <Contact>[],
    };
    for (final contact in contacts) {
      grouped[contact.circle]?.add(contact);
    }
    return grouped;
  }

  String _circleTitle(ContactCircle circle) {
    switch (circle) {
      case ContactCircle.proches:
        return 'Proches';
      case ContactCircle.eloignes:
        return 'Eloignes';
      case ContactCircle.partenaire:
        return 'Partenaire';
      case ContactCircle.amis:
        return 'Amis';
    }
  }

  String _circleSubtitle(ContactCircle circle) {
    switch (circle) {
      case ContactCircle.proches:
        return 'Proche';
      case ContactCircle.eloignes:
        return 'Eloigne';
      case ContactCircle.partenaire:
        return 'Partenaire';
      case ContactCircle.amis:
        return 'Ami';
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.mutedText,
  });

  final String title;
  final int count;
  final Color mutedText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: mutedText,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Text(
            count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyContactsState extends StatelessWidget {
  const _EmptyContactsState({required this.mutedText});

  final Color mutedText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_outlined,
              size: 56,
              color: theme.colorScheme.primary.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun proche pour le moment.',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez un premier proche pour commencer votre agenda relationnel.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: mutedText,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushNamed(ContactEditPage.routeName);
              },
              child: const Text('Ajouter un proche'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.mutedText});

  final Color mutedText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Aucun resultat pour cette recherche.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: mutedText,
            ),
      ),
    );
  }
}

class _SyncPromoCard extends StatelessWidget {
  const _SyncPromoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.group,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Synchroniser vos contacts',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Retrouvez automatiquement vos proches pour ne jamais oublier de leur ecrire.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: theme.colorScheme.primary,
            ),
            onPressed: () {},
            child: const Text('Autoriser l\'acces'),
          ),
        ],
      ),
    );
  }
}
