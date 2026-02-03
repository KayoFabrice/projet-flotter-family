import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/features/reminders/domain/notification_action_payload.dart';

void main() {
  test('NotificationActionPayloadParser refuse call sans tel scheme', () {
    final parsed = NotificationActionPayloadParser.tryParse({
      'action': 'call',
      'contactId': 'c1',
      'uri': 'mailto:test@example.com',
    });

    expect(parsed, isNull);
  });

  test('NotificationActionPayloadParser accepte call avec tel scheme', () {
    final parsed = NotificationActionPayloadParser.tryParse({
      'action': 'call',
      'contactId': 'c1',
      'uri': 'tel:+33612345678',
    });

    expect(parsed, isA<NotificationCallActionPayload>());
    final payload = parsed as NotificationCallActionPayload;
    expect(payload.contactId, 'c1');
    expect(payload.uri.scheme, 'tel');
  });
}
