import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/cadence_page.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_cadence_provider.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/widgets/cadence_option_chip.dart';

class FailingCadenceNotifier extends OnboardingCadenceNotifier {
  @override
  Future<List<ContactCadence>> build() async {
    return const [
      ContactCadence(circle: ContactCircle.proches, cadenceDays: 7),
    ];
  }

  @override
  Future<bool> persist() async {
    return false;
  }
}

void main() {
  testWidgets('CadenceContent shows default values and CTA', (tester) async {
    final cadences = [
      ContactCadence(circle: ContactCircle.proches, cadenceDays: 7),
      ContactCadence(circle: ContactCircle.eloignes, cadenceDays: 30),
      ContactCadence(circle: ContactCircle.partenaire, cadenceDays: 14),
      ContactCadence(circle: ContactCircle.amis, cadenceDays: 14),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CadenceContent(
            cadences: cadences,
            onCadenceSelected: (_, __) {},
            onContinuePressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Quel est le bon rythme ?'), findsOneWidget);
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Freres & Soeurs'), findsOneWidget);
    expect(find.text('Grand-parents'), findsOneWidget);
    expect(find.text('Amis proches'), findsOneWidget);
    expect(find.text('Chaque semaine'), findsWidgets);
    expect(find.text('Tous les 15 jours'), findsWidgets);
    expect(find.text('Chaque mois'), findsWidgets);
    expect(find.text('Continuer'), findsOneWidget);

    final prochesChip = tester.widget<CadenceOptionChip>(
      find.byKey(const ValueKey('cadence-proches-7')),
    );
    final eloignesChip = tester.widget<CadenceOptionChip>(
      find.byKey(const ValueKey('cadence-eloignes-30')),
    );
    final partenaireChip = tester.widget<CadenceOptionChip>(
      find.byKey(const ValueKey('cadence-partenaire-14')),
    );
    final amisChip = tester.widget<CadenceOptionChip>(
      find.byKey(const ValueKey('cadence-amis-14')),
    );

    expect(prochesChip.selected, isTrue);
    expect(eloignesChip.selected, isTrue);
    expect(partenaireChip.selected, isTrue);
    expect(amisChip.selected, isTrue);
  });

  testWidgets('CadencePage shows snackbar when save fails', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCadenceProvider.overrideWith(FailingCadenceNotifier.new),
        ],
        child: const MaterialApp(
          home: CadencePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pump();

    expect(find.text("Impossible d'enregistrer la cadence."), findsOneWidget);
  });
}
