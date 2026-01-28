import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/pages/welcome_page.dart';

void main() {
  testWidgets('WelcomePage shows a single primary CTA', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WelcomePage(),
        ),
      ),
    );

    expect(find.text('Commencer'), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
