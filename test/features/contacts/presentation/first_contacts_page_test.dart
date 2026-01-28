import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/first_contacts_page.dart';

void main() {
  testWidgets('FirstContactsContent shows contacts and CTAs', (tester) async {
    final contacts = [
      Contact(
        id: 1,
        displayName: 'Alex',
        circle: ContactCircle.amis,
        createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
      ),
      Contact(
        id: 2,
        displayName: 'Sarah',
        circle: ContactCircle.proches,
        createdAt: DateTime(2026, 1, 2).toUtc().toIso8601String(),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: FirstContactsContent(
          contacts: contacts,
          onAddPressed: () {},
          onContinuePressed: () {},
        ),
      ),
    );

    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Sarah'), findsOneWidget);
    expect(find.text('Amis proches'), findsOneWidget);
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Continuer'), findsOneWidget);
    expect(find.text('Ajouter un proche'), findsOneWidget);
  });

  testWidgets('Add button is disabled when three contacts are present', (tester) async {
    final contacts = [
      Contact(
        id: 1,
        displayName: 'Alex',
        circle: ContactCircle.amis,
        createdAt: DateTime(2026, 1, 1).toUtc().toIso8601String(),
      ),
      Contact(
        id: 2,
        displayName: 'Sarah',
        circle: ContactCircle.proches,
        createdAt: DateTime(2026, 1, 2).toUtc().toIso8601String(),
      ),
      Contact(
        id: 3,
        displayName: 'Leo',
        circle: ContactCircle.eloignes,
        createdAt: DateTime(2026, 1, 3).toUtc().toIso8601String(),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: FirstContactsContent(
          contacts: contacts,
          onAddPressed: () {},
          onContinuePressed: () {},
        ),
      ),
    );

    final addButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(addButton.onPressed, isNull);
  });
}
