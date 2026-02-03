import 'package:flutter_test/flutter_test.dart';
import 'package:projet_flutter_famille/core/notifications/local_notifications_service.dart';

void main() {
  test('buildRouteArgs refuse actions non deferral', () {
    final args = LocalNotificationsService.buildRouteArgs('write', 'c1');

    expect(args, isNull);
  });

  test('buildRouteArgs refuse payload vide', () {
    final args = LocalNotificationsService.buildRouteArgs('later', '');

    expect(args, isNull);
  });

  test('buildRouteArgs accepte action later', () {
    final args = LocalNotificationsService.buildRouteArgs('later', 'c1');

    expect(args, isNotNull);
    expect(args!['action'], 'later');
    expect(args['contactId'], 'c1');
  });

  test('isDeferralAction valide later et not_now', () {
    expect(LocalNotificationsService.isDeferralAction('later'), isTrue);
    expect(LocalNotificationsService.isDeferralAction('not_now'), isTrue);
    expect(LocalNotificationsService.isDeferralAction('other'), isFalse);
  });
}
