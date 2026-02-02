import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/widgets/circle_selector_sheet.dart';

void main() {
  testWidgets('CircleSelectorSheet disables confirm for unchanged selection', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CircleSelectorSheet(initialCircle: ContactCircle.proches),
        ),
      ),
    );

    final confirmFinder = find.widgetWithText(FilledButton, 'Confirmer');
    expect(confirmFinder, findsOneWidget);

    FilledButton confirmButton = tester.widget(confirmFinder);
    expect(confirmButton.onPressed, isNull);

    await tester.tap(find.text(ContactCircle.amis.label));
    await tester.pump();

    confirmButton = tester.widget(confirmFinder);
    expect(confirmButton.onPressed, isNotNull);
  });
}
