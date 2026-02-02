import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_cadence.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/settings/presentation/pages/cadence_settings_page.dart';

void main() {
  testWidgets('CadenceSettingsContent shows defaults and saves', (tester) async {
    var saved = false;
    final cadences = [
      ContactCadence(circle: ContactCircle.proches, cadenceDays: 7),
      ContactCadence(circle: ContactCircle.eloignes, cadenceDays: 30),
      ContactCadence(circle: ContactCircle.partenaire, cadenceDays: 14),
      ContactCadence(circle: ContactCircle.amis, cadenceDays: 14),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CadenceSettingsContent(
            cadences: cadences,
            onCadenceSelected: (_, __) {},
            onSavePressed: () {
              saved = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Cadence'), findsOneWidget);
    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Freres & Soeurs'), findsOneWidget);
    expect(find.text('Grand-parents'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Amis proches'), 200);
    expect(find.text('Amis proches'), findsOneWidget);
    expect(find.text('Enregistrer'), findsOneWidget);

    Future<ChoiceChip> findChip(ValueKey<String> key) async {
      await tester.scrollUntilVisible(find.byKey(key), 200);
      return tester.widget<ChoiceChip>(find.byKey(key));
    }

    final prochesChip = await findChip(const ValueKey('cadence-proches-7'));
    final eloignesChip = await findChip(const ValueKey('cadence-eloignes-30'));
    final partenaireChip = await findChip(const ValueKey('cadence-partenaire-14'));
    final amisChip = await findChip(const ValueKey('cadence-amis-14'));

    expect(prochesChip.selected, isTrue);
    expect(eloignesChip.selected, isTrue);
    expect(partenaireChip.selected, isTrue);
    expect(amisChip.selected, isTrue);

    await tester.tap(find.text('Enregistrer'));
    expect(saved, isTrue);
  });
}
