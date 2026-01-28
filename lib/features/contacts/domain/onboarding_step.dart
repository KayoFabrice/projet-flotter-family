enum OnboardingStep {
  welcome,
  circles,
  firstContacts,
  cadence,
  importContacts,
}

extension OnboardingStepMapping on OnboardingStep {
  static OnboardingStep fromStorage(String value) {
    switch (value) {
      case 'first_contacts':
        return OnboardingStep.firstContacts;
      case 'cadence':
        return OnboardingStep.cadence;
      case 'import_contacts':
        return OnboardingStep.importContacts;
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
      case OnboardingStep.cadence:
        return 'cadence';
      case OnboardingStep.importContacts:
        return 'import_contacts';
    }
  }
}
