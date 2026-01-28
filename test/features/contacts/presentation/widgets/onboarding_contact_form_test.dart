import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/domain/contact_circle.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/widgets/onboarding_contact_form.dart';

void main() {
  testWidgets('OnboardingContactForm shows selected circles as options', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingContactForm(
            availableCircles: const [
              ContactCircle.proches,
              ContactCircle.amis,
            ],
            onSubmit: (displayName, circle) async {},
          ),
        ),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<ContactCircle>));
    await tester.pumpAndSettle();

    expect(find.text('Parents'), findsOneWidget);
    expect(find.text('Amis proches'), findsOneWidget);
  });

  testWidgets('OnboardingContactForm requires name and circle', (tester) async {
    var submitted = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OnboardingContactForm(
            availableCircles: const [ContactCircle.proches],
            onSubmit: (displayName, circle) async {
              submitted = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ajouter'));
    await tester.pump();

    expect(submitted, isFalse);
    expect(find.text('Nom requis'), findsOneWidget);
    expect(find.text('Cercle requis'), findsOneWidget);
  });
}
