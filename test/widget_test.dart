// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:projet_flutter_famille/main.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_step.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_step_provider.dart';

class _FakeOnboardingRepository implements OnboardingRepository {
  _FakeOnboardingRepository(this._step);

  OnboardingStep _step;

  @override
  Future<OnboardingStep> fetchCurrentStep() async => _step;

  @override
  Future<void> setCurrentStep(OnboardingStep step) async {
    _step = step;
  }
}

void main() {
  testWidgets('App shows the welcome CTA on launch', (tester) async {
    final fakeRepository = _FakeOnboardingRepository(OnboardingStep.welcome);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Commencer'), findsOneWidget);
  });
}
