import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/navigation/app_shell.dart';
import 'features/contacts/presentation/pages/circles_page.dart';
import 'features/contacts/presentation/pages/onboarding_gate.dart';
import 'features/contacts/presentation/pages/welcome_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'projet_flutter_famille',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6A7B6C)),
        useMaterial3: true,
      ),
      home: const OnboardingGate(),
      routes: {
        WelcomePage.routeName: (_) => const WelcomePage(),
        CirclesPage.routeName: (_) => const CirclesPage(),
        AppShell.routeName: (_) => const AppShell(),
      },
    );
  }
}
