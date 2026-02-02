import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/contact_edit_page.dart';

void main() {
  testWidgets('ContactEditPage shows inline validation errors', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ContactEditPage(),
        ),
      ),
    );

    expect(find.text('Enregistrer'), findsOneWidget);
    expect(find.text('Annuler'), findsOneWidget);

    final submitFinder = find.text('Enregistrer');
    await tester.ensureVisible(submitFinder);
    await tester.tap(submitFinder, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Nom requis'), findsOneWidget);
    expect(find.text('Categorie requise'), findsOneWidget);
  });
}
