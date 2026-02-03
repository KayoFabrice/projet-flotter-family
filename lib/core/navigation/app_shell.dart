import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/contacts/presentation/pages/contacts_page.dart';
import '../../features/reminders/presentation/providers/suggestion_provider.dart';
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
  late final SuggestionContext _context;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _context = SuggestionContext(
      currentMinuteOfDay: now.hour * 60 + now.minute,
      nowUtc: now.toUtc(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decision = ref.watch(suggestionDecisionProvider(_context));

    return SafeArea(
      child: Center(
        child: decision.when(
          data: (result) => Text(
            result.hasSuggestion
                ? 'Suggestion: ${result.contact?.displayName ?? ''}'
                : 'Aucune suggestion',
          ),
          loading: () => const Text('Chargement...'),
          error: (_, __) => const Text('Erreur de suggestion'),
        ),
      ),
    );
  }
}
