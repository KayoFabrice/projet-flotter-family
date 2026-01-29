import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/contacts/data/onboarding_completion_repository.dart';
import 'package:projet_flutter_famille/features/contacts/domain/onboarding_completion_service.dart';

class FakeOnboardingCompletionRepository implements OnboardingCompletionRepository {
  bool value;

  FakeOnboardingCompletionRepository(this.value);

  @override
  Future<bool> fetchIsComplete() async => value;

  @override
  Future<void> setComplete(bool value) async {
    this.value = value;
  }
}

void main() {
  test('OnboardingCompletionService saves and reloads completion flag', () async {
    final repository = FakeOnboardingCompletionRepository(false);
    final service = OnboardingCompletionService(repository);

    final initial = await service.loadCompletion();
    expect(initial.isComplete, isFalse);

    await service.markComplete();

    final updated = await service.loadCompletion();
    expect(updated.isComplete, isTrue);
  });
}
