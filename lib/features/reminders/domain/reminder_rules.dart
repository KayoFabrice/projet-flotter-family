import '../../settings/domain/availability_window.dart';
import 'eligibility_result.dart';
import 'rest_window.dart';

class ReminderRules {
  EligibilityResult evaluateEligibility({
    required String? currentLocationLabel,
    required List<String> keyLocations,
    required int currentMinuteOfDay,
    required List<AvailabilityWindow> windows,
    List<RestWindow> restWindows = const [],
  }) {
    if (_isWithinRestWindows(currentMinuteOfDay, restWindows)) {
      return EligibilityResult.restWindow;
    }
    if (_isRestResumeBlocked(currentMinuteOfDay, restWindows)) {
      return EligibilityResult.restWindow;
    }
    if (!_matchesKeyLocation(currentLocationLabel, keyLocations)) {
      return EligibilityResult.locationMismatch;
    }
    if (!_isWithinWindows(currentMinuteOfDay, windows)) {
      return EligibilityResult.outsideAvailabilityWindow;
    }
    return EligibilityResult.eligible;
  }

  bool _matchesKeyLocation(
    String? currentLocationLabel,
    List<String> keyLocations,
  ) {
    final normalizedCurrent = _normalizeLabel(currentLocationLabel);
    if (normalizedCurrent == null || normalizedCurrent.isEmpty) {
      return true;
    }
    for (final location in keyLocations) {
      final normalizedLocation = _normalizeLabel(location);
      if (normalizedLocation != null && normalizedLocation == normalizedCurrent) {
        return true;
      }
    }
    return false;
  }

  String? _normalizeLabel(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed.toLowerCase();
  }

  bool _isWithinWindows(
    int currentMinuteOfDay,
    List<AvailabilityWindow> windows,
  ) {
    if (currentMinuteOfDay < 0 || currentMinuteOfDay > 24 * 60) {
      return false;
    }
    for (final window in windows) {
      if (currentMinuteOfDay >= window.startMinute &&
          currentMinuteOfDay < window.endMinute) {
        return true;
      }
    }
    return false;
  }

  bool _isWithinRestWindows(
    int currentMinuteOfDay,
    List<RestWindow> windows,
  ) {
    if (currentMinuteOfDay < 0 || currentMinuteOfDay > 24 * 60) {
      return false;
    }
    for (final window in windows) {
      if (window.contains(currentMinuteOfDay)) {
        return true;
      }
    }
    return false;
  }

  bool _isRestResumeBlocked(
    int currentMinuteOfDay,
    List<RestWindow> windows,
  ) {
    if (currentMinuteOfDay < 0 || currentMinuteOfDay > 24 * 60) {
      return false;
    }
    for (final window in windows) {
      if (currentMinuteOfDay == window.endMinute) {
        return true;
      }
    }
    return false;
  }
}
