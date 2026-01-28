import 'package:flutter/material.dart';

class ImportContactsPage extends StatelessWidget {
  const ImportContactsPage({super.key});

  static const routeName = '/onboarding/import-contacts';
  static const _pageBackground = Color(0xFFF6F7F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Importer vos contacts',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Cette etape arrive bientot. Vous pourrez importer vos contacts ici.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Aucune permission systeme n'est demandee a cette etape.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.black54,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
