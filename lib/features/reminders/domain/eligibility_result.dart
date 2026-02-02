enum EligibilityStatus {
  eligible,
  locationMismatch,
  outsideAvailabilityWindow,
  restWindow,
}

class EligibilityResult {
  const EligibilityResult({
    required this.status,
    required this.reason,
  });

  final EligibilityStatus status;
  final String reason;

  bool get isEligible => status == EligibilityStatus.eligible;
  bool get shouldNotify => isEligible;

  static const EligibilityResult eligible = EligibilityResult(
    status: EligibilityStatus.eligible,
    reason: 'eligible',
  );

  static const EligibilityResult locationMismatch = EligibilityResult(
    status: EligibilityStatus.locationMismatch,
    reason: 'location_mismatch',
  );

  static const EligibilityResult outsideAvailabilityWindow = EligibilityResult(
    status: EligibilityStatus.outsideAvailabilityWindow,
    reason: 'outside_availability_window',
  );

  static const EligibilityResult restWindow = EligibilityResult(
    status: EligibilityStatus.restWindow,
    reason: 'rest_window',
  );
}

class EligibilityLogEntry {
  const EligibilityLogEntry({
    required this.result,
    required this.recordedAt,
  });

  final EligibilityResult result;
  final DateTime recordedAt;
}

class EligibilityDecision {
  const EligibilityDecision({
    required this.result,
  });

  final EligibilityResult result;

  bool get shouldNotify => result.shouldNotify;
}
