import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/navigation/app_shell.dart';
import 'features/contacts/presentation/pages/circles_page.dart';
import 'features/contacts/presentation/pages/cadence_page.dart';
import 'features/contacts/presentation/pages/first_contacts_page.dart';
import 'features/contacts/presentation/pages/import_contacts_page.dart';
import 'features/contacts/presentation/pages/onboarding_gate.dart';
import 'features/contacts/presentation/pages/ready_page.dart';
import 'features/contacts/presentation/pages/welcome_page.dart';
import 'features/settings/presentation/pages/location_or_availability_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFFF6F7F3);
    const foreground = Color(0xFF0F172A);
    const border = Color(0xFFE2E8F0);
    const input = Color(0xFFF2F4F8);
    const primary = Color(0xFF4C6FFF);
    const secondary = Color(0xFFF3F4F6);
    const destructive = Color(0xFFEF4444);
    const card = Colors.white;

    final baseTextTheme = ThemeData.light().textTheme;
    return MaterialApp(
      title: 'projet_flutter_famille',
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: primary,
          onPrimary: Colors.white,
          secondary: secondary,
          onSecondary: foreground,
          surface: card,
          onSurface: foreground,
          error: destructive,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: background,
        dividerColor: border,
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(baseTextTheme),
        cardTheme: CardThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: card,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: input,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: border),
            borderRadius: BorderRadius.circular(12),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: foreground,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const OnboardingGate(),
      routes: {
        WelcomePage.routeName: (_) => const WelcomePage(),
        CirclesPage.routeName: (_) => const CirclesPage(),
        FirstContactsPage.routeName: (_) => const FirstContactsPage(),
        CadencePage.routeName: (_) => const CadencePage(),
        ImportContactsPage.routeName: (_) => const ImportContactsPage(),
        LocationOrAvailabilityPage.routeName: (_) =>
            const LocationOrAvailabilityPage(),
        ReadyPage.routeName: (_) => const ReadyPage(),
        AppShell.routeName: (_) => const AppShell(),
      },
    );
  }
}
