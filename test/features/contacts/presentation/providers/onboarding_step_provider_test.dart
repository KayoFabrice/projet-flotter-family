import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_step.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_step_provider.dart';

class FakeOnboardingRepository implements OnboardingRepository {
  FakeOnboardingRepository(this._step);

  OnboardingStep _step;

  @override
  Future<OnboardingStep> fetchCurrentStep() async => _step;

  @override
  Future<void> setCurrentStep(OnboardingStep step) async {
    _step = step;
  }
}

class FailingOnboardingRepository implements OnboardingRepository {
  @override
  Future<OnboardingStep> fetchCurrentStep() async => OnboardingStep.welcome;

  @override
  Future<void> setCurrentStep(OnboardingStep step) async {
    throw Exception('db failure');
  }
}

void main() {
  test('OnboardingStepProvider exposes initial step and updates', () async {
    final fakeRepository = FakeOnboardingRepository(OnboardingStep.welcome);
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(onboardingStepProvider),
      isA<AsyncLoading<OnboardingStep>>(),
    );

    final initial = await container.read(onboardingStepProvider.future);
    expect(initial, OnboardingStep.welcome);

    await container.read(onboardingStepProvider.notifier).setStep(
          OnboardingStep.circles,
        );

    final updated = await container.read(onboardingStepProvider.future);
    expect(updated, OnboardingStep.circles);
  });

  test('OnboardingStepProvider surfaces errors when persistence fails', () async {
    final container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(
          FailingOnboardingRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final success = await container
        .read(onboardingStepProvider.notifier)
        .setStep(OnboardingStep.circles);

    expect(success, isFalse);
    expect(container.read(onboardingStepProvider), isA<AsyncError<OnboardingStep>>());
  });
}
