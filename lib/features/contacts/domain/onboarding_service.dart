import '../data/onboarding_repository.dart';
import 'onboarding_step.dart';

class OnboardingService {
  OnboardingService(this._repository);

  final OnboardingRepository _repository;

  Future<OnboardingStep> loadCurrentStep() {
    return _repository.fetchCurrentStep();
  }

  Future<void> saveCurrentStep(OnboardingStep step) {
    return _repository.setCurrentStep(step);
  }
}
