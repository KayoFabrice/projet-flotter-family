import '../data/onboarding_completion_repository.dart';
import 'onboarding_completion.dart';

class OnboardingCompletionService {
  OnboardingCompletionService(this._repository);

  final OnboardingCompletionRepository _repository;

  Future<OnboardingCompletion> loadCompletion() async {
    final isComplete = await _repository.fetchIsComplete();
    return OnboardingCompletion(isComplete: isComplete);
  }

  Future<void> markComplete() {
    return _repository.setComplete(true);
  }
}
