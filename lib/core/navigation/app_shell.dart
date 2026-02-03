import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/contacts/presentation/pages/contacts_page.dart';
import '../../features/contacts/domain/contact.dart';
import '../../features/contacts/domain/contact_write_action_service.dart';
import '../../features/contacts/presentation/providers/contact_action_provider.dart';
import '../../features/agenda/presentation/providers/suggestion_provider.dart';
import '../../features/agenda/presentation/widgets/agenda_section.dart';
import '../../features/agenda/presentation/widgets/suggestion_card.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static const routeName = '/shell';

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static final _pages = <Widget>[
    const _AgendaPage(),
    const ContactsPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Agenda',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            label: 'Proches',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: 'Reglages',
          ),
        ],
      ),
    );
  }
}

class _AgendaPage extends ConsumerStatefulWidget {
  const _AgendaPage();

  @override
  ConsumerState<_AgendaPage> createState() => _AgendaPageState();
}

class _AgendaPageState extends ConsumerState<_AgendaPage> {
  late SuggestionContext _context;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshContext();
    _scheduleNextRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _refreshContext() {
    final now = DateTime.now();
    _context = SuggestionContext(
      currentMinuteOfDay: now.hour * 60 + now.minute,
      nowUtc: now.toUtc(),
      nowLocal: now,
    );
  }

  void _scheduleNextRefresh() {
    final now = DateTime.now();
    final secondsUntilNextMinute = 60 - now.second;
    _refreshTimer = Timer(Duration(seconds: secondsUntilNextMinute), () {
      if (!mounted) {
        return;
      }
      setState(_refreshContext);
      _scheduleNextRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final decision = ref.watch(suggestionDecisionProvider(_context));

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          decision.when(
            data: (result) => result.hasSuggestion
                ? SuggestionCard(
                    decision: result,
                    onWrite: () => _handleWrite(result.contact),
                    onCall: _handleCall,
                    onLater: _handleLater,
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          if (decision.maybeWhen(
            data: (result) => result.hasSuggestion,
            orElse: () => false,
          ))
            const SizedBox(height: 16),
          const AgendaSection(
            title: "Aujourd'hui",
            subtitle: 'Aucune action planifiee pour le moment.',
          ),
          const SizedBox(height: 12),
          const AgendaSection(
            title: 'Cette semaine',
            subtitle: 'Aucune action planifiee pour le moment.',
          ),
          const SizedBox(height: 12),
          const AgendaSection(
            title: 'Ce mois',
            subtitle: 'Aucune action planifiee pour le moment.',
          ),
        ],
      ),
    );
  }

  Future<void> _handleWrite(Contact? contact) async {
    if (contact == null) {
      _showActionFeedback('Ecrire');
      return;
    }
    final service = ref.read(contactWriteActionServiceProvider);
    final options = service.buildWriteOptions(contact);
    if (options.isEmpty) {
      _showSnackBar('Ajoutez un numero ou un email pour ecrire.');
      return;
    }
    if (options.length == 1) {
      await _launchWriteOption(contact.id, options.first);
      return;
    }
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
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
                onTap: () async {
                  Navigator.of(context).pop();
                  await _launchWriteOption(contact.id, option);
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

  Future<void> _launchWriteOption(
    String contactId,
    ContactWriteOption option,
  ) async {
    final service = ref.read(contactWriteActionServiceProvider);
    final result = await service.launchWrite(
      contactId: contactId,
      uri: option.uri,
    );
    if (!mounted) {
      return;
    }
    switch (result) {
      case ContactWriteOutcome.success:
        _showSnackBar('Ecriture lancee.');
        break;
      case ContactWriteOutcome.unavailable:
        _showSnackBar('Action indisponible sur cet appareil.');
        break;
      case ContactWriteOutcome.failed:
        _showSnackBar('Impossible d\'ouvrir l\'application.');
        break;
    }
  }

  void _handleCall() => _showActionFeedback('Appeler');
  void _handleLater() => _showActionFeedback('Plus tard');

  void _showActionFeedback(String label) {
    _showSnackBar('$label bientot disponible.');
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
