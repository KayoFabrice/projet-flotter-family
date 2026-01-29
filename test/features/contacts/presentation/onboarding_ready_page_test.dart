import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/onboarding_ready_page.dart';

void main() {
  testWidgets('OnboardingReadyPage shows CTA to go to agenda', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: OnboardingReadyPage(),
        ),
      ),
    );

    expect(find.text('Decouvrir mon agenda'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
