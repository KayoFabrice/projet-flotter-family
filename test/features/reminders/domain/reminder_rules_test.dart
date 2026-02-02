import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/reminders/domain/eligibility_result.dart';
import 'package:projet_flutter_famille/features/reminders/domain/reminder_rules.dart';
import 'package:projet_flutter_famille/features/reminders/domain/rest_window.dart';
import 'package:projet_flutter_famille/features/settings/domain/availability_window.dart';

void main() {
  test('ReminderRules eligibile quand lieu + plage OK', () {
    final rules = ReminderRules();
    final result = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison', 'Bureau'],
      currentMinuteOfDay: 10 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      ],
    );

    expect(result.status, EligibilityStatus.eligible);
    expect(result.isEligible, isTrue);
  });

  test('ReminderRules non eligible hors plage', () {
    final rules = ReminderRules();
    final result = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 8 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      ],
    );

    expect(result.status, EligibilityStatus.outsideAvailabilityWindow);
    expect(result.isEligible, isFalse);
  });

  test('ReminderRules non eligible lieu non correspondant', () {
    final rules = ReminderRules();
    final result = rules.evaluateEligibility(
      currentLocationLabel: 'Parc',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 10 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      ],
    );

    expect(result.status, EligibilityStatus.locationMismatch);
    expect(result.isEligible, isFalse);
  });

  test('ReminderRules respecte les frontieres de plage', () {
    final rules = ReminderRules();
    final window =
        const AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60);

    final startStatus = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 9 * 60,
      windows: [window],
    );
    final endStatus = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 12 * 60,
      windows: [window],
    );

    expect(startStatus.status, EligibilityStatus.eligible);
    expect(endStatus.status, EligibilityStatus.outsideAvailabilityWindow);
  });

  test('ReminderRules accepte l\'absence de localisation en mode degrade', () {
    final rules = ReminderRules();
    final result = rules.evaluateEligibility(
      currentLocationLabel: null,
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 10 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      ],
    );

    expect(result.status, EligibilityStatus.eligible);
  });

  test('ReminderRules rejette minute hors bornes', () {
    final rules = ReminderRules();
    final result = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 25 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 12 * 60),
      ],
    );

    expect(result.status, EligibilityStatus.outsideAvailabilityWindow);
  });

  test('ReminderRules bloque pendant la periode de repos', () {
    final rules = ReminderRules();
    final result = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 23 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 23 * 60),
      ],
      restWindows: const [
        RestWindow(startMinute: 22 * 60, endMinute: 7 * 60),
      ],
    );

    expect(result.status, EligibilityStatus.restWindow);
    expect(result.isEligible, isFalse);
  });

  test('ReminderRules respecte les frontieres de repos', () {
    final rules = ReminderRules();
    final restWindow =
        const RestWindow(startMinute: 22 * 60, endMinute: 7 * 60);

    final startStatus = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 22 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 23 * 60),
      ],
      restWindows: [restWindow],
    );
    final endStatus = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 7 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 9 * 60, endMinute: 23 * 60),
      ],
      restWindows: [restWindow],
    );

    expect(startStatus.status, EligibilityStatus.restWindow);
    expect(endStatus.status, EligibilityStatus.restWindow);
  });

  test('ReminderRules redevient eligible apres la fin du repos', () {
    final rules = ReminderRules();
    final restWindow =
        const RestWindow(startMinute: 22 * 60, endMinute: 7 * 60);

    final endStatus = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 7 * 60,
      windows: const [
        AvailabilityWindow(startMinute: 7 * 60, endMinute: 10 * 60),
      ],
      restWindows: [restWindow],
    );
    final afterStatus = rules.evaluateEligibility(
      currentLocationLabel: 'Maison',
      keyLocations: const ['Maison'],
      currentMinuteOfDay: 7 * 60 + 1,
      windows: const [
        AvailabilityWindow(startMinute: 7 * 60, endMinute: 10 * 60),
      ],
      restWindows: [restWindow],
    );

    expect(endStatus.status, EligibilityStatus.restWindow);
    expect(afterStatus.status, EligibilityStatus.eligible);
  });
}
