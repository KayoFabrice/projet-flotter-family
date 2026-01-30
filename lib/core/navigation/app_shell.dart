import 'package:flutter/material.dart';

import '../../features/contacts/presentation/pages/contacts_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static const routeName = '/shell';

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _pages = <Widget>[
    _PlaceholderPage(title: 'Agenda'),
    ContactsPage(),
    _PlaceholderPage(title: 'Reglages'),
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

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Text(title),
      ),
    );
  }
}
