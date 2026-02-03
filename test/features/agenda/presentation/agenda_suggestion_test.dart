import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/core/navigation/app_shell.dart';
import 'package:projet_flutter_famille/features/agenda/presentation/providers/suggestion_provider.dart';
import 'package:projet_flutter_famille/features/agenda/presentation/widgets/suggestion_card.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/reminders/domain/suggestion_selector.dart';

void main() {
  testWidgets('Agenda shows suggestion card when suggestion exists', (tester) async {
    final decision = SuggestionDecision(
      contact: Contact(
        id: 'c-1',
        displayName: 'Camille Dupont',
        circle: ContactCircle.amis,
        createdAt: DateTime(2024, 1, 1).toIso8601String(),
      ),
      reason: 'test',
      message: 'Envoyer un message sympa',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          suggestionDecisionProvider.overrideWith((ref, _) async => decision),
        ],
        child: const MaterialApp(home: AppShell()),
      ),
    );

    await tester.pump();

    expect(find.byType(SuggestionCard), findsOneWidget);
    expect(find.text('Ecrire'), findsOneWidget);
    expect(find.text('Appeler'), findsOneWidget);
    expect(find.text('Plus tard'), findsOneWidget);
    final suggestionTop = tester.getTopLeft(find.byType(SuggestionCard)).dy;
    final todayTop = tester.getTopLeft(find.text("Aujourd'hui")).dy;
    expect(suggestionTop, lessThan(todayTop));
  });

  testWidgets('Agenda hides suggestion card when no suggestion', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          suggestionDecisionProvider.overrideWith(
            (ref, _) async => SuggestionDecision.noSuggestion,
          ),
        ],
        child: const MaterialApp(home: AppShell()),
      ),
    );

    await tester.pump();

    expect(find.byType(SuggestionCard), findsNothing);
    expect(find.text("Aujourd'hui"), findsOneWidget);
    expect(find.text('Cette semaine'), findsOneWidget);
    expect(find.text('Ce mois'), findsOneWidget);
  });
}
