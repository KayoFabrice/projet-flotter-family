enum OnboardingStep {
  welcome,
  circles,
  firstContacts,
  cadence,
  importContacts,
  locationOrAvailability,
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
      case 'location_or_availability':
        return OnboardingStep.locationOrAvailability;
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
      case OnboardingStep.locationOrAvailability:
        return 'location_or_availability';
    }
  }
}
