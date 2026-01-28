enum OnboardingStep {
  welcome,
  circles,
}

extension OnboardingStepMapping on OnboardingStep {
  static OnboardingStep fromStorage(String value) {
    switch (value) {
      case 'circles':
        return OnboardingStep.circles;
      case 'welcome':
      default:
        return OnboardingStep.welcome;
    }
  }

  String get storageValue {
    switch (this) {
      case OnboardingStep.welcome:
        return 'welcome';
      case OnboardingStep.circles:
        return 'circles';
    }
  }
}
