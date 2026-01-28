enum OnboardingStep {
  welcome,
  circles,
  firstContacts,
}

extension OnboardingStepMapping on OnboardingStep {
  static OnboardingStep fromStorage(String value) {
    switch (value) {
      case 'first_contacts':
        return OnboardingStep.firstContacts;
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
      case OnboardingStep.firstContacts:
        return 'first_contacts';
    }
  }
}
