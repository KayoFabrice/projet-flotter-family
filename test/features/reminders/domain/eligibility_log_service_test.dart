import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/reminders/domain/eligibility_log_service.dart';
import 'package:projet_flutter_famille/features/reminders/domain/eligibility_result.dart';

void main() {
  test('EligibilityLogService enregistre et expose le dernier statut', () {
    final log = EligibilityLogService();

    expect(log.latest, isNull);

    log.record(EligibilityResult.locationMismatch);
    log.record(EligibilityResult.eligible);

    expect(log.entries.length, 2);
    expect(log.latest?.result.status, EligibilityStatus.eligible);
    expect(log.latest?.recordedAt, isNotNull);
  });
}
