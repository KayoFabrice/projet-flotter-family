import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_completion_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_completion.dart';
import 'package:projet_flutter_famille/features/contacts/presentation/providers/onboarding_completion_provider.dart';

class FakeOnboardingCompletionRepository
    implements OnboardingCompletionRepository {
  FakeOnboardingCompletionRepository(this._value);

  bool _value;

  @override
  Future<bool> fetchIsComplete() async => _value;

  @override
  Future<void> setComplete(bool value) async {
    _value = value;
  }
}

class FailingOnboardingCompletionRepository
    implements OnboardingCompletionRepository {
  @override
  Future<bool> fetchIsComplete() async => false;

  @override
  Future<void> setComplete(bool value) async {
    throw Exception('db failure');
  }
}

void main() {
  test('OnboardingCompletionProvider exposes initial state and updates', () async {
    final fakeRepository = FakeOnboardingCompletionRepository(false);
    final container = ProviderContainer(
      overrides: [
        onboardingCompletionRepositoryProvider
            .overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(onboardingCompletionProvider),
      isA<AsyncLoading<OnboardingCompletion>>(),
    );

    final initial = await container.read(onboardingCompletionProvider.future);
    expect(initial.isComplete, isFalse);

    await container
        .read(onboardingCompletionProvider.notifier)
        .markComplete();

    final updated = await container.read(onboardingCompletionProvider.future);
    expect(updated.isComplete, isTrue);
  });

  test('OnboardingCompletionProvider surfaces errors on failure', () async {
    final container = ProviderContainer(
      overrides: [
        onboardingCompletionRepositoryProvider.overrideWithValue(
          FailingOnboardingCompletionRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final success = await container
        .read(onboardingCompletionProvider.notifier)
        .markComplete();

    expect(success, isFalse);
    expect(
      container.read(onboardingCompletionProvider),
      isA<AsyncError<OnboardingCompletion>>(),
    );
  });
}
